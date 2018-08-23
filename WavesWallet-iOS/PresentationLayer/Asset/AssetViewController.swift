//
//  AssetViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift
import UIKit

private enum Constants {
    static let segmentedControlHeight: CGFloat = 100
    static let segmentedControlTopPading: CGFloat = 11
    static let segmentedControlBottomPading: CGFloat = 24
}

final class AssetViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet var segmentedControl: WrapperAssetsSegmentedControl!

    private var refreshControl: UIRefreshControl!
    private var isHiddenSegmentedControl = false
    private let favoriteOffBarButton = UIBarButtonItem(image: Images.topbarFavoriteOff.image.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
    private let favoriteOnBarButton = UIBarButtonItem(image: Images.topbarFavoriteOn.image.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)

    var presenter: AssetPresenterProtocol!
    private var replaySubject: PublishSubject<Bool> = PublishSubject<Bool>()

    private var sections: [AssetTypes.ViewModel.Section] = .init()
    private var currentAssetName: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        createBackButton()
        tableView.backgroundColor = .basic50
        segmentedControl.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(segmentedControl)
        navigationItem.rightBarButtonItem = favoriteOffBarButton
        setupSystem()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPassthroughFrameForNavigationBar()
        updateContentInsetForTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationBar()
        hiddenSegmentedIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetSetupNavigationBar()
    }
}

// MARK:

extension AssetViewController {
}

// MARL: RxFeedback

private extension AssetViewController {

    func setupSystem() {

        let uiFeedback: AssetPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<AssetTypes.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: AssetPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .rx
                .viewWillAppear
                .take(1)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in AssetTypes.Event.readyView }
        }
        
        presenter.system(feedbacks: [uiFeedback, readyViewFeedback])
    }

    func events() -> [Signal<AssetTypes.Event>] {

        let eventChangedAsset = segmentedControl.currentAssetId().map { AssetTypes.Event.changedAsset(id: $0) }
        let favoriteOn = favoriteOnBarButton.rx.tap.asSignal().map { AssetTypes.Event.tapFavorite(on: false) }
        let favoriteOff = favoriteOffBarButton.rx.tap.asSignal().map { AssetTypes.Event.tapFavorite(on: true) }
        let refreshEvent = tableView.rx.didRefreshing(refreshControl: refreshControl).asSignal().map { _ in AssetTypes.Event.refreshing }


        return [eventChangedAsset, favoriteOn, favoriteOff, refreshEvent]
    }

    func subscriptions(state: Driver<AssetTypes.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }


    func updateView(with state: AssetTypes.DisplayState) {

        switch state.action {
        case .changedCurrentAsset:
            changeCurrentAsset(info: state.currentAsset)
            reloadSectionTable(with: state)
            
        case .refresh:
            reloadTable(with: state)
            reloadSegmentedControl(assets: state.assets, currentAsset: state.currentAsset)
            changeCurrentAsset(info: state.currentAsset)
            updateNavigationItem(with: state)
        case .changedFavorite:
            updateNavigationItem(with: state)
        case .none:
            break
        }
    }

    func updateNavigationItem(with state: AssetTypes.DisplayState) {
        if state.isFavorite {
            self.navigationItem.rightBarButtonItem = favoriteOnBarButton
        } else {
            self.navigationItem.rightBarButtonItem = favoriteOffBarButton
        }
    }

    func reloadSectionTable(with state: AssetTypes.DisplayState) {
        sections = state.sections
        tableView.beginUpdates()
        let count = max(0, sections.count - 1)
        tableView.reloadSections(IndexSet(0...count), with: .fade)
        tableView.endUpdates()
    }

    func reloadTable(with state: AssetTypes.DisplayState) {
        sections = state.sections
        tableView.reloadDataWithAnimationTheCrossDissolve()
    }

    func reloadSegmentedControl(assets: [AssetTypes.DTO.Asset.Info], currentAsset: AssetTypes.DTO.Asset.Info) {
        let assets = assets.map { $0.map() }
        segmentedControl.update(with: .init(assets: assets, currentAsset: currentAsset.map() ))
    }

    func changeCurrentAssetForSegmentedControl(info : AssetTypes.DTO.Asset.Info) {
        segmentedControl.setCurrentAsset(id: info.id)
    }

    func changeCurrentAsset(info : AssetTypes.DTO.Asset.Info) {
        currentAssetName = info.name
        layoutSegmentedControl(scrollView: tableView)
    }
}

