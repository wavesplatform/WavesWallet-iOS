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

struct ConfirmRequestModuleBuilder: ModuleBuilderOutput {
    
    typealias Input = Void
    
    let output: ConfirmRequestModuleOutput
    
    func build(input: ConfirmRequestModuleBuilder.Input) -> UIViewController {
        
        let vc = StoryboardScene.WidgetSettings.widgetSettingsViewController.instantiate()
        vc.system = WidgetSettingsCardSystem()
        
        return vc
    }
}
