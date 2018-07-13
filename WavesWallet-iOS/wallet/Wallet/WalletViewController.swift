//
//  WalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RESideMenu

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WalletTopTableCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    enum SectionAssets: Int {
        case main = 1
        case hidden
        case spam
    }
    
    enum SectionLeasing: Int {
        case balance = 1
        case active
        case quickNote
    }
    
    var SectionTop = 0
    
    enum WalletSelectedIndex {
        case assets
        case leasing
    }
    
    var selectedSegmentIndex = WalletSelectedIndex.assets

    var isOpenSpamAssets = false
    var isOpenHiddenAssets = false
    var isOpenActiveLeasing = true
    var isOpenQuickNote = false
    var isAvailableLeasingHistory = true
    
    var hasFirstChangeSegment = false
    
    var lastScrollCorrectOffset: CGPoint?

    var assetsMainItems = ["Waves", "Bitcoin", "ETH", "Dash", "USD", "EUR", "Lira"]
    var assetsHiddenItems = ["Bitcoin Cash", "EOS", "Cardano", "Stellar", "Litecoin", "NEO", "TRON", "Monero", "ZCash"]
    var assetsSpamItems = ["ETH", "Monero"]
    
    var leasingActiveItems = ["10", "0000.0000", "123.31", "3141.43141", "000.314314", "314.3414", "231", "31414.4314", "0", "00.4314"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wallet"
        navigationController?.navigationBar.barTintColor = UIColor.basic50
        
        createMenuButton()
        setupRightButons()

        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
        else {
            tableView.addSubview(refreshControl)
        }
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0)
        tableView.register(UINib(nibName: WalletHeaderView.identifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: WalletHeaderView.identifier())
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        tableView.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeLeft.direction = .left
        tableView.addGestureRecognizer(swipeLeft)
    }
    
    func setupRightButons() {
        if selectedSegmentIndex == .assets {
            let btnScan = UIBarButtonItem(image: UIImage(named: "wallet_scanner"), style: .plain, target: self, action: #selector(scanTapped))
            let btnSort = UIBarButtonItem(image: UIImage(named: "wallet_sort"), style: .plain, target: self, action: #selector(sortTapped))
            navigationItem.rightBarButtonItems = [btnScan, btnSort]
        }
        else {
            let btnScan = UIBarButtonItem(image: UIImage(named: "wallet_scanner"), style: .plain, target: self, action: #selector(scanTapped))
            navigationItem.rightBarButtonItems = [btnScan]
        }
    }
    
    @objc func handleGesture(_ gesture: UISwipeGestureRecognizer) {
       
        if gesture.direction == .left {
            if selectedSegmentIndex == .assets {
                
                setupTableSections(.leasing)

                if !hasFirstChangeSegment {
                    hasFirstChangeSegment = true
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }

                if let topHeaderCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? WalletTopTableCell {
                    topHeaderCell.setupState(.leasing, animation: true)
                }
            }
        }
        else if gesture.direction == .right {
            if selectedSegmentIndex == .leasing {
                setupTableSections(.assets)

                if let topHeaderCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? WalletTopTableCell {
                    topHeaderCell.setupState(.assets, animation: true)
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTopBarLine()

        
        setupBigNavigationBar()
        navigationController?.setNavigationBarHidden(false, animated: true)

        if rdv_tabBarController.isTabBarHidden {
            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lastScrollCorrectOffset = nil
    }

    @objc func beginRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func setupLastScrollCorrectOffset() {
        lastScrollCorrectOffset = tableView.contentOffset
    }
    
    @objc func startLeasing() {
        setupLastScrollCorrectOffset()
        let sort = storyboard?.instantiateViewController(withIdentifier: "StartLeasingViewController") as! StartLeasingViewController
        navigationController?.pushViewController(sort, animated: true)
        
        rdv_tabBarController.setTabBarHidden(true, animated: true)
    }
    
    @objc func scanTapped() {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "MyAddressViewController") as! MyAddressViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func sortTapped() {

        setupLastScrollCorrectOffset()
        let sort = storyboard?.instantiateViewController(withIdentifier: "WalletSortViewController") as! WalletSortViewController
        navigationController?.pushViewController(sort, animated: true)
    
        rdv_tabBarController.setTabBarHidden(true, animated: true)
    }
  
    @objc func headerTapped(_ sender: UIButton) {
        
        let section = sender.tag
        
        if selectedSegmentIndex == .assets {
            
            if section == SectionAssets.hidden.rawValue {
                if assetsHiddenItems.count == 0 {
                    return
                }
                
                isOpenHiddenAssets = !isOpenHiddenAssets
                
                tableView.beginUpdates()
                tableView.reloadSections([section], animationStyle: .fade)
                tableView.endUpdates()
                
                if isOpenHiddenAssets {
                    tableView.scrollToRow(at: IndexPath(row: 0, section:  section), at: .top, animated: true)
                }
                
                if let view = tableView.headerView(forSection: section) as? WalletHeaderView {
                    view.setupArrow(isOpenHideenAsset: isOpenHiddenAssets, animation: true)
                }
            }
            else if section == SectionAssets.spam.rawValue {
                if assetsSpamItems.count == 0 {
                    return
                }
                
                isOpenSpamAssets = !isOpenSpamAssets
                
                tableView.beginUpdates()
                tableView.reloadSections([section], animationStyle: .fade)
                tableView.endUpdates()
                
                if isOpenSpamAssets {
                    tableView.scrollToRow(at: IndexPath(row: 0, section:  section), at: .top, animated: true)
                }
                
                if let view = tableView.headerView(forSection: section) as? WalletHeaderView {
                    view.setupArrow(isOpenHideenAsset: isOpenSpamAssets, animation: true)
                }
            }

        }
        else {
            if section == SectionLeasing.active.rawValue {
                if leasingActiveItems.count == 0 {
                    return
                }
                
                isOpenActiveLeasing = !isOpenActiveLeasing

                tableView.beginUpdates()
                tableView.reloadSections([section], animationStyle: .fade)
                tableView.endUpdates()
                
                if isOpenActiveLeasing {
                    tableView.scrollToRow(at: IndexPath(row: 0, section:  section), at: .top, animated: true)
                }
                            
                if let view = tableView.headerView(forSection: section) as? WalletHeaderView {
                    view.setupArrow(isOpenHideenAsset: isOpenActiveLeasing, animation: true)
                }
            }
            else if section == SectionLeasing.quickNote.rawValue {
                isOpenQuickNote = !isOpenQuickNote
                
                tableView.beginUpdates()
                tableView.reloadSections([section], animationStyle: .fade)
                tableView.endUpdates()
                
                if isOpenQuickNote {
                    tableView.scrollToRow(at: IndexPath(row: 0, section:  section), at: .top, animated: true)
                }

                if let view = tableView.headerView(forSection: section) as? WalletHeaderView {
                    view.setupArrow(isOpenHideenAsset: isOpenQuickNote, animation: true)
                }
            }
            
        }
    }
    
    //MARK: - WalletTopTableCellDelegate
    
    func setupTableSections(_ segmentIndex: WalletSelectedIndex) {
        
        selectedSegmentIndex = segmentIndex
        setupRightButons()
        
        tableView.beginUpdates()
        if selectedSegmentIndex == .leasing {
            tableView.reloadSections([1], animationStyle: .fade)
            tableView.reloadSections([2, 3], animationStyle: .fade)
        }
        else {
            tableView.reloadSections([1], animationStyle: .fade)
            tableView.reloadSections([2, 3], animationStyle: .fade)
            
        }
        tableView.endUpdates()
    }
    
    func walletTopTableCellDidChangeIndex(_ index: WalletSelectedIndex) {
        
        hasFirstChangeSegment = true
        setupTableSections(index)
    }
    
    //MARK: - UITableView

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if selectedSegmentIndex == .assets {
            
            setupLastScrollCorrectOffset()
            let assetController = storyboard?.instantiateViewController(withIdentifier: "AssetViewController") as! AssetViewController
            navigationController?.pushViewController(assetController, animated: true)
            rdv_tabBarController.setTabBarHidden(true, animated: true)
        }
        else {
            if indexPath.section == SectionLeasing.balance.rawValue {
                if indexPath.row == 1 {
                    
                    setupLastScrollCorrectOffset()
                    let history = storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
                    history.isLeasingMode = true
                    navigationController?.pushViewController(history, animated: true)
                    rdv_tabBarController.setTabBarHidden(true, animated: true)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if let offset = lastScrollCorrectOffset, Platform.isIphoneX {
            scrollView.contentOffset = offset // to fix top bar offset in iPhoneX when tabBarHidden = true
        }
        
        setupTopBarLine()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        if selectedSegmentIndex == .leasing {
            return 4
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        if selectedSegmentIndex == .assets {
            if section == SectionAssets.hidden.rawValue {
                return assetsHiddenItems.count > 0 ? WalletHeaderView.viewHeight() : 0
            }
            else if section == SectionAssets.spam.rawValue {
                return assetsSpamItems.count > 0 ? WalletHeaderView.viewHeight() : 0
            }
        }
        else {
            if section == SectionLeasing.active.rawValue || section == SectionLeasing.quickNote.rawValue {
                return WalletHeaderView.viewHeight()
            }
        }
        return 0
    }
    
    func getHeader(_ section: Int) -> WalletHeaderView {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: WalletHeaderView.identifier()) as! WalletHeaderView
        view.buttonTap.addTarget(self, action: #selector(headerTapped(_:)), for: .touchUpInside)
        view.buttonTap.tag = section
        
        if selectedSegmentIndex == .assets {
            if section == SectionAssets.hidden.rawValue {
                view.labelTitle.text = "Hidden assets (\(assetsHiddenItems.count))"
                view.setupArrow(isOpenHideenAsset: isOpenHiddenAssets, animation: false)
            }
            else if section == SectionAssets.spam.rawValue {
                view.labelTitle.text = "Spam assets (\(assetsSpamItems.count))"
                view.setupArrow(isOpenHideenAsset: isOpenSpamAssets, animation: false)
            }
        }
        else {
            if section == SectionLeasing.active.rawValue {
                view.labelTitle.text = "Active now (\(leasingActiveItems.count))"
                view.setupArrow(isOpenHideenAsset: isOpenActiveLeasing, animation: false)
            }
            else if section == SectionLeasing.quickNote.rawValue {
                view.labelTitle.text = "Quick note"
                view.setupArrow(isOpenHideenAsset: isOpenQuickNote, animation: false)
            }
        }
        return view
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        if selectedSegmentIndex == .assets {
            if section == SectionAssets.hidden.rawValue {
                return getHeader(section)
            }
            else if section == SectionAssets.spam.rawValue {
                return getHeader(section)
            }
        }
        
        if section == SectionLeasing.active.rawValue || section == SectionLeasing.quickNote.rawValue {
            return getHeader(section)
        }
        return nil
    }
    
    func cellHeight(_ indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SectionTop {
            return WalletTopTableCell.cellHeight()
        }
        
        if selectedSegmentIndex == .assets {
            if indexPath.section == SectionAssets.main.rawValue {
                if indexPath.row == assetsMainItems.count - 1 {
                    return WalletTableAssetsCell.cellHeight() + 10
                }
            }
            else if indexPath.section == SectionAssets.hidden.rawValue {
                if indexPath.row == assetsHiddenItems.count - 1 {
                    return WalletTableAssetsCell.cellHeight() + 10
                }
            }
            return WalletTableAssetsCell.cellHeight()
        }
        
        if indexPath.section == SectionLeasing.balance.rawValue {
            if indexPath.row == 0 {
                return WalletLeasingBalanceCell.cellHeight(isAvailableLeasingHistory: isAvailableLeasingHistory)
            }
            else if indexPath.row == 1 {
                return WalletHistoryCell.cellHeight()
            }
        }
        else if indexPath.section == SectionLeasing.active.rawValue {
            if indexPath.row == leasingActiveItems.count - 1 {
                return WalletLeasingCell.cellHeight() + 10
            }
            return WalletLeasingCell.cellHeight()
        }
        else if indexPath.section == SectionLeasing.quickNote.rawValue {
            return WalletQuickNoteCell.cellHeight()
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight(indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if section == SectionTop {
            return 1
        }
        
        if selectedSegmentIndex == .assets {
            if section == SectionAssets.main.rawValue {
                return assetsMainItems.count
            }
            else if section == SectionAssets.hidden.rawValue {
                return isOpenHiddenAssets ? assetsHiddenItems.count : 0
            }
            else if section == SectionAssets.spam.rawValue {
                return isOpenSpamAssets ? assetsSpamItems.count : 0
            }
        }
        
        if section == SectionLeasing.balance.rawValue {
            return isAvailableLeasingHistory ? 2 : 1
        }
        else if section == SectionLeasing.active.rawValue {
            return isOpenActiveLeasing ? leasingActiveItems.count : 0
        }
        else if section == SectionLeasing.quickNote.rawValue {
            return isOpenQuickNote ? 1 : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == SectionTop {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTopTableCell") as! WalletTopTableCell
            cell.delegate = self
            cell.setupState(selectedSegmentIndex, animation: false)
            return cell
        }
        
        if selectedSegmentIndex == .leasing {
            if indexPath.section == SectionLeasing.balance.rawValue {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "WalletLeasingBalanceCell") as! WalletLeasingBalanceCell
                    cell.setupCell(isAvailableLeasingHistory: isAvailableLeasingHistory)
                    cell.buttonStartLease.addTarget(self, action: #selector(startLeasing), for: .touchUpInside)
                    return cell
                }
                else if indexPath.row == 1 {
                    var cell : WalletHistoryCell! = tableView.dequeueReusableCell(withIdentifier: "WalletHistoryCell") as? WalletHistoryCell
                    if cell == nil {
                        cell = WalletHistoryCell.loadView() as? WalletHistoryCell
                    }
                    return cell
                }
            }
            else if indexPath.section == SectionLeasing.active.rawValue {
                
                var cell : WalletLeasingCell! = tableView.dequeueReusableCell(withIdentifier: "WalletLeasingCell") as? WalletLeasingCell
                if cell == nil {
                    cell = WalletLeasingCell.loadView() as? WalletLeasingCell
                }
                cell.setupCell(leasingActiveItems[indexPath.row])
                return cell
            }
            else if indexPath.section == SectionLeasing.quickNote.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WalletQuickNoteCell") as! WalletQuickNoteCell
                return cell
            }
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableAssetsCell") as! WalletTableAssetsCell
        cell.viewAssetType.isHidden = false
        cell.viewSpam.isHidden = true
        if indexPath.section == SectionAssets.main.rawValue {
            cell.setupCell(value: assetsMainItems[indexPath.row])
        }
        else if indexPath.section == SectionAssets.hidden.rawValue {
            cell.setupCell(value: assetsHiddenItems[indexPath.row])
        }
        else if indexPath.section == SectionAssets.spam.rawValue {
            cell.viewSpam.isHidden = false
            cell.viewAssetType.isHidden = true
            cell.setupCell(value: assetsSpamItems[indexPath.row])
        }
        
        return cell
    }

}