// MARL: Setup Methods

extension AssetViewController {

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        if #available(iOS 10.0, *) {
            //            refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    private func setupNavigationBar() {
        setupSmallNavigationBar()
        navigationController?.navigationBar.shouldPassthroughTouch = true
        navigationController?.navigationBar.isEnabledPassthroughSubviews = true
    }

    private func resetSetupNavigationBar() {
        navigationController?.navigationBar.shouldPassthroughTouch = false
        navigationController?.navigationBar.isEnabledPassthroughSubviews = false
    }

    private func updateContentInsetForTableView() {

        let top = heightDifferenceSegmentedControlBetweenNavigationBar + Constants.segmentedControlBottomPading + Constants.segmentedControlTopPading
        tableView.contentInset = UIEdgeInsetsMake(top, 0, 24, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 24, 0)
    }
}

// MARK: Private Methods

private extension AssetViewController {

    private func layoutPassthroughFrameForNavigationBar() {
        let witdthCells = segmentedControl.witdthCells()
        navigationController?.navigationBar.passthroughFrame = CGRect(x: (view.frame.width - witdthCells) * 0.5, y: 0, width: witdthCells, height: 44)
    }

    private var heightDifferenceSegmentedControlBetweenNavigationBar: CGFloat {
        return -(navigationController?.navigationBar.frame.height ?? 0) + segmentedControl.frame.height
    }

    func layoutSegmentedControl(scrollView: UIScrollView, animated: Bool = true) {

        var yContent = scrollView.contentOffset.y
        if #available(iOS 11.0, *) {
            yContent += scrollView.adjustedContentInset.top
        }

        let navigationBarY = (navigationController?.navigationBar.frame.origin.y ?? 0) + Constants.segmentedControlTopPading
        var newPosY: CGFloat = navigationBarY - yContent
        newPosY = min(navigationBarY, newPosY)
        segmentedControl.frame.origin = CGPoint(x: 0, y: newPosY)
        segmentedControl.frame.size = CGSize(width: view.frame.size.width, height: Constants.segmentedControlHeight)

        hiddenSegmentedIfNeeded()
    }

    func hiddenSegmentedIfNeeded() {

        guard let navigationController = self.navigationController else { return }
        let navigationBar = navigationController.navigationBar
        guard let assetsSegmentedControl = self.segmentedControl.assetsSegmentedControl else { return }
        guard let titleLabel = assetsSegmentedControl.titleLabel else { return }

        let titleFrame = assetsSegmentedControl.convert(titleLabel.frame, to: view)
        let navigationFrame = view.convert(navigationBar.frame, to: view)
        let dif = (navigationFrame.height - titleFrame.height) * 0.5
        let navigationTitlePosition = navigationFrame.origin.y + dif

        let isHiddenSegmentedControl = navigationTitlePosition < titleFrame.origin.y

        if isHiddenSegmentedControl == false {
            showNavigationTitle()
        } else {
            showSegmentedControl()
        }
        self.isHiddenSegmentedControl = isHiddenSegmentedControl
    }

    func showNavigationTitle() {

        navigationItem.backgroundImage = nil
        navigationItem.shadowImage = nil
        title = currentAssetName
    }

    func showSegmentedControl() {

        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()
        title = nil
    }
}

extension AssetViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        layoutSegmentedControl(scrollView: scrollView)
    }
}

// MARK: - UITableView

