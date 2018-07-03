//
//  ChooseAssetViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ChooseAssetCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var iconAsset: UIImageView!
    @IBOutlet weak var iconArrow: UIImageView!
    @IBOutlet weak var iconCheckmark: UIImageView!
    @IBOutlet weak var labelCryptoName: UILabel!
    @IBOutlet weak var iconFav: UIImageView!
}


protocol ChooseAssetViewControllerDelegate: class {

    func chooseAssetViewControllerDidSelectAsset( _ asset: String)
}

class ChooseAssetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var delegate: ChooseAssetViewControllerDelegate?
    
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var assets = ["Waves", "Bitcoin", "ETH", "Dash", "USD", "EUR", "Lira", "Bitcoin Cash", "EOS", "Cardano", "Stellar", "Litecoin", "NEO", "TRON", "Monero", "ZCash"]

    var searchAssets: [String] = []
    
    var selectedAsset = ""
    var isSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func searchChange(_ sender: Any) {
    
        isSearchMode = textFieldSearch.text!.count > 0
        searchAssets.removeAll()
        
        if isSearchMode {
            for value in assets {
                if (value.lowercased() as NSString).range(of: textFieldSearch.text!.lowercased()).location != NSNotFound {
                    searchAssets.append(value)
                }
            }
        }
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - UITableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAsset = isSearchMode ? searchAssets[indexPath.row] : assets[indexPath.row]
        delegate?.chooseAssetViewControllerDidSelectAsset(selectedAsset)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? searchAssets.count : assets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAssetCell") as! ChooseAssetCell
        
        let title = isSearchMode ? searchAssets[indexPath.row] : assets[indexPath.row]
        cell.labelTitle.text = title
        
        if selectedAsset == title {
            cell.iconCheckmark.image = UIImage(named: "on")
        }
        else {
            cell.iconCheckmark.image = UIImage(named: "off")
        }
        
        let iconName = DataManager.logoForCryptoCurrency(title)
        if iconName.count == 0 {
            cell.labelCryptoName.text = String(title.first!).uppercased()
            cell.iconAsset.image = nil
            cell.iconAsset.backgroundColor = DataManager.bgColorForCryptoCurrency(title)
        }
        else {
            cell.labelCryptoName.text = nil
            cell.iconAsset.image = UIImage(named: iconName)
        }
        return cell
    }
}
