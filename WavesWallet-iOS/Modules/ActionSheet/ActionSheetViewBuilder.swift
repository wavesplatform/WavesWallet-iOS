//
//  WidgetSettingsIntervalViewBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 02.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

struct ActionSheetViewBuilder: ModuleBuilderOutput {
    
    typealias Input = ActionSheet.DTO.Data
    
    var output: ((ActionSheet.DTO.Element) -> Void)
    
    func build(input: Input) -> UIViewController {
        let vc = StoryboardScene.ActionSheet.actionSheetViewController.instantiate()
        vc.data = input
        vc.elementDidSelect = output
        return vc
    }
}
    
