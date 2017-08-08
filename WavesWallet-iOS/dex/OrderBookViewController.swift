//
//  OrderBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class OrderBookViewController: UIViewController {

    var priceAsset : String!
    var amountAsset : String!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.getOrderBook(amountAsset: amountAsset, priceAsset: priceAsset) { (items, errorMessage) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
