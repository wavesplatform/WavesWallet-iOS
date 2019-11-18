//
//  DexInfoPopupModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/11/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

struct DexInfoModuleBuilder: ModuleBuilder {
    
    func build(input: DexInfoPair.DTO.Pair) -> UIViewController {
        let vc = StoryboardScene.Dex.dexInfoViewController.instantiate()
        vc.pair = input
        return vc
    }
}
