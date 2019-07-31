//
//  WidgetSettingsModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

struct WidgetSettingsModuleBuilder: ModuleBuilderOutput {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var output: Output
    
    func build(input: WidgetSettingsModuleBuilder.Input) -> UIViewController {
        
        let vc = StoryboardScene.WidgetSettings.widgetSettingsViewController.instantiate()
//        let presenter = WidgetSettingsModuleBuilder
        vc.system = WidgetSettingsCardSystem()
//        presenter.moduleOutput = output
//        presenter.input = input
//        vc.presenter = presenter
        return vc
    }
}

