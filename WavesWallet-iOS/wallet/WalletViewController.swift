//
//  WalletViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletHeaderView: UITableViewHeaderFooterView {
    
    override var reuseIdentifier: String? {
        return "WalletHeaderView"
    }
}

class WalletTopTableCell: UITableViewCell {
    
    
    @IBOutlet weak var buttonAssets: UIButton!
    @IBOutlet weak var buttonLeasing: UIButton!
    
    class func cellHeight() -> CGFloat {
        return 60
    }
    
    func setupCell(isSelectedAssets: Bool) {
        
        let blueColor = UIColor(31, 90, 246)
        let textLightColor = UIColor(155, 166, 178)
        if isSelectedAssets {
            buttonAssets.backgroundColor = blueColor
            buttonAssets.setTitleColor(UIColor.white, for: .normal)
            buttonLeasing.backgroundColor = UIColor.clear
            buttonLeasing.setTitleColor(textLightColor, for: .normal)
        }
        else {
            buttonAssets.backgroundColor = UIColor.clear
            buttonAssets.setTitleColor(textLightColor, for: .normal)
            buttonLeasing.backgroundColor = blueColor
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
        viewContent.layer.shadowColor = UIColor.black.cgColor
        viewContent.layer.shadowOffset = CGSize(width: 0, height: 1)
        viewContent.layer.shadowRadius = 1
        viewContent.layer.shadowOpacity = 0.15
        viewContent.layer.cornerRadius = 3
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wallet"
        navigationController?.navigationBar.barTintColor = UIColor(248, 249, 251)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false

            navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .never
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
        
        tableView.register(WalletHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "WalletHeaderView")
    }

    func beginRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func menuTapped() {
        
    }
    
    func scanTapped() {
        
    }
    
    func sortTapped() {
        
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "WalletHeaderView")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.top.rawValue {
            return WalletTopTableCell.cellHeight()
        }
        else if indexPath.section == Section.main.rawValue {
            return WalletTableCell.cellHeight()
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Section.top.rawValue {
            return 1
        }
        else if section == Section.main.rawValue {
            return 10
        }
        return 0
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
        return cell
    }

}
