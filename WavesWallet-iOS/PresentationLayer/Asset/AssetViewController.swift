//
//  AssetViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private final class FrameListenerNavigationTitle: UIView {

    private enum Constants {
        static let frame = "frame"
    }

    var changedFrame: ((FrameListenerNavigationTitle, CGRect) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addObserver(self, forKeyPath: Constants.frame, options: [.new, .initial, .old], context: nil)
        autoresizingMask = [.flexibleWidth]
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == Constants.frame else { return }
        changedFrame?(self, frame)
    }

    deinit {
        removeObserver(self, forKeyPath: Constants.frame)
    }
}

// , UITableViewDelegate, UITableViewDataSource
final class AssetViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet var segmentedControl: WrapperAssetsSegmentedControl!


    enum Section: Int {
        case balance = 0
        case lastTransactions
        case chart
        case info
    }

    enum ChartPeriod: Int {
        case day
        case week
        case month
    }

    var selectedChartPediod = ChartPeriod.day
    let isAvailableChart = true
    let lastTransctions: [String] = ["WAVES", "USD", "Bitcoin", "ETH"]

    var inFavourite = false

    let headerItems = ["Waves", "ETH", "Bitcoin", "Eth Classic"]

    fileprivate enum StateTitleView {
        case assets
        case title
    }

    private var refreshControl: UIRefreshControl!

    private let frameListenerNavigationTitle: FrameListenerNavigationTitle = FrameListenerNavigationTitle()
    private var stateTitleView: StateTitleView = .assets
    private var originTitleFrame: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()
//        hideTopBarLine()
        setupRefreshControl()

        title = "test"
        view.addSubview(segmentedControl)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Aladin", style: .done, target: self, action: #selector(sendTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Aladin", style: .done, target: self, action: #selector(sendTapped))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        navigationController?.navigationBar.passthroughFrame = CGRect(x: (view.frame.width - 152) * 0.5, y: 0, width: 152, height: 44)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shouldPassthroughTouch = true
        navigationController?.navigationBar.isEnabledPassthroughSubviews = true

        segmentedControl.frame.origin = CGPoint(x: 0, y: navigationController?.navigationBar.frame.origin.y ?? 0)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true



        tableView.contentInset = UIEdgeInsetsMake(-(navigationController?.navigationBar.frame.height ?? 0) + segmentedControl.frame.height, 0, 0, 0)
//        setupNavigationTitleView(state: self.stateTitleView)

//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.isTranslucent = true
//
//        setupSmallNavigationBar()
    }

    func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//            refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    @objc func sendTapped() {
        stateTitleView = stateTitleView == .assets ? .title : .assets
//        setupNavigationTitleView(state: self.stateTitleView)
    }


    func updateTitleView() {
    }
}

extension AssetViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)

        guard let originTitleFrame = self.originTitleFrame else { return }

        let yContent = scrollView.contentOffset.y
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
//    func updateTableWithNewPage(_ newPage: Int) {
//
//        if newPage == currentPage {
//            return
//        }
//
//        let sections = [0, 1, 2, 3]
//        if newPage > currentPage {
//            tableView.reloadSections(sections, animationStyle: .left)
//        }
//        else {
//            tableView.reloadSections(sections, animationStyle: .right)
//        }
//
//        currentPage = newPage
//
//        labelTitle.text = headerItems[currentPage]
//        labelToken.text = headerItems[currentPage] + " token"
//
//        if currentPage == 2 {
//            viewSpam.isHidden = false
//            labelToken.isHidden = true
//        }
//        else {
//            viewSpam.isHidden = true
//            labelToken.isHidden = false
//        }
//    }
//
// MARK: - UICollectionView

//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == collectionView {
//            let newPage = Int(floor((scrollView.contentOffset.x - collectionPageSize.width / 2) / collectionPageSize.width) + 1)
//            updateTableWithNewPage(newPage)
//        }
//        else {
//            updateTopBarOffset()
//        }
//    }

// MARK: - UITableView

extension AssetViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    var maxScrollOffset: CGFloat {
        return 64
    }

    func updateTopBarOffset() {
//        let offset = abs(topViewOffset.constant)
//
//        if offset < maxScrollOffset / 2 && offset > 0 {
//            self.topViewOffset.constant = 0
//
//            UIView.animate(withDuration: 0.3, animations: {
//                self.collectionView.alpha = 1
//                self.labelToken.alpha = 1
//                self.view.layoutIfNeeded()
//            }) { (complete) in
//                self.viewSeparator.isHidden = true
//            }
//        }
//        else if offset < maxScrollOffset && offset > 0 {
//            self.topViewOffset.constant = -maxScrollOffset
//
//            UIView.animate(withDuration: 0.3, animations: {
//                self.collectionView.alpha = 0
//                self.labelToken.alpha = 0
//                self.view.layoutIfNeeded()
//            }) { (complete) in
//                self.viewSeparator.isHidden = false
//            }
//        }
    }

//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//
//        if scrollView == tableView {
//           updateTopBarOffset()
//        }
//    }

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
