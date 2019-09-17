//
//  ViewController.swift
//  KeeperExample
//
//  Created by rprokofev on 04.09.2019.
//  Copyright © 2019 Waves. All rights reserved.
//

import UIKit
import RxSwift
import WavesSDK
import WavesSDKCrypto

final class Button: UIButton {

    enum Kind: Int {
        case none
        case send_1
        case send_2
        case send_3
        case send_4
        case send_5
        case send_6
        case send_7
        case send_8
        case send_9
        case send_10
        case send_11
        case send_12
        case send_13
        case send_14
        case send_15
        case send_16
    }
    
    @IBInspectable private var type: Int = 0
    
    var kind: Kind {
        return Kind.init(rawValue: type) ?? .none
    }
}


class ViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handlerButton(sender: Button) {
        
        var chainId = WavesSDK.shared.enviroment.chainId ?? ""
        
//        chainId = "T"
        
//        switch sender.kind {
//        case .send_1:
//            WavesKeeper.shared.send(.transfer(txTansfer(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    print("Eee boy \(response)")
//                },
//                           onError: nil,
//                           onCompleted: nil,
//                           onDisposed: nil)
//            
//            
//        case .send_2:
//            WavesKeeper.shared.send(.invokeScript(txInvokeScript(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//
//                    print(response)
//                })
//
//            
//        case .send_3:
//            WavesKeeper.shared.send(.data(txData(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//           
//
//            
//        case .send_4:
//            WavesKeeper.shared.send(.transfer(txTransferError(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    print(response)
//                })
//            
//        case .send_5:
//            WavesKeeper.shared.send(.invokeScript(txInvokeScriptError(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//            
//        case .send_6:
//           
//            
//            WavesKeeper.shared.send(.data(txDataEmpty(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//            
//        case .send_7:
//            WavesKeeper.shared.send(.data(txDataError(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//            
//        case .send_8:
//          
//            WavesKeeper.shared.send(.burn(txBurn(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//        
//        case .send_9:
//            WavesKeeper.shared.sign(.transfer(txTansfer(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    print("\(response)")
//                },
//                           onError: nil,
//                           onCompleted: nil,
//                           onDisposed: nil)
//            
//        case .send_10:
//
//            WavesKeeper.shared.sign(.invokeScript(txInvokeScript(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//            
//        case .send_11:
//
//            WavesKeeper.shared.sign(.data(txData(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//            
//        case .send_12:
//            WavesKeeper.shared.sign(.transfer(txTransferError(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    print(response)
//                })
//            
//        case .send_13:
//    
//            WavesKeeper.shared.sign(.invokeScript(txInvokeScriptError(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//        case .send_14:
//            WavesKeeper.shared.sign(.data(txDataEmpty(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//            
//        case .send_15:
//            WavesKeeper.shared.sign(.data(txDataError(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//            
//        case .send_16:
//            WavesKeeper.shared.sign(.burn(txBurn(chainId: chainId)))
//                .subscribe(onNext: { (response) in
//                    
//                    print(response)
//                })
//        case .none:
//            break
//        default:
//            break
//        }
    }
}
