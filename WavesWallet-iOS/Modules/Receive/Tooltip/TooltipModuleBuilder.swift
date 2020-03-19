//
//  TooltipModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class TooltipModuleBuilder: ModuleBuilderOutput {

    struct Input: TooltipViewControllerModulInput {
        var data: TooltipTypes.DTO.Data
    }
    
    weak var output: TooltipViewControllerModulOutput?
    
    init(output: TooltipViewControllerModulOutput?) {
        self.output = output
    }
    
    func build(input: TooltipModuleBuilder.Input) -> UIViewController {

        let vc = StoryboardScene.Tooltip.tooltipViewController.instantiate()
        vc.update(with: input)
        vc.moduleOutput = output
        return vc
    }
}
