//
//  TransactionCardBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

struct TransactionCardBuilder: ModuleBuilderOutput {

    struct Input {
        var transaction: DomainLayer.DTO.SmartTransaction
        var callbackInput: ((TransactionCardViewControllerInput) -> Void)
    }

    var output: TransactionCardViewControllerDelegate

    func build(input: Input) -> UIViewController {

        let vc = StoryboardScene.TransactionCard.transactionCardViewController.instantiate()
        vc.system = TransactionCardSystem(transaction: input.transaction)
        vc.delegate = output
        input.callbackInput(vc)
        return vc
    }
}


