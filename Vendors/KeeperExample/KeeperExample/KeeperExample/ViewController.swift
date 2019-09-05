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
        
        let chainId = WavesSDK.shared.enviroment.chainId ?? ""
        
        switch sender.kind {
        case .send_1:
            
            WavesKeeper.shared.send(.transfer(.init(recipient: "3PNaua1fMrQm4TArqeTuakmY1u985CgMRk6",
                                                    assetId: "WAVES",
                                                    amount: 1000,
                                                    fee: 100000,
                                                    attachment: "First",
                                                    feeAssetId: "WAVES",
                                                    chainId: chainId)))
                .subscribe(onNext: { (response) in
                    print("Eee boy \(response)")
                },
                           onError: nil,
                           onCompleted: nil,
                           onDisposed: nil)
            
            
        case .send_2:
            
            WavesKeeper.shared.sign(.transfer(.init(recipient: "3PNaua1fMrQm4TArqeTuakmY1u985CgMRk6",
                                                    assetId: "WAVES",
                                                    amount: 1000,
                                                    fee: 100000,
                                                    attachment: "First",
                                                    feeAssetId: "WAVES",
                                                    chainId: chainId)))
                .flatMap({ (response) -> Observable<NodeService.DTO.Transaction> in
                    
                    guard case let .success(success) = response.kind else { return Observable.never() }
                    guard case let .sign(query) = success else { return Observable.never() }
                    
                        
                    return WavesSDK.shared
                        .services
                        .nodeServices
                        .transactionNodeService
                        .transactions(query: query)
                })
                .subscribe(onNext: { (response) in
                    print("Eee boy \(response)")
                },
                           onError: nil,
                           onCompleted: nil,
                           onDisposed: nil)
            
        case .send_3:
            WavesKeeper.shared.send(.transfer(.init(recipient: "3PNaua1fMrQm4TArqeTuakmY1u985CgMRk6",
                                                    assetId: "WAVES",
                                                    amount: 1000,
                                                    fee: 100000,
                                                    attachment: "First",
                                                    feeAssetId: "А",
                                                    chainId: chainId)))
                .subscribe(onNext: { (response) in
                    print("Eee boy \(response)")
                },
                           onError: nil,
                           onCompleted: nil,
                           onDisposed: nil)
            
        case .send_4:
            break
            
        case .none:
            break
        default:
            break
        }
    }
}



