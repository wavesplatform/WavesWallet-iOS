//
//  StakingTransferModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 24.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer


final class StakingTransferModuleBuilder: ModuleBuilderOutput {
                    
    weak var output: StakingTransferModuleOutput?
    
    struct Input {
        let assetId: String
        let kind: StakingTransfer.DTO.Kind
    }
    
    init(output: Output) {
        self.output = output
    }
        
    func build(input: StakingTransferModuleBuilder.Input) -> UIViewController {
        let vc = StoryboardScene.StakingTransfer.stakingTransferViewController.instantiate()
        vc.moduleOutput = output
        vc.system = StakingTransferSystem(assetId: input.assetId, kind: input.kind)
        
        return vc
    }
}
