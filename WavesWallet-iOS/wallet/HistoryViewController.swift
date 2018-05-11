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
    
    let allItems = [["title" : "February 12, 2018", "items" : [10.23, 2, 23.23, 31.32, 3213.43, 434.34, 55.5]],
                     ["title" : "February 15, 2018", "items" : [0.23, 4, 13.3, 1.32, 0.43]],
                     ["title" : "February 17, 2018", "items" : [1.2, 2.2, 2.3, 3.3, 1.3, 14.44, 10.5]],
                     ["title" : "February 20, 2018", "items" : [31.32, 3213.43, 434.34, 55.5]]]

    let sentItems = [["title" : "February 14, 2018", "items" : [1.32, 0.43]],
                     ["title" : "February 16, 2018", "items" : [23.23, 31.32, 3213.43, 434.34, 10.23]]]

    let receivedItems = [["title" : "February 10, 2018", "items" : [2.3, 3.3, 1.3, 14.44, 10.5]],
                         ["title" : "February 12, 2018", "items" : [10.23, 2]],
                         ["title" : "February 16, 2018", "items" : [13.3, 1.32, 0.43]]]

    let exchangeItems = [["title" : "February 10, 2018", "items" : [3.3]],
                         ["title" : "February 16, 2018", "items" : [1.32, 0.43]]]
    
    let leasedItems = [["title" : "February 10, 2018", "items" : [4, 13.3]],
                         ["title" : "February 16, 2018", "items" : [10.23, 2, 23.23, 31.32, 3213.43, 434.34, 55.5]],
                         ["title" : "February 18, 2018", "items" : [4, 13.3, 1.32, 0.43]]]
    
    let issuedItems = [["title" : "February 10, 2018", "items" : [0.43]]]
    
    let activeNowItems = [["title" : "February 14, 2018", "items" : [1.32, 0.43]],
                          ["title" : "February 16, 2018", "items" : [23.23, 31.32, 3213.43, 434.34, 10.23]]]

    let canceledItems = [["title" : "February 10, 2018", "items" : [4, 13.3]],
                         ["title" : "February 16, 2018", "items" : [10.23, 2, 23.23, 31.32, 3213.43, 434.34, 55.5]],
                         ["title" : "February 18, 2018", "items" : [4, 13.3, 1.32, 0.43]]]

    
    var isLeasingMode = false
    
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
    }

    func beginRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
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
    
    func itemForSection(_ section: Int) -> [String : Any] {
       
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
        tableView.insertSections(insertSections, animationStyle: animationStyle)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        setupTopBarLine(tableContentOffsetY: tableView.contentOffset.y)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
    
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
        
        let item = itemForSection(indexPath.section)
        let items = item["items"] as! [Any]
        let value = items[indexPath.row]
        if let val = value as? Double {
            cell.setupCell(value: String(val))
        }
        else if let val = value as? Int {
            cell.setupCell(value: String(val))
        }
        return cell
    }
}
