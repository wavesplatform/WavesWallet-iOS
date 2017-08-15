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
    }
}

class DexSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var textFieldSearch : UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchItems = [NSDictionary]()
    
    var isLoading = false
    var wavesWBTCItem: NSDictionary? = nil
    
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
            self.setupDefaultItem()
            activityIndicator.stopAnimating()
            textFieldSearch.attributedPlaceholder = NSAttributedString(string: "Search...", attributes: [NSForegroundColorAttributeName : UIColor.white])
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        textFieldSearch.resignFirstResponder()
    }
    
    func setupDefaultItem() {
        
        for item in DataManager.shared.orderBooks as! [NSDictionary] {
            
            if item["amountAsset"] as? String == "WAVES" &&
                item["priceAssetName"] as? String == "WBTC" {
                    wavesWBTCItem = item
                }
        }
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
                DataManager.shared.orderBooks = items
                NetworkManager.getVerifiedAssets({ (assets, errorMessage) in
                    
                    self.activityIndicator.stopAnimating()
                    self.isLoading = false

                    if errorMessage != nil {
                        self.presentBasicAlertWithTitle(title: errorMessage!)
                    }
                    else {
                        self.setupDefaultItem()
                        self.textFieldSearch.attributedPlaceholder = NSAttributedString(string: "Search...", attributes: [NSForegroundColorAttributeName : UIColor.white])
                        DataManager.shared.verifiedAssets = assets
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func addTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func trimmingSpaceTextFrom(text: String) -> String {
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func textFieldDidChange() {
        
        searchItems = []
        
        if textFieldSearch.text!.characters.count > 0 {
            
            var textAmountAsset = ""
            var textPriceAsset = ""
            
            if (textFieldSearch.text! as NSString).range(of: "/").location != NSNotFound {
                textAmountAsset = textFieldSearch.text!.substring(to: textFieldSearch.text!.range(of: "/")!.lowerBound)
                textAmountAsset = textAmountAsset.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                textPriceAsset = textFieldSearch.text!.substring(from: textFieldSearch.text!.range(of: "/")!.upperBound)
                textPriceAsset = textPriceAsset.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            
            if textAmountAsset.characters.count > 0 && textPriceAsset.characters.count > 0 {
               
                for item in DataManager.shared.orderBooks as! [NSDictionary] {
                    
                    if (item["amountAssetName"] as? String)?.lowercased() == textAmountAsset.lowercased() &&
                       ((item["priceAssetName"] as! String).lowercased() as NSString).range(of: textPriceAsset.lowercased()).location != NSNotFound {
                        self.searchItems.append(item)
                    }
                }
            }
            else if textAmountAsset.characters.count > 0 || textPriceAsset.characters.count > 0 {
                
                for item in DataManager.shared.orderBooks as! [NSDictionary] {
                    
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
                
                for item in DataManager.shared.orderBooks as! [NSDictionary] {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UITableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
        }
        else {
            
            let item = searchItems[indexPath.row]
            print(item)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if isLoading || (textFieldSearch.text?.characters.count)! > 0 {
                return 0
            }
            
            return wavesWBTCItem == nil ? 0 : 1
        }
        
        return searchItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: DexSearchCell = tableView.dequeueReusableCell(withIdentifier: "DexSearchCell", for: indexPath) as! DexSearchCell
        
        if indexPath.section == 0 {
            cell.setupCell(wavesWBTCItem!)
        }
        else {
            cell.setupCell(searchItems[indexPath.row])
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
