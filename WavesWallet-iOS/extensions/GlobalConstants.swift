//
//  GlobalConstants.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum GlobalConstants {
    #if DEBUG
    static let accountNameMinLimitSymbols: Int = 2
    #else
    static let accountNameMinLimitSymbols: Int = 8
    #endif
    static let wavesAssetId = "WAVES"
}
