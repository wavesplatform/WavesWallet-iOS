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

    @IBOutlet weak var labelValue1: UILabel!
    @IBOutlet weak var labelValue2: UILabel!
    @IBOutlet weak var imageViewIcon1: UIImageView!
    @IBOutlet weak var imageViewIcon2: UIImageView!
    
    @IBOutlet weak var labelAmountAsset: UILabel!
    @IBOutlet weak var labelPriceAsset: UILabel!
    
    @IBOutlet weak var label1Offset: NSLayoutConstraint!
    @IBOutlet weak var label2Offset: NSLayoutConstraint!
    
    override func awakeFromNib() {
        backgroundColor = UIColor.clear
        viewContainer.layer.cornerRadius = 3
        viewContainer.backgroundColor = UIColor.white
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowRadius = 2
        viewContainer.layer.shadowOpacity = 0.3
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func setupCell(_ item: NSDictionary) {
        
        labelValue1.text = "\(item["amountAssetName"]!)  /"
        labelValue2.text = item["priceAssetName"] as? String
        
        label1Offset.constant = 65
        label2Offset.constant = 5
        
        if item["amountAsset"] as? String == "WAVES" {
            imageViewIcon1.image = UIImage(named: "icon_waves")
        }
        else {
            
            let arr = DataManager.shared.verifiedAssets.allKeys as NSArray
            if arr.contains(item["amountAsset"]!) {
                imageViewIcon1.image = UIImage(named: "icon_cert")
            }
            else {
                label1Offset.constant = 45
                imageViewIcon1.image = nil
            }
            
        }
        
        if item["priceAsset"] as? String == "WAVES" {
            imageViewIcon2.image = UIImage(named: "icon_waves")
        }
        else {
            let arr = DataManager.shared.verifiedAssets.allKeys as NSArray
            if arr.contains(item["priceAsset"]!) {
                imageViewIcon2.image = UIImage(named: "icon_cert")
            }
            else {
                label2Offset.constant = 0
                imageViewIcon2.image = nil
            }
        }
        
        labelAmountAsset.text = item["amountAsset"] as? String
        labelPriceAsset.text = item["priceAsset"] as? String

        
        if DataManager.hasPair(item) {
            imageViewCheckmark.image = UIImage(named: "checkmark_fill_gray")
        }
        else {
            imageViewCheckmark.image = UIImage(named: "checkmark_empty_gray")
        }
        
        imageViewCheckmark.alpha = DataManager.isWavesWbtcPair(item) ? 0.6 : 1
    }
}

class DexSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var textFieldSearch : UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchItems = [NSDictionary]()
    
    var isLoading = false
    var isSearchMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        textFieldSearch = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        textFieldSearch.clearButtonMode = .always
        textFieldSearch.textColor = UIColor.white
        textFieldSearch.delegate = self
        textFieldSearch.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textFieldSearch.autocorrectionType = .no
        textFieldSearch.returnKeyType = .done
        navigationItem.titleView = textFieldSearch
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        if DataManager.shared.verifiedAssets == nil {
            loadInfo()
        }
        else {
            activityIndicator.stopAnimating()
            textFieldSearch.attributedPlaceholder = NSAttributedString(string: "Search...", attributes: [NSForegroundColorAttributeName : UIColor.white])
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        textFieldSearch.resignFirstResponder()
    }
    
    func loadInfo() {
        isLoading = true
        NetworkManager.getAllOrderBooks { (items, errorMessage) in
           
            if errorMessage != nil {
                self.presentBasicAlertWithTitle(title: errorMessage!)
                self.isLoading = false
                self.activityIndicator.stopAnimating()
            }
            else {
                DataManager.shared.orderBooks = items as! [NSDictionary]
                NetworkManager.getVerifiedAssets({ (assets, errorMessage) in
                    
                    self.activityIndicator.stopAnimating()
                    self.isLoading = false

                    if errorMessage != nil {
                        self.presentBasicAlertWithTitle(title: errorMessage!)
                    }
                    else {
                        self.textFieldSearch.attributedPlaceholder = NSAttributedString(string: "Search...", attributes: [NSForegroundColorAttributeName : UIColor.white])
                        DataManager.shared.verifiedAssets = assets
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func addTapped() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "DexNewPairViewController")
        navigationController?.pushViewController(controller!, animated: true)
    }
    
    func trimmingSpaceTextFrom(text: String) -> String {
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func textFieldDidChange() {
        
        searchItems = []
        
        isSearchMode = textFieldSearch.text!.characters.count > 0
        
        if isSearchMode {
            
            var textAmountAsset = ""
            var textPriceAsset = ""
            
            if (textFieldSearch.text! as NSString).range(of: "/").location != NSNotFound {
                textAmountAsset = textFieldSearch.text!.substring(to: textFieldSearch.text!.range(of: "/")!.lowerBound)
                textAmountAsset = textAmountAsset.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                textPriceAsset = textFieldSearch.text!.substring(from: textFieldSearch.text!.range(of: "/")!.upperBound)
                textPriceAsset = textPriceAsset.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            
            if textAmountAsset.characters.count > 0 && textPriceAsset.characters.count > 0 {
               
                for item in DataManager.shared.orderBooks{
                    
                    if (item["amountAssetName"] as? String)?.lowercased() == textAmountAsset.lowercased() &&
                       ((item["priceAssetName"] as! String).lowercased() as NSString).range(of: textPriceAsset.lowercased()).location != NSNotFound {
                        self.searchItems.append(item)
                    }
                }
            }
            else if textAmountAsset.characters.count > 0 || textPriceAsset.characters.count > 0 {
                
                for item in DataManager.shared.orderBooks {
                    
                    if textAmountAsset.characters.count > 0 {
                        
                        if (item["amountAssetName"] as? String)?.lowercased() == textAmountAsset.lowercased() {
                            self.searchItems.append(item)
                        }
                    }
                    else {
                        
                        if ((item["priceAssetName"] as! String).lowercased() as NSString).range(of: textPriceAsset.lowercased()).location != NSNotFound {
                            self.searchItems.append(item)
                        }
                    }
                }
            }
            else {
                let words = textFieldSearch.text?.components(separatedBy: " ")
                
                for item in DataManager.shared.orderBooks {
                    for word in words! {
                        if word.characters.count > 0 {
                            if ((item["amountAssetName"] as! String).lowercased() as NSString).range(of: word.lowercased()).location != NSNotFound ||
                                ((item["priceAssetName"] as! String).lowercased() as NSString).range(of: word.lowercased()).location != NSNotFound {
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
            let item = DataManager.shared.orderBooks[indexPath.row]
            
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
        
        return DataManager.shared.orderBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: DexSearchCell = tableView.dequeueReusableCell(withIdentifier: "DexSearchCell", for: indexPath) as! DexSearchCell
        
        if isSearchMode {
            cell.setupCell(searchItems[indexPath.row])
        }
        else {
            cell.setupCell(DataManager.shared.orderBooks[indexPath.row])
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
