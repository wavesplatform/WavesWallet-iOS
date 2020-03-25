//
//  TransactionCompletedVC.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions

protocol TransactionCompletedInput {
    
}

final class TransactionCompletedVC: UIViewController {
    
    var transactions: DomainLayer.DTO.SmartTransaction? {
        didSet {
            
        }
    }
}

final class TransactionCompletedBuilder: ModuleBuilder {
             
    func build(input: DomainLayer.DTO.SmartTransaction) -> UIViewController {
        
        let vc = StoryboardScene.StakingTransfer.transactionCompletedVC.instantiate()
        vc.transactions = input
        return vc
    }
}
