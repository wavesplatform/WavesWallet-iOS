//
//  DexSearchViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10.08.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class DexSearchCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imageViewCheckmark: UIImageView!

    @IBOutlet weak var labelTitleLong: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewIcon1: UIImageView!
    
    @IBOutlet weak var labelAmountAsset: UILabel!
    @IBOutlet weak var labelPriceAsset: UILabel!
    @IBOutlet weak var detailsView: UIStackView!
    @IBOutlet weak var hideButton: UIButton!

    func setupCell(_ item: NSDictionary, indexPath: IndexPath, isDetailsHidden: Bool) {
        self.hideButton.tag = indexPath.row
        
        labelTitle.text = DataManager.shared.getTickersTitle(item: item)
        labelTitleLong.text = "\(item["amountAssetName"]!) / \(item["priceAssetName"]!)"
        
        if DataManager.shared.isVerified(asset: item["amountAsset"]! as! String)
            && DataManager.shared.isVerified(asset: item["priceAsset"]! as! String) {
            imageViewIcon1.image = #imageLiteral(resourceName: "verified")
        } else {
            imageViewIcon1.image = nil
        }
        
        labelAmountAsset.text = item["amountAsset"] as? String
        labelPriceAsset.text = item["priceAsset"] as? String

        
        if DataManager.hasPair(item) {
            imageViewCheckmark.image = #imageLiteral(resourceName: "pair-selected")
        }
        else {
            imageViewCheckmark.image = #imageLiteral(resourceName: "pair-not-selected")
        }
        
        detailsView.isHidden = isDetailsHidden
        hideButton.setImage(isDetailsHidden ? #imageLiteral(resourceName: "down-chevron") : #imageLiteral(resourceName: "up-chevron@"), for: .normal)
        imageViewCheckmark.alpha = DataManager.isWavesWbtcPair(item) ? 0.6 : 1
    }

}

class DexSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var textFieldSearch : CustomUITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchItems = [NSDictionary]()
    
    var isLoading = false
    var isSearchMode: Bool = false
    
    var verifiedItems = [NSDictionary]()
    var detailsShown = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        setupTableView()
        
        textFieldSearch = CustomUITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        textFieldSearch.backgroundColor = AppColors.darkPrimaryColor
        textFieldSearch.leftView = UIImageView(image: #imageLiteral(resourceName: "search"))
        textFieldSearch.leftViewMode = .always
        textFieldSearch.leftPadding = 10.0
        textFieldSearch.clearButtonMode = .always
        textFieldSearch.borderStyle = .roundedRect
        textFieldSearch.textColor = UIColor.white
        
        textFieldSearch.delegate = self
        textFieldSearch.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textFieldSearch.autocorrectionType = .no
        textFieldSearch.returnKeyType = .done
        navigationItem.titleView = textFieldSearch
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"icon_action"), style: .plain, target: self, action: #selector(actionTapped))
        
        isLoading = true
        self.activityIndicator.startAnimating()
        
        DataManager.withLoadedVerifiedAssets { (assets, errorMessage) in
            if errorMessage != nil {
                self.isLoading = false
                self.activityIndicator.stopAnimating()
                 self.presentBasicAlertWithTitle(title: errorMessage!)
            } else {
                self.loadInfo()
            }
            
        }
    }

    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 106
    }

    override func viewWillDisappear(_ animated: Bool) {
        textFieldSearch.resignFirstResponder()
    }
    
    func loadInfo() {
        isLoading = true
        NetworkManager.getAllOrderBooks { (items, errorMessage) in
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            if errorMessage != nil {
                self.presentBasicAlertWithTitle(title: errorMessage!)
            }
            else {
                DataManager.shared.orderBooks = items as! [NSDictionary]
                self.textFieldSearch.attributedPlaceholder = NSAttributedString(string: "Search...", attributes: [NSForegroundColorAttributeName : UIColor(netHex: 0x8c8c8c)])
                        
                self.setupVerifiedItems()
                self.tableView.reloadData()
            }
        }

    }
    
    func setupVerifiedItems() {
        for item in DataManager.shared.orderBooks {
            if self.isVerifiedAsset(asset: item) {
                let vi = NSMutableDictionary(dictionary: item)
                vi["amountTicker"] = DataManager.shared.getTicker(asset: item["amountAsset"])
                vi["priceTicker"] = DataManager.shared.getTicker(asset: item["priceAsset"])
                self.verifiedItems.append(vi as NSDictionary)
            }
        }
    }
    
    func actionTapped() {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addPair = UIAlertAction(title: "Add New Market", style: .default) { (action) in
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "DexNewPairViewController")
            self.navigationController?.pushViewController(controller!, animated: true)
        }
        
        let filterTitle = DataManager.isShowUnverifiedAssets() ? "Hide Unverified Assets" : "Show Unverified Assets"
        
        let filter = UIAlertAction(title: filterTitle, style: .default) { (action) in
            
            DataManager.setShowUnverifiedAssets(!DataManager.isShowUnverifiedAssets())
            self.textFieldDidChange()
        }
        
        controller.addAction(cancel)
        controller.addAction(addPair)
        controller.addAction(filter)
        
        present(controller, animated: true, completion: nil)
        
    }
    
    
    func trimmingSpaceTextFrom(text: String) -> String {
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func isVerifiedAsset(asset: NSDictionary) -> Bool {
        
        if DataManager.shared.isVerified(asset: asset["amountAsset"]! as! String)
            && DataManager.shared.isVerified(asset: asset["priceAsset"] as! String) {
                return true
        }
        
        return false
    }
    
    func isOurAsset(_ item: NSDictionary, _ key: String, _ value: String) -> Bool {
        return (item["\(key)Name"] as? String)?.lowercased() == value.lowercased()
            || DataManager.shared.getTicker(asset: item[key])?.lowercased() == value.lowercased()
    }
    
    func isOurAssetContains(_ item: NSDictionary, _ key: String, _ value: String) -> Bool {
        let isNameCountains = ((item["\(key)Name"] as! String).lowercased() as NSString).range(of: value.lowercased()).location != NSNotFound
        let tckLocation = (DataManager.shared.getTicker(asset: item[key])?.lowercased() as NSString?)?.range(of: value.lowercased()).location
        
        return isNameCountains || (tckLocation != nil && tckLocation != NSNotFound)
    }
    
    func textFieldDidChange() {
        
        searchItems = []
        
        isSearchMode = textFieldSearch.text!.characters.count > 0
        
        if isSearchMode {
            
            var textAmountAsset = ""
            var textPriceAsset = ""
            
            let items = DataManager.isShowUnverifiedAssets() ? DataManager.shared.orderBooks : verifiedItems
            
            if (textFieldSearch.text! as NSString).range(of: "/").location != NSNotFound {
                textAmountAsset = textFieldSearch.text!.substring(to: textFieldSearch.text!.range(of: "/")!.lowerBound)
                textAmountAsset = textAmountAsset.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
                
                textPriceAsset = textFieldSearch.text!.substring(from: textFieldSearch.text!.range(of: "/")!.upperBound)
                textPriceAsset = textPriceAsset.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
            }
            
            if textAmountAsset.characters.count > 0 && textPriceAsset.characters.count > 0 {
               
                for item in items {
                    if isOurAsset(item, "amountAsset", textAmountAsset)
                        && isOurAssetContains(item, "priceAsset", textPriceAsset) {
                        self.searchItems.append(item)
                    }
                }
            }
            else if textAmountAsset.characters.count > 0 || textPriceAsset.characters.count > 0 {
                
                for item in items {
                    
                    if textAmountAsset.characters.count > 0 {
                        
                        if isOurAsset(item, "amountAsset", textAmountAsset) {
                            self.searchItems.append(item)
                        }
                    } else {
                        
                        if isOurAssetContains(item, "priceAsset", textPriceAsset) {
                            self.searchItems.append(item)
                        }
                    }
                }
            }
            else {
                let words = textFieldSearch.text?.components(separatedBy: " ")
                
                for item in items {
                    for word in words! {
                        if word.characters.count > 0 {
                            if isOurAssetContains(item, "amountAsset", word) ||
                                isOurAssetContains(item, "priceAsset", word) {
                                self.searchItems.append(item)
                            }
                        }
                    }
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return DataManager.shared.orderBooks.count > 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UITableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearchMode {
            let item = searchItems[indexPath.row]
            
            if DataManager.hasPair(item) {
                DataManager.removePair(item)
            }
            else {
                DataManager.addPair(item)
            }
        }
        else {
            let item = DataManager.isShowUnverifiedAssets() ? DataManager.shared.orderBooks[indexPath.row] : verifiedItems[indexPath.row]
            
            if DataManager.hasPair(item) {
                DataManager.removePair(item)
            }
            else {
                DataManager.addPair(item)
            }
        }
        
        tableView.reloadData()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue:kNotifDidChangeDexItems), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearchMode {
            return searchItems.count
        }
        
        if DataManager.isShowUnverifiedAssets() {
            return DataManager.shared.orderBooks.count
        }
        
        return verifiedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: DexSearchCell = tableView.dequeueReusableCell(withIdentifier: "DexSearchCell", for: indexPath) as! DexSearchCell
        
        if isSearchMode {
            cell.setupCell(searchItems[indexPath.row], indexPath: indexPath,
                           isDetailsHidden: !detailsShown.contains(indexPath.row))
        }
        else {
            
            if DataManager.isShowUnverifiedAssets() {
                cell.setupCell(DataManager.shared.orderBooks[indexPath.row], indexPath: indexPath,
                               isDetailsHidden: !detailsShown.contains(indexPath.row))
            }
            else {
                cell.setupCell(verifiedItems[indexPath.row], indexPath: indexPath,
                               isDetailsHidden: !detailsShown.contains(indexPath.row))
            }
        }
        
        return cell
    }
    
    @IBAction func onHideDetails(_ sender: Any) {
        if let btn = sender as? UIButton {
            if detailsShown.contains(btn.tag) {
                detailsShown.remove(btn.tag)
            } else {
                detailsShown.insert(btn.tag)
            }
            self.tableView.reloadItemsAtIndexPaths([IndexPath(row: btn.tag, section: 0)], animationStyle: .automatic)
        }
    }
    
    
}
