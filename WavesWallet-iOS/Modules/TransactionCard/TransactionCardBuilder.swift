//
//  TransactionCardBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

struct TransactionCardBuilder: ModuleBuilderOutput {

    struct Input {
        var kind: TransactionCard.Kind
        var callbackInput: ((TransactionCardModuleInput) -> Void)
    }

    var output: TransactionCardModuleOutput

    func build(input: Input) -> UIViewController {

        let vc = StoryboardScene.TransactionCard.transactionCardViewController.instantiate()
        vc.system = TransactionCardSystem(kind: input.kind)
        vc.delegate = output
        input.callbackInput(vc)
        return vc
    }
}