extension AssetViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = sections[indexPath]

        switch row {
        case .balance(let balance):
            let cell: AssetBalanceCell = tableView.dequeueAndRegisterCell()
            cell.update(with: balance)
            return cell

        case .balanceSkeleton:
            let cell: AssetBalanceSkeletonCell = tableView.dequeueAndRegisterCell()
            return cell

        case .viewHistory:
            let cell: AssetViewHistoryCell = tableView.dequeueAndRegisterCell()
            return cell

        case .viewHistorySkeleton:
            let cell: AssetHistorySkeletonCell = tableView.dequeueAndRegisterCell()
            return cell

        case .lastTransactions:
            break

        case .transactionSkeleton:
            let cell: AssetTransactionSkeletonCell = tableView.dequeueAndRegisterCell()
            return cell

        case .viewHistoryDisabled:
            let cell: AssetEmptyHistoryCell = tableView.dequeueAndRegisterCell()
            return cell

        case .assetInfo(let info):
            let cell: AssetDetailCell = tableView.dequeueAndRegisterCell()
            cell.update(with: info)
            return cell
        }

        //        else if indexPath.section == Section.lastTransactions.rawValue {
        //            if indexPath.row == 0 {
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "AssetLastTransactionCell") as! AssetLastTransactionCell
        //                cell.setupCell(lastTransctions)
        //                return cell
        //            }
        //
        //            if lastTransctions.count == 0 {
        //                return tableView.dequeueReusableCell(withIdentifier: "AssetEmptyHistoryCell") as! AssetEmptyHistoryCell
        //            }
        //
        //            var cell: WalletHistoryCell! = tableView.dequeueReusableCell(withIdentifier: "WalletHistoryCell") as? WalletHistoryCell
        //            if cell == nil {
        //                cell = WalletHistoryCell.loadView() as? WalletHistoryCell
        //            }
        //            return cell
        //        }


        return UITableViewCell()
    }
}

extension AssetViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let model = sections[section]

        switch model.kind {
        case .skeletonTitle:
            return AssetHistorySkeletonCell.cellHeight()
        case .title(let title):
            return AssetHeaderView.viewHeight(model: title, width: tableView.frame.width)
        default:
            return CGFloat.minValue
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let model = sections[section]

        switch model.kind {
        case .skeletonTitle:
            return tableView.dequeueAndRegisterHeaderFooter() as AssetHeaderSkeletonView

        case .title(let title):
            let header = tableView.dequeueAndRegisterHeaderFooter() as AssetHeaderView
            header.update(with: title)
            return header

        default:
            break
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

//        else if indexPath.section == Section.lastTransactions.rawValue {
//            if indexPath.row == 0 {
//                return lastTransctions.count > 0 ? AssetLastTransactionCell.cellHeight() : 0
//            }

        let row = sections[indexPath]

        switch row {
        case .balance(let balance):
            return AssetBalanceCell.viewHeight(model: balance, width: tableView.frame.width)

        case .balanceSkeleton:
            return AssetBalanceSkeletonCell.cellHeight()

        case .viewHistory:
            return AssetViewHistoryCell.cellHeight()

        case .viewHistorySkeleton:
            return AssetHistorySkeletonCell.cellHeight()

        case .lastTransactions:
            break

        case .viewHistoryDisabled:
            return AssetEmptyHistoryCell.cellHeight()

        case .transactionSkeleton:
            return AssetTransactionSkeletonCell.cellHeight()

        case .assetInfo(let info):
            return AssetDetailCell.viewHeight(model: info, width: tableView.frame.width)
        }
        return CGFloat.minValue
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let row = sections[indexPath]

        switch row {
        case .balanceSkeleton:
            let cell = cell as? AssetBalanceSkeletonCell
            cell?.startAnimation()

        case .viewHistorySkeleton:
            let cell = cell as? AssetHistorySkeletonCell
            cell?.startAnimation()

        case .transactionSkeleton:
            let cell = cell as? AssetTransactionSkeletonCell
            cell?.startAnimation()
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        let model = sections[section]

        switch model.kind {
        case .skeletonTitle:
            let view = view as? AssetHeaderSkeletonView
            view?.startAnimation()
        default:
            break
        }
    }
}

// MARK: Assisstants
extension AssetTypes.DTO.Asset.Info {

    func map() -> AssetsSegmentedControl.Model.Asset {

        var kind: AssetsSegmentedControl.Model.Asset.Kind = .spam

        if isSpam {
            kind = .spam
        } else if isFiat {
            kind = .fiat
        } else if isGateway {
            kind = .gateway
        } else {
            kind = .wavesToken
        }

        return AssetsSegmentedControl.Model.Asset(id: id, name: name, kind: kind)
    }
}
