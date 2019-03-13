//
//  TransactionCardBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

struct TransactionCardBuilder: ModuleBuilderOutput {
    
    typealias Input = DomainLayer.DTO.SmartTransaction

    var output: Void

    func build(input: DomainLayer.DTO.SmartTransaction) -> UIViewController {

        let vc = StoryboardScene.TransactionCard.transactionCardViewController.instantiate()
        vc.system = TransactionCardSystem(transaction: input)

        return vc
    }
}


