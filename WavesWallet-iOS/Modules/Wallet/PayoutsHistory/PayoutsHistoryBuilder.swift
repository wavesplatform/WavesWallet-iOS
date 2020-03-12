//
//  PaymentHistoryBuilder.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation

protocol PayoutsHistoryOutput: AnyObject {}

final class PayoutsHistoryBuilder: ModuleBuilder {
    typealias Input = Void
//    var output: PayoutsHistoryOutput
    
//    init(output: PayoutsHistoryOutput) {
//        self.output = output
//    }
    
    func build(input: Void) -> UIViewController {
        build()
    }
    
    func build() -> UIViewController {
        let viewController = StoryboardScene.PayoutsHistory.payoutsHistoryVC.instantiate()
        
        let massTransferRepository = UseCasesFactory.instance.repositories.massTransferRepository
        let enviroment = UseCasesFactory.instance.repositories.developmentConfigsRepository
        
        let system = PayoutsHistorySystem(massTransferRepository: massTransferRepository, enviroment: enviroment)
        
        viewController.system = system
        
        return viewController
    }
}
