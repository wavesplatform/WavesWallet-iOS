//
//  AssetViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxFeedback

final class AssetViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet var segmentedControl: WrapperAssetsSegmentedControl!

    private var refreshControl: UIRefreshControl!
    private var isHiddenSegmentedControl = false
    private let favoriteOffBarButton = UIBarButtonItem(image: Images.topbarFavoriteOff.image, style: .plain, target: nil, action: nil)
    private let favoriteOnBarButton = UIBarButtonItem(image: Images.topbarFavoriteOn.image, style: .plain, target: nil, action: nil)

    private var presenter: AsssetPresenterProtocol! = AsssetPresenter()

    private var replaySubject: PublishSubject<Bool> = PublishSubject<Bool>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()

        let assets: [AssetsSegmentedControl.Asset] = [.init(name: "Waves", kind: .wavesToken),
                                                      .init(name: "BTC", kind: .gateway),
                                                      .init(name: "ALLADIN", kind: .spam),
                                                      .init(name: "USD", kind: .fiat)]
        segmentedControl.update(with: assets)

        view.addSubview(segmentedControl)
        navigationItem.rightBarButtonItem = favoriteOffBarButton
        favoriteOffBarButton.action = #selector(sendTapped)
        favoriteOffBarButton.target = self

        let bin: AsssetPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<AssetTypes.DisplayEvent>) in

            let event = owner.replaySubject.map { _ in AssetTypes.DisplayEvent.readyView }.asSignal(onErrorSignalWith: Signal.empty())


            return Bindings(subscriptions: [], events: [event])
        }
        presenter.system(feedbacks: [bin])
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

// MARL: RxFeedback

extension AssetViewController {

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
        tableView.contentInset = UIEdgeInsetsMake(heightDifferenceSegmentedControlBetweenNavigationBar, 0, 0, 0)
    }
}

// MARK: Private Methods

private extension AssetViewController {

    private func layoutPassthroughFrameForNavigationBar() {
        navigationController?.navigationBar.passthroughFrame = CGRect(x: (view.frame.width - 152) * 0.5, y: 0, width: 152, height: 44)
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

        let animations = {
            let isHiddenSegmentedControl = yContent < self.heightDifferenceSegmentedControlBetweenNavigationBar
            if isHiddenSegmentedControl == false {
                self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                self.navigationController?.navigationBar.shadowImage = nil
                self.title = "Waves"
            } else {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.title = nil
            }
            self.isHiddenSegmentedControl = isHiddenSegmentedControl
        }
        if animated {
            UIView.animate(withDuration: 0.34, delay: 0, options: [.transitionCrossDissolve, .beginFromCurrentState], animations: animations, completion: nil)
        } else {
            animations()
        }

        segmentedControl.frame.origin = CGPoint(x: 0, y: newPosY)
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

extension AssetViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == Section.lastTransactions.rawValue{
//            return WalletHeaderView.viewHeight()
//        }
//        else if section == Section.chart.rawValue && isAvailableChart {
//            return AssetChartHeaderView.viewHeight()
//        }

        return 0
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

        return 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        if section == Section.balance.rawValue {
//            return 1
//        }
//        else if section == Section.lastTransactions.rawValue {
//            return 2
//        }
//        else if section == Section.chart.rawValue {
//            return isAvailableChart ? 1 : 0
//        }
//        else if section == Section.info.rawValue {
//            return 1
//        }
        return 150
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
