//
//  AssetsSearchModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

protocol AssetsSearchModuleOutput: AnyObject {
    
    func assetsSearchSelectedAssets(_ assets: [DomainLayer.DTO.Asset])
}
