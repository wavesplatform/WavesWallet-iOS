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

final class AssetViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet var segmentedControl: WrapperAssetsSegmentedControl!

    private var refreshControl: UIRefreshControl!
    private var isHiddenSegmentedControl = false
    private let favoriteOffBarButton = UIBarButtonItem(image: Images.topbarFavoriteOff.image, style: .plain, target: nil, action: nil)
    private let favoriteOnBarButton = UIBarButtonItem(image: Images.topbarFavoriteOn.image, style: .plain, target: nil, action: nil)

    private var presenter: AsssetPresenterProtocol! = AsssetPresenter()
    private var replaySubject: PublishSubject<Bool> = PublishSubject<Bool>()

    private var sections: [AssetTypes.ViewModel.Section] = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()

        let assets: [AssetsSegmentedControl.Asset] = [.init(id: "1", name: "Waves", kind: .wavesToken),
                                                      .init(id: "2", name: "BTC", kind: .gateway),
                                                      .init(id: "3", name: "ALLADIN", kind: .spam),
                                                      .init(id: "4", name: "USD", kind: .fiat)]
        segmentedControl.update(with: assets)

        view.addSubview(segmentedControl)
        navigationItem.rightBarButtonItem = favoriteOffBarButton
        favoriteOffBarButton.action = #selector(sendTapped)
        favoriteOffBarButton.target = self

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
        layoutSegmentedControl(scrollView: tableView, animated: animated)
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

        let bin: AsssetPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<AssetTypes.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: AsssetPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in AssetTypes.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [bin, readyViewFeedback])
    }

    func events() -> [Signal<AssetTypes.Event>] {

        return []
    }

    func subscriptions(state: Driver<AssetTypes.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

                guard let strongSelf = self else { return }

                strongSelf.sections = state.displayState.sections
                strongSelf.tableView.reloadDataWithAnimationTheCrossDissolve()
        })

        return [subscriptionSections]
    }

    static var number = 0
    @objc func sendTapped() {
//        presenter = nil

        if AssetViewController.number >= 2 {
            presenter = nil
        } else {
            AssetViewController.number += 1
            replaySubject.onNext(true)
        }
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
        navigationController?.navigationBar.shouldPassthroughTouch = true
        navigationController?.navigationBar.isEnabledPassthroughSubviews = true
    }

    private func resetSetupNavigationBar() {
        navigationController?.navigationBar.shouldPassthroughTouch = false
        navigationController?.navigationBar.isEnabledPassthroughSubviews = false
    }

    private func updateContentInsetForTableView() {
        tableView.contentInset = UIEdgeInsetsMake(heightDifferenceSegmentedControlBetweenNavigationBar + 24, 0, 0, 0)
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

        let navigationBarY = navigationController?.navigationBar.frame.origin.y ?? 0
        var newPosY: CGFloat = navigationBarY - yContent
        newPosY = min(navigationBarY, newPosY)
        segmentedControl.frame.origin = CGPoint(x: 0, y: newPosY)

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

        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        title = "Waves"
    }

    func showSegmentedControl() {

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        title = nil
    }
}

extension AssetViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        layoutSegmentedControl(scrollView: scrollView)
    }
}

