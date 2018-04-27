//
//  WalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletTopTableCell: UITableViewCell {
    
    
    @IBOutlet weak var buttonAssets: UIButton!
    @IBOutlet weak var buttonLeasing: UIButton!
    
    class func cellHeight() -> CGFloat {
        return 60
    }
    
    func setupCell(isSelectedAssets: Bool) {
                

        if isSelectedAssets {
            buttonAssets.backgroundColor = UIColor.submit400
            buttonAssets.setTitleColor(UIColor.white, for: .normal)
            buttonLeasing.backgroundColor = UIColor.clear
            buttonLeasing.setTitleColor(UIColor.basic500, for: .normal)
        }
        else {
            buttonAssets.backgroundColor = UIColor.clear
            buttonAssets.setTitleColor(UIColor.basic500, for: .normal)
            buttonLeasing.backgroundColor = UIColor.submit400
            buttonLeasing.setTitleColor(UIColor.white, for: .normal)
        }
    }
}

class WalletTableCell: UITableViewCell {
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var iconArrow: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
    }
    
    class func cellHeight() -> CGFloat {
        return 76
    }
}

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    enum Section: Int {
        case top = 0
        case main
        case hidden
    }
    
    var isSelectedAssets = true
    var isOpenHiddenAssets = false
    
    var lastScrollCorrectOffset: CGPoint?
    
    var mainItems = ["Waves", "Bitcoin", "ETH"]

//    var mainItems = ["Waves", "Bitcoin", "ETH", "ETH Classic", "Ripple"]
    var hiddenItems = ["Bitcoin Cash", "EOS", "Cardano", "Stellar", "Litecoin", "NEO", "TRON", "Monero", "ZCash"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wallet"
        navigationController?.navigationBar.barTintColor = UIColor.basic50
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
        
        
        let btnScan = UIBarButtonItem(image: UIImage(named: "wallet_scanner"), style: .plain, target: self, action: #selector(scanTapped))
        let btnSort = UIBarButtonItem(image: UIImage(named: "wallet_sort"), style: .plain, target: self, action: #selector(sortTapped))
        navigationItem.rightBarButtonItems = [btnScan, btnSort]
        
        let btnMenu = UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .done, target: self, action: #selector(menuTapped))
        navigationItem.leftBarButtonItem = btnMenu

        if #available(iOS 11.0, *) {
            refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            refreshControl.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0)
        tableView.register(UINib(nibName: WalletHeaderView.identifier(), bundle: nil), forHeaderFooterViewReuseIdentifier: WalletHeaderView.identifier())
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupTopBarLine(tableContentOffsetY: tableView.contentOffset.y)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lastScrollCorrectOffset = nil
    }

    func beginRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func menuTapped() {
        
    }
    
    func scanTapped() {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "MyAddressViewController") as! MyAddressViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func sortTapped() {

        lastScrollCorrectOffset = tableView.contentOffset
        let sort = storyboard?.instantiateViewController(withIdentifier: "WalletSortViewController") as! WalletSortViewController
        navigationController?.pushViewController(sort, animated: true)
    
        rdv_tabBarController.setTabBarHidden(true, animated: true)
    }
  
    func headerTapped() {
        isOpenHiddenAssets = !isOpenHiddenAssets
        
        var indexPathes : [IndexPath] = []
        for i in 0..<hiddenItems.count {
            indexPathes.append(IndexPath(row: i, section: Section.hidden.rawValue))
        }

        if isOpenHiddenAssets {
            tableView.beginUpdates()
            tableView.insertRows(at: indexPathes, with: .fade)
            tableView.endUpdates()
            
            tableView.scrollToRow(at: IndexPath(row: 0, section:  Section.hidden.rawValue), at: .top, animated: true)
        }
        else {
            tableView.beginUpdates()
            tableView.deleteRows(at: indexPathes, with: .fade)
            tableView.endUpdates()
        }
        
        if let view = tableView.headerView(forSection: Section.hidden.rawValue) as? WalletHeaderView {
            view.setupArrow(isOpenHideenAsset: isOpenHiddenAssets, animation: true)
        }
    }
    
    func assetsTapped() {
        isSelectedAssets = true
        tableView.reloadData()
    }
    
    func leasingTapped() {
        isSelectedAssets = false
        tableView.reloadData()
    }
    
    //MARK: - UITableView

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if let offset = lastScrollCorrectOffset, Platform.isIphoneX {
            scrollView.contentOffset = offset // to fix top bar offset in iPhoneX when tabBarHidden = true
        }
        
        setupTopBarLine(tableContentOffsetY: tableView.contentOffset.y)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == Section.hidden.rawValue {
            return 34
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == Section.hidden.rawValue {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: WalletHeaderView.identifier()) as! WalletHeaderView
            view.buttonTap.addTarget(self, action: #selector(headerTapped), for: .touchUpInside)
            view.labelTitle.text = "Hidden assets (\(hiddenItems.count))"
            view.setupArrow(isOpenHideenAsset: isOpenHiddenAssets, animation: false)
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.top.rawValue {
            return WalletTopTableCell.cellHeight()
        }
        else if indexPath.section == Section.main.rawValue {
            if indexPath.row == mainItems.count - 1 {
                return WalletTableCell.cellHeight() + 10
            }
            return WalletTableCell.cellHeight()
        }
        return WalletTableCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Section.top.rawValue {
            return 1
        }
        else if section == Section.main.rawValue {
            return mainItems.count
        }
        
        return isOpenHiddenAssets ? hiddenItems.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == Section.top.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTopTableCell") as! WalletTopTableCell
            cell.buttonAssets.addTarget(self, action: #selector(assetsTapped), for: .touchUpInside)
            cell.buttonLeasing.addTarget(self, action: #selector(leasingTapped), for: .touchUpInside)
            cell.setupCell(isSelectedAssets: isSelectedAssets)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableCell") as! WalletTableCell
        
        let text = "000.0000000"
        
        let range = (text as NSString).range(of: ".")
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: cell.labelSubtitle.font.pointSize, weight: UIFontWeightSemibold)], range: NSRange(location: 0, length: range.location))
        
        cell.labelSubtitle.attributedText = attrString
        
        if indexPath.section == Section.main.rawValue {
            cell.labelTitle.text = mainItems[indexPath.row]
        }
        else {
            cell.labelTitle.text = hiddenItems[indexPath.row]
        }
        
        return cell
    }

}
