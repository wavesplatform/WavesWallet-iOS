//
//  HistoryViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/10/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HistoryTopHeaderCellDelegate {

    enum HistoryState: Int {
        case all = 0
        case sent
        case received
        case exchaned
        case leased
        case issued
        case activeNow
        case canceled
    }
    
    var selectedState = HistoryState.all
    
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    
    var isMenuButton = false
    
    var allItems : [NSDictionary] = []
    var sentItems : [NSDictionary] = []
    var receivedItems : [NSDictionary] = []
    var exchangeItems : [NSDictionary] = []
    var leasedItems : [NSDictionary] = []
    var issuedItems : [NSDictionary] = []
    var activeNowItems : [NSDictionary] = []
    var canceledItems : [NSDictionary] = []
  
    var isLeasingMode = false
    
    var lastScrollCorrectOffset: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "History"
        
        setupBigNavigationBar()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if isMenuButton {
            createMenuButton()
        }
        else {
            createBackButton()
        }
        
        tableView.register(UINib(nibName: WalletHeaderView.identifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: WalletHeaderView.identifier())
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        tableView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeLeft.direction = .left
        tableView.addGestureRecognizer(swipeLeft)
        
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
        else {
            tableView.addSubview(refreshControl)
        }
        
        let path = Bundle.main.path(forResource: "HistoryInfo", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! NSDictionary
        
        allItems.append(contentsOf: jsonResult["allItems"] as! [NSDictionary])
        sentItems.append(contentsOf: jsonResult["sentItems"] as! [NSDictionary])
        receivedItems.append(contentsOf: jsonResult["receivedItems"] as! [NSDictionary])
        exchangeItems.append(contentsOf: jsonResult["exchangeItems"] as! [NSDictionary])
        leasedItems.append(contentsOf: jsonResult["leasedItems"] as! [NSDictionary])
        issuedItems.append(contentsOf: jsonResult["issuedItems"] as! [NSDictionary])
        activeNowItems.append(contentsOf: jsonResult["activeNowItems"] as! [NSDictionary])
        canceledItems.append(contentsOf: jsonResult["canceledItems"] as! [NSDictionary])
    }

    func beginRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lastScrollCorrectOffset = nil
    }
    
    func setupLastScrollCorrectOffset() {
        lastScrollCorrectOffset = tableView.contentOffset
    }
   
    func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        
        if tableView.contentOffset.y > -20 {
            return
        }
        
        if gesture.direction == .left {

            if isLeasingMode {
                if selectedState == .canceled {
                    return
                }
                
                var state : HistoryState!
                if selectedState == .all {
                    state = .activeNow
                }
                else if selectedState == .activeNow {
                    state = .canceled
                }
                
                let sections = getUpdateSection(state: state)
                selectedState = state
                
                updateTable(insertSections: sections.insertSections, deleteSections: sections.deleteSections, reloadSections: sections.reloadSections, animationStyle: .left)
                
                if let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HistoryLeasedTopHeaderCell {
                    headerCell.setupState(selectedState, animation: true)
                }
            }
            else {
                let index = selectedState.rawValue + 1
                if index <= HistoryState.issued.rawValue {
                    
                    let state = HistoryState(rawValue: index)!
                    let sections = getUpdateSection(state: state)
                    
                    selectedState = state

                    updateTable(insertSections: sections.insertSections, deleteSections: sections.deleteSections, reloadSections: sections.reloadSections, animationStyle: .left)
                    
                    if let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HistoryTopHeaderCell {
                        headerCell.setupState(selectedState, animation: true)
                    }
                }
            }
        }
        else if gesture.direction == .right {
            
            if isLeasingMode {
                
                if selectedState == .all {
                    return
                }
                
                var state : HistoryState!
                if selectedState == .canceled {
                    state = .activeNow
                }
                else if selectedState == .activeNow {
                    state = .all
                }
                
                let sections = getUpdateSection(state: state)
                selectedState = state
                
                updateTable(insertSections: sections.insertSections, deleteSections: sections.deleteSections, reloadSections: sections.reloadSections, animationStyle: .right)
                
                if let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HistoryLeasedTopHeaderCell {
                    headerCell.setupState(selectedState, animation: true)
                }
            }
            else {
                let index = selectedState.rawValue - 1
                if index >= 0 {
                    let state = HistoryState(rawValue: index)!
                    let sections = getUpdateSection(state: state)
                    
                    selectedState = state
                    
                    updateTable(insertSections: sections.insertSections, deleteSections: sections.deleteSections, reloadSections: sections.reloadSections, animationStyle: .right)
                    
                    if let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HistoryTopHeaderCell {
                        headerCell.setupState(selectedState, animation: true)
                    }
                }
            }
        }
        
    }
    
    func numberOfSections(state: HistoryState) -> Int {
        if state == .sent {
            return sentItems.count
        }
        else if state == .received {
            return receivedItems.count
        }
        else if state == .exchaned {
            return exchangeItems.count
        }
        else if state == .leased {
            return leasedItems.count
        }
        else if state == .issued {
            return issuedItems.count
        }
        else if state == .activeNow {
            return activeNowItems.count
        }
        else if state == .canceled {
            return canceledItems.count
        }
        return allItems.count
    }
    
    func itemForSection(_ section: Int) -> NSDictionary {
       
        if selectedState == .sent {
           return sentItems[section - 1]
        }
        else if selectedState == .received {
            return receivedItems[section - 1]
        }
        else if selectedState == .exchaned {
            return exchangeItems[section - 1]
        }
        else if selectedState == .leased {
            return leasedItems[section - 1]
        }
        else if selectedState == .issued {
            return issuedItems[section - 1]
        }
        else if selectedState == .activeNow {
            return activeNowItems[section - 1]
        }
        else if selectedState == .canceled {
            return canceledItems[section - 1]
        }
        
        return allItems[section - 1]
    }
    
    func getUpdateSection(state: HistoryState) -> (deleteSections: [Int], insertSections: [Int], reloadSections: [Int]) {
        
        let prevSectionCount = numberOfSections(state: selectedState)
        let newSectionCount = numberOfSections(state: state)
        
        var deleteSections : [Int] {
            var section : [Int] = []
            for i in stride(from: prevSectionCount, to: newSectionCount, by: -1) {
                section.append(i)
            }
            return section
        }
        
        var insertSections: [Int] {
            var section : [Int] = []
            for i in stride(from: newSectionCount, to: prevSectionCount, by: -1) {
                section.append(i)
            }
            return section
        }
        
        var reloadSections : [Int] {
            var sections : [Int] = []
            for i in stride(from: 0, to: newSectionCount - insertSections.count, by: 1) {
                sections.append(i + 1)
            }
            return sections
        }
        
        return (deleteSections, insertSections,reloadSections)
    }
    
    func updateTable(insertSections: [Int], deleteSections: [Int], reloadSections: [Int], animationStyle: UITableViewRowAnimation) {

        tableView.beginUpdates()
        let insertAnimation : UITableViewRowAnimation = animationStyle == .left ? .right : .left
        tableView.insertSections(insertSections, animationStyle: insertAnimation)
        tableView.deleteSections(deleteSections, animationStyle: animationStyle)
        tableView.reloadSections(reloadSections, animationStyle: animationStyle)
        tableView.endUpdates()

    }
    //MARK: - HistoryTopHeaderCellDelegate
    
    func historyTopHeaderCellDidSelectState(_ state: HistoryViewController.HistoryState, leftDirection: Bool) {
    
        let sections = getUpdateSection(state: state)
        
        selectedState = state
        
        let animationStyle = leftDirection ? UITableViewRowAnimation.right : UITableViewRowAnimation.left

        updateTable(insertSections: sections.insertSections, deleteSections: sections.deleteSections, reloadSections: sections.reloadSections, animationStyle: animationStyle)
    }
    
    
    //MARK: - UITableView
    
    func getAllItems() -> [NSDictionary] {
        var items : [NSDictionary] = []
        
        if selectedState == .sent {
            for item in sentItems {
                items.append(contentsOf: item["items"] as! [NSDictionary])
            }
        }
        else if selectedState == .received {
            for item in receivedItems {
                items.append(contentsOf: item["items"] as! [NSDictionary])
            }
        }
        else if selectedState == .exchaned {
            for item in exchangeItems {
                items.append(contentsOf: item["items"] as! [NSDictionary])
            }
        }
        else if selectedState == .leased {
            for item in leasedItems {
                items.append(contentsOf: item["items"] as! [NSDictionary])
            }
        }
        else if selectedState == .issued {
            for item in issuedItems {
                items.append(contentsOf: item["items"] as! [NSDictionary])
            }
        }
        else if selectedState == .activeNow {
            for item in activeNowItems {
                items.append(contentsOf: item["items"] as! [NSDictionary])
            }
        }
        else if selectedState == .canceled {
            for item in canceledItems {
                items.append(contentsOf: item["items"] as! [NSDictionary])
            }
        }
        else {
            for item in allItems {
                items.append(contentsOf: item["items"] as! [NSDictionary])
            }
        }
        
        return items
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let offset = lastScrollCorrectOffset, Platform.isIphoneX {
            scrollView.contentOffset = offset // to fix top bar offset in iPhoneX when tabBarHidden = true
        }
        
        setupTopBarLine()
    }
    
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
    
        let sectionItems = getAllItems()
        
        var index = 0
        let item = itemForSection(indexPath.section)
        let items = item["items"] as! [Any]
        let dict = items[indexPath.row] as! NSDictionary

        for (i, value) in sectionItems.enumerated() {
            if value == dict {
                index = i
                break
            }
        }
        
        let controller = StoryboardManager.TransactionsStoryboard().instantiateViewController(withIdentifier: "TransactionHistoryViewController") as! TransactionHistoryViewController
        controller.items = sectionItems
        controller.currentPage = index
        let popup = PopupViewController()
        popup.present(contentViewController: controller)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section > 0 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: WalletHeaderView.identifier()) as! WalletHeaderView
            view.iconArrow.isHidden = true
            let item = itemForSection(section)
            view.labelTitle.text = item["title"] as? String
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return WalletHeaderView.viewHeight()
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + numberOfSections(state: selectedState)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if indexPath.section == 0 {
            return HistoryTopHeaderCell.cellHeight()
        }

        let item = itemForSection(indexPath.section)
        if indexPath.row == (item["items"] as! [Any]).count - 1 {
            return HistoryAssetCell.cellHeight() + 10
        }
        return HistoryAssetCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        let item = itemForSection(section)
        return (item["items"] as! [Any]).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if isLeasingMode {
                var cell: HistoryLeasedTopHeaderCell! = tableView.dequeueReusableCell(withIdentifier: "HistoryLeasedTopHeaderCell") as? HistoryLeasedTopHeaderCell
                if cell == nil {
                    cell = HistoryLeasedTopHeaderCell.loadView() as? HistoryLeasedTopHeaderCell
                    cell.delegate = self
                }
                cell.setupState(selectedState, animation: false)
                return cell
            }
            
            var cell: HistoryTopHeaderCell! = tableView.dequeueReusableCell(withIdentifier: "HistoryTopHeaderCell") as? HistoryTopHeaderCell
            if cell == nil {
                cell = HistoryTopHeaderCell.loadView() as? HistoryTopHeaderCell
                cell.delegate = self
            }
            cell.setupState(selectedState, animation: false)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryAssetCell") as! HistoryAssetCell
        cell.viewAssetType.isHidden = false
        cell.viewSpam.isHidden = true
        
        if indexPath.row % 4 == 0 {
            cell.viewAssetType.isHidden = true
            cell.viewSpam.isHidden = false
        }
        let item = itemForSection(indexPath.section)
        let items = item["items"] as! [Any]
        let dict: NSDictionary = items[indexPath.row] as! NSDictionary
        let value = dict["value"]
        let state = HistoryTransactionState(rawValue: dict["state"] as! Int)!
        if let val = value as? Double {
            cell.setupCell(value: String(val), state: state)
        }
        else if let val = value as? Int {
            cell.setupCell(value: String(val), state: state)
        }
        return cell
    }
}