//
//    @objc func sendTapped() {
//        let controller = StoryboardManager.WavesStoryboard().instantiateViewController(withIdentifier: "WavesSendViewController") as! WavesSendViewController
//        controller.hideTabBarOnBack = true
//        navigationController?.pushViewController(controller, animated: true)
//    }
//
//    @objc func receiveTapped() {
//        let controller = StoryboardManager.WavesStoryboard().instantiateViewController(withIdentifier: "WavesReceiveViewController") as! WavesReceiveViewController
//        controller.hideTabBarOnBack = true
//        navigationController?.pushViewController(controller, animated: true)
//
//    }
//
//    @objc func exchangeTapped() {
//
//    }
//
//    @objc func beginRefresh() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.refreshControl.endRefreshing()
//        }
//    }
//
//    @IBAction func favouriteTapped(_ sender: Any) {
//
//        inFavourite = !inFavourite
//        buttonFavourite.setImage(UIImage(named: inFavourite ? "topbarFavoriteOn" : "topbarFavoriteOff"), for: .normal)
//    }
//
//    @IBAction func backTapped(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
//
//    @objc func changeChartPeriod() {
//
//        let controller = UIAlertController(title: "Choose period", message: nil, preferredStyle: .actionSheet)
//        let day = UIAlertAction(title: "Day", style: .default) { (action) in
//
//            if self.selectedChartPediod == .day {
//                return
//            }
//            self.selectedChartPediod = .day
//            self.tableView.reloadData()
//        }
//        let week = UIAlertAction(title: "Week", style: .default) { (action) in
//
//            if self.selectedChartPediod == .week {
//                return
//            }
//            self.selectedChartPediod = .week
//            self.tableView.reloadData()
//        }
//        let month = UIAlertAction(title: "Month", style: .default) { (action) in
//
//            if self.selectedChartPediod == .month {
//                return
//            }
//            self.selectedChartPediod = .month
//            self.tableView.reloadData()
//        }
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        controller.addAction(day)
//        controller.addAction(week)
//        controller.addAction(month)
//        controller.addAction(cancel)
//        present(controller, animated: true, completion: nil)
//    }
//
//    func getChartPediodText() -> String {
//
//        if selectedChartPediod == .day {
//            return "Day"
//        }
//        else if selectedChartPediod == .week {
//            return "Week"
//        }
//        return "Month"
//    }
//

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
            break
        case .balanceSkeleton:
            let cell: AssetBalanceSkeletonCell = tableView.dequeueAndRegisterCell()

            return cell
        case .viewHistory:
            break
        case .viewHistorySkeleton:
            let cell: AssetHistorySkeletonCell = tableView.dequeueAndRegisterCell()

            return cell
        case .lastTransactions:
            break
        case .transactionSkeleton:
            let cell: AssetTransactionSkeletonCell = tableView.dequeueAndRegisterCell()

            return cell
        case .assetInfo:
            break
        }

        //
        //        if indexPath.section == Section.balance.rawValue {
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetBalanceCell") as! AssetBalanceCell
        //            cell.buttonSend.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        ////            cell.buttonReceive.addTarget(self, action: #selector(receiveTapped), for: .touchUpInside)
        ////            cell.buttonExchange.addTarget(self, action: #selector(exchangeTapped), for: .touchUpInside)
        //            cell.setupCell(isLeased: true, inOrder: true)
        //            return cell
        //        }
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
        //        else if indexPath.section == Section.chart.rawValue {
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetChartCell") as! AssetChartCell
        //            cell.setupCell(isNoDataChart: false)
        //            return cell
        //        }
        //        else if indexPath.section == Section.info.rawValue {
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetDetailCell") as! AssetDetailCell
        //            return cell
        //        }

        return UITableViewCell()
    }
}

extension AssetViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == Section.lastTransactions.rawValue{
//            return WalletHeaderView.viewHeight()
//        }
//        else if section == Section.chart.rawValue && isAvailableChart {
//            return AssetChartHeaderView.viewHeight()
//        }

        let model = sections[section]

        switch model.kind {
        case .skeletonTitle:
            return AssetHistorySkeletonCell.cellHeight()
        default:
            break
        }

        return CGFloat.minValue
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == Section.lastTransactions.rawValue {
//            let view: WalletHeaderView = tableView.dequeueAndRegisterHeaderFooter()
//            view.iconArrow.isHidden = true
//
//            if lastTransctions.count > 0 {
//                view.labelTitle.text = "Last transactions"
//            }
//            else {
//                view.labelTitle.text = "You do not have any transactions"
//            }
//
//            return view
//        }
//        else if section == Section.chart.rawValue && isAvailableChart {
//            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: AssetChartHeaderView.identifier()) as! AssetChartHeaderView
        ////            view.labelTitle.text = "\(getChartPediodText()) status"
        ////            view.buttonChangePeriod.addTarget(self, action: #selector(changeChartPeriod), for: .touchUpInside)
//            return view
//        }

        let model = sections[section]

        switch model.kind {
        case .skeletonTitle:
            var view: AssetHeaderSkeletonView = tableView.dequeueAndRegisterHeaderFooter()
            return view
        default:
            break
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == Section.balance.rawValue {
//            return AssetBalanceCell.cellHeight(isLeased: true, inOrder: true)
//        }
//        else if indexPath.section == Section.lastTransactions.rawValue {
//            if indexPath.row == 0 {
//                return lastTransctions.count > 0 ? AssetLastTransactionCell.cellHeight() : 0
//            }
//
//            return lastTransctions.count == 0 ? AssetEmptyHistoryCell.cellHeight() : WalletHistoryCell.cellHeight()
//        }
//        else if indexPath.section == Section.chart.rawValue {
//            return AssetChartCell.cellHeight()
//        }
//        else if indexPath.section == Section.info.rawValue {
//            return AssetDetailCell.cellHeight()
//        }
        let row = sections[indexPath]

        switch row {
        case .balance(let balance):
            break
        case .balanceSkeleton:
            return AssetBalanceSkeletonCell.cellHeight()
        case .viewHistory:
            break
        case .viewHistorySkeleton:
            return AssetHistorySkeletonCell.cellHeight()
        case .lastTransactions:
            break
        case .transactionSkeleton:
            return AssetTransactionSkeletonCell.cellHeight()
        case .assetInfo:
            break
        }

        return 100
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
