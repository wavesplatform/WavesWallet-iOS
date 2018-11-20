//
//  StartLeasingLoadingBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

struct StartLeasingLoadingBuilder: ModuleBuilder {
    
    struct Input {
        let kind: StartLeasing.DTO.Kind
    }
    
    func build(input: StartLeasingLoadingBuilder.Input) -> UIViewController {
        
        let vc = StoryboardScene.StartLeasing.startLeasingLoadingViewController.instantiate()
        vc.kind = input.kind
        return vc
    }
}
