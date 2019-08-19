//
//  WidgetSettingsModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

struct WidgetSettingsModuleBuilder: ModuleBuilderOutput {
    
    typealias Input = Void
    
    let output: WidgetSettingsModuleOutput
    
    func build(input: WidgetSettingsModuleBuilder.Input) -> UIViewController {
        
        let vc = StoryboardScene.WidgetSettings.widgetSettingsViewController.instantiate()
        vc.system = WidgetSettingsCardSystem()
        vc.moduleOutput = output
        return vc
    }
}
