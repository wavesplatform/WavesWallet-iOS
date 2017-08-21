//
//  DexViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 04.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import Alamofire


class DexTableListCell : UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelLow: UILabel!
    @IBOutlet weak var labelHigh: UILabel!
    @IBOutlet weak var labelPercent: UILabel!
    @IBOutlet weak var imageViewArrow: UIImageView!

    @IBOutlet weak var labelValue1: UILabel!
    @IBOutlet weak var labelValue2: UILabel!
    
    let timeFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewContent.layer.cornerRadius = 3
        viewContent.backgroundColor = UIColor.white
        viewContent.layer.shadowColor = UIColor.black.cgColor
        viewContent.layer.shadowRadius = 2
        viewContent.layer.shadowOpacity = 0.3
        viewContent.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        timeFormatter.dateFormat = "HH:mm:ss"
    }

    func setupCell(_ item: NSDictionary, dataItem: NSDictionary?) {
     
        labelTitle.text = "\(item["amountAssetName"]!) / \(item["priceAssetName"]!)"
    
        let data = dataItem?["24h_open"]
        
        if data != nil {

            let lastPriceOpen24 = Double(dataItem!["24h_open"] as! String)!
            let lastPrice = dataItem!["price"] as! Double
            
            labelValue1.text = String(format: "%.08f", lastPrice)
            
            labelLow.text = "low: \(dataItem?["24h_low"] as! String)"
            labelHigh.text = "high: \(dataItem?["24h_high"] as! String)"
            
            let timestamp = dataItem?["timestamp"] as! Int64
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
            labelTime.text = timeFormatter.string(from: date)
            
            if lastPriceOpen24 == 0 {
                labelPercent.text = "+0.00 %"
            }
            else {
                let percent = (lastPrice - lastPriceOpen24) * 100 / lastPriceOpen24
                
                if percent >= 0 {
                    labelPercent.text = String(format: "+%.02f%%", percent)
                }
                else {
                    labelPercent.text = String(format: "%.02f%%", percent)
                }
            }
            
            if lastPrice - lastPriceOpen24 >= 0 {
                labelValue2.text = String(format: "+%.08f", lastPrice - lastPriceOpen24)
                imageViewArrow.image = UIImage(named: "arrow_green")
                labelValue1.textColor = UIColor(netHex: 0x5EAC69)
                labelValue2.textColor = UIColor(netHex: 0x5EAC69)
                labelPercent.textColor = UIColor(netHex: 0x5EAC69)
            }
            else {
                labelValue2.text = String(format: "%.08f", lastPrice - lastPriceOpen24)
                imageViewArrow.image = UIImage(named: "arrow_red")
                labelValue1.textColor = UIColor(netHex: 0xE56C69)
                labelValue2.textColor = UIColor(netHex: 0xE56C69)
                labelPercent.textColor = UIColor(netHex: 0xE56C69)
            }
        }
        else {
            labelValue1.text = "0.00"
            labelValue2.text = "0.00"
            labelLow.text = "low: 0.00"
            labelHigh.text = "high: 0.00"
            labelTime.text = nil
            labelPercent.text = "0.00 %"
            imageViewArrow.image = UIImage(named: "arrow_green")
            labelValue1.textColor = UIColor(netHex: 0x5EAC69)
            labelValue2.textColor = UIColor(netHex: 0x5EAC69)
            labelPercent.textColor = UIColor(netHex: 0x5EAC69)
        }
    }
}



class DexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var dataItems = NSMutableArray()
    
    var timer: Timer! = nil
    
    var request: DataRequest? = nil
    
    let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        title = "Dex"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            
        let wavesWbtc = DataManager.getWavesWbtcPair()
   
        dataItems.add(NSMutableDictionary(dictionary: ["priceAsset" : wavesWbtc["priceAsset"]!, "amountAsset" : wavesWbtc["amountAsset"]!]))
        
        for item in DataManager.getDexPairs() as! [NSDictionary] {
            dataItems.add(NSMutableDictionary(dictionary:["priceAsset" : item["priceAsset"]!, "amountAsset" : item["amountAsset"]!]))
        }
        
        tableView.isHidden = true
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: kNotifDidChangeDexItems), object: nil, queue: nil) { (notif) in
            
            self.setupValidDataItems()
            self.updateInfo()
            self.tableView.reloadData()
        }
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh() {
    
        updateInfo()
    }
    
    func setupValidDataItems() {
        let itemsToRemove = NSMutableArray()
        
        for item in self.dataItems as! [NSDictionary] {
            
            if !DataManager.hasPair(item) {
                itemsToRemove.add(item)
            }
        }
        
        self.dataItems.removeObjects(in: itemsToRemove as! [Any])
        
        for item in DataManager.getDexPairs() as! [NSDictionary] {
            
            var hasItem = false
            
            for dataItem in self.dataItems as! [NSDictionary] {
                if dataItem["amountAsset"] as? String == item["amountAsset"] as? String &&
                    dataItem["priceAsset"] as? String == item["priceAsset"] as? String {
                    hasItem = true
                }
            }
            
            if !hasItem {
                self.dataItems.add(NSMutableDictionary(dictionary:["priceAsset" : item["priceAsset"]!,
                                                                   "amountAsset" : item["amountAsset"]!]))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if timer == nil {
            loadInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        clearTimer()
    }
    
    func clearTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        request?.cancel()
    }
    
    func updateInfo() {
        
        for item in dataItems as! [NSMutableDictionary] {
            item["hasLoadInfo"] = false
        }
        
        loadInfo()
    }
    
    func loadInfo() {
        
        clearTimer()
        
        if let item = getItemToLoad() as? NSMutableDictionary {
            
            let amountAsset = item["amountAsset"] as! String
            let priceAsset = item["priceAsset"] as! String
            
            request = NetworkManager.getLastTraderPairPrice(amountAsset: amountAsset, priceAsset: priceAsset, complete: { (price,timestamp, errorMessage) in
                
                if errorMessage != nil {
                    item["hasLoadInfo"] = true
                    self.loadInfo()
                }
                else {
                    item["price"] = price
                    item["timestamp"] = timestamp

                    self.request = NetworkManager.getTickerInfo(amountAsset: amountAsset, priceAsset: priceAsset, complete: { (info, errorMessage) in
                        
                        if errorMessage != nil {

                            self.presentBasicAlertWithTitle(title: errorMessage!)
                        }
                        else {
                            item["hasLoadInfo"] = true
                            item["24h_high"] = info?["24h_high"]
                            item["24h_low"] = info?["24h_low"]
                            item["24h_open"] = info?["24h_open"]
                            
                            self.loadInfo()
                        }
                    })
                }
            })
        }
        else {
            
            if tableView.isHidden {
                tableView.isHidden = false
                activityIndicator.stopAnimating()
            }
            
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            
            tableView.reloadData()
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
        }
    }
    
    func getItemToLoad() -> NSDictionary? {
        
        for item in dataItems as! [NSDictionary] {
            
            if item["hasLoadInfo"] as? Bool == false ||
               item["hasLoadInfo"] == nil {
               return item
            }
        }
        
        return nil
    }
    
    func getDataItemForPair(_ pair: NSDictionary) -> NSDictionary? {
     
        for item in dataItems as! [NSDictionary] {
            
            if item["amountAsset"] as? String == pair["amountAsset"] as? String &&
                item["priceAsset"] as? String == pair["priceAsset"] as? String{
                return item
            }
        }
        
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addTapped() {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "DexSearchViewController") as! DexSearchViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: UITableView
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            if editingStyle == .delete {
                let item = DataManager.getDexPairs()[indexPath.row] as! NSDictionary
                DataManager.removePair(item)
                setupValidDataItems()
                updateInfo()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DexContainerViewController", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if section == 0 {
            return 1
        }
        
        return DataManager.getDexPairs().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell : DexTableListCell = tableView.dequeueReusableCell(withIdentifier: "DexTableListCell", for:indexPath) as! DexTableListCell
       
        if indexPath.section == 0 {
            cell.setupCell(DataManager.getWavesWbtcPair(), dataItem: getDataItemForPair(DataManager.getWavesWbtcPair()))
        }
        else {
            let item = DataManager.getDexPairs()[indexPath.row] as! NSDictionary
            cell.setupCell(item , dataItem: getDataItemForPair(item))
        }
        
        return cell
    }
    
    //MARK: Segue
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DexContainerViewController" {
            
            let indexPath = sender as! NSIndexPath
            
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as? DexTableListCell
            
            let item : NSDictionary!
            
            if indexPath.section == 0 {
                item = DataManager.getWavesWbtcPair()
            }
            else {
                item = DataManager.getDexPairs()[indexPath.row] as! NSDictionary
            }
            
            let dexContainerViewController = segue.destination as! DexContainerViewController
            dexContainerViewController.amountAsset = item["amountAsset"] as! String
            dexContainerViewController.priceAsset = item["priceAsset"] as! String
            dexContainerViewController.priceAssetDecimal = (item["priceAssetInfo"] as? NSDictionary)?["decimals"] as? Int ?? 8
            dexContainerViewController.amountAssetDecimal = (item["amountAssetInfo"] as? NSDictionary)?["decimals"] as? Int ?? 8
            dexContainerViewController.title = cell?.labelTitle.text ?? ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
