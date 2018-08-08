//
//  AssetViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout


//, UITableViewDelegate, UITableViewDataSource
class AssetViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var buttonFavourite: UIButton!
    @IBOutlet weak var topViewOffset: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelToken: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewSpam: UIView!
    
    var currentPage: Int = 0
    
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
    
    var refreshControl: UIRefreshControl!

    var selectedChartPediod = ChartPeriod.day
    let isAvailableChart = true
    let lastTransctions: [String] = ["WAVES", "USD", "Bitcoin", "ETH"]

    var inFavourite = false
    
    let headerItems = ["Waves", "ETH", "Bitcoin", "Eth Classic"]
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
////        if #available(iOS 10.0, *) {
////            refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
////            refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
////            tableView.refreshControl = refreshControl
////        }
////        else {
////            tableView.addSubview(refreshControl)
////        }
////
//////        tableView.register(UINib(nibName: WalletHeaderView.identifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: WalletHeaderView.identifier())
////        tableView.register(UINib(nibName: AssetChartHeaderView.identifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: AssetChartHeaderView.identifier())
////
////        buttonFavourite.setImage(UIImage(named: inFavourite ? "topbarFavoriteOn" : "topbarFavoriteOff"), for: .normal)
////
////        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
////        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 24)
////        labelTitle.text = headerItems[currentPage]
////        labelToken.text = headerItems[currentPage] + " token"
////        viewSpam.isHidden = true
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(true, animated: true)
//        setupSmallNavigationBar()
//    }
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
    //MARK: - UICollectionView
    
//    fileprivate var collectionPageSize: CGSize {
//        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
//        var pageSize = layout.itemSize
//        if layout.scrollDirection == .horizontal {
//            pageSize.width += layout.minimumLineSpacing
//        } else {
//            pageSize.height += layout.minimumLineSpacing
//        }
//        return pageSize
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return headerItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionHeaderCell", for: indexPath) as! AssetCollectionHeaderCell
//
//        let value = headerItems[indexPath.row]
//
//        let iconName = DataManager.logoForCryptoCurrency(value)
//        if iconName.count == 0 {
//            cell.imageViewIcon.image = nil
//            cell.imageViewIcon.backgroundColor = DataManager.bgColorForCryptoCurrency(value)
//            cell.labelTitle.text = String(value.uppercased().first!)
//        }
//        else {
//            cell.labelTitle.text = nil
//            cell.imageViewIcon.image = UIImage(named: iconName)
//        }
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        if indexPath.row != currentPage {
//            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
//
//        updateTableWithNewPage(indexPath.row)
//    }
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

    //MARK: - UITableView
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == Section.lastTransactions.rawValue {
//            if indexPath.row == 1 {
//                let history = storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
//                navigationController?.pushViewController(history, animated: true)
//            }
//        }
//        else if indexPath.section == Section.chart.rawValue {
//            let chart = storyboard?.instantiateViewController(withIdentifier: "AssetChartViewController") as! AssetChartViewController
//            navigationController?.pushViewController(chart, animated: true)
//        }
//    }
//    var maxScrollOffset: CGFloat {
//        return 64
//    }
//
//    func updateTopBarOffset() {
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
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//
//        if scrollView == tableView {
//           updateTopBarOffset()
//        }
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if scrollView == tableView {
//            topViewOffset.constant += -scrollView.contentOffset.y
//
//            if topViewOffset.constant <= -maxScrollOffset {
//                topViewOffset.constant = -maxScrollOffset
//            }
//            else if topViewOffset.constant >= 0 {
//                topViewOffset.constant = 0
//            }
//            else {
//                scrollView.contentOffset.y = 0
//            }
//
//            viewSeparator.isHidden = abs(topViewOffset.constant) < maxScrollOffset
//
//            let alpha = 1 - (abs(topViewOffset.constant) / maxScrollOffset)
//            collectionView.alpha = alpha < 0 ? 0 : alpha
//            labelToken.alpha = alpha < 0 ? 0 : alpha
//            viewSpam.alpha = alpha < 0 ? 0 : alpha
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == Section.lastTransactions.rawValue{
//            return WalletHeaderView.viewHeight()
//        }
//        else if section == Section.chart.rawValue && isAvailableChart {
//            return AssetChartHeaderView.viewHeight()
//        }
//
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
//            view.labelTitle.text = "\(getChartPediodText()) status"
//            view.buttonChangePeriod.addTarget(self, action: #selector(changeChartPeriod), for: .touchUpInside)
//            return view
//        }
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
//
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
//        return 0
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 4
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if indexPath.section == Section.balance.rawValue {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "AssetBalanceCell") as! AssetBalanceCell
//            cell.buttonSend.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
//            cell.buttonReceive.addTarget(self, action: #selector(receiveTapped), for: .touchUpInside)
//            cell.buttonExchange.addTarget(self, action: #selector(exchangeTapped), for: .touchUpInside)
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
//
//        return UITableViewCell()
//    }
}
