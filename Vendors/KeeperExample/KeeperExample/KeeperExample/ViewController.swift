//
//  ViewController.swift
//  KeeperExample
//
//  Created by rprokofev on 04.09.2019.
//  Copyright © 2019 Waves. All rights reserved.
//

import UIKit
import WavesSDK

final class Button: UIButton {

    enum Kind: Int {
        case none
        case send_1
        case send_2
        case send_3
        case send_4
    }
    
    @IBInspectable private var type: Int = 0
    
    var kind: Kind {
        return Kind.init(rawValue: type) ?? .none
    }
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handlerButton(sender: Button) {
        
        switch sender.kind {
        case .send_1:
            
            WavesKeeper.shared.send(.transfer(.init(recipient: "3PNaua1fMrQm4TArqeTuakmY1u985CgMRk6",
                                                    assetId: "WAVES",
                                                    amount: 1000,
                                                    fee: 100000,
                                                    attachment: "First",
                                                    feeAssetId: "WAVES",
                                                    chainId: "W")))
            
            
        case .send_2:
            break
            
        case .send_3:
            break
            
        case .send_4:
            break
            
        case .none:
            break
        }
    }
}



