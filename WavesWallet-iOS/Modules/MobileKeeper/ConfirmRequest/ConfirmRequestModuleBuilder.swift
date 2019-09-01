//
//  ConfirmRequestModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import Extensions
import WavesSDK

struct ConfirmRequestModuleBuilder: ModuleBuilderOutput {
    
    typealias Input = ConfirmRequest.DTO.Input
    
    let output: ConfirmRequestModuleOutput
    
    func build(input: ConfirmRequestModuleBuilder.Input) -> UIViewController {
        
        let vc = StoryboardScene.MobileKeeper.confirmRequestViewController.instantiate()
        vc.system = ConfirmRequestSystem(input: input)
        vc.moduleOutput = output
        
        return vc
    }
}
