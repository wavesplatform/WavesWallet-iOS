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

    static let aliasNameMinLimitSymbols: Int = 4
    static let aliasNameMaxLimitSymbols: Int = 30
    static let wavesAssetId = "WAVES"
}

enum RegEx {
    static let alias = "^[a-z0-9\\.@_-]*$"

    static func alias(_ alias: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: RegEx.alias)
            return regex.matches(in: alias, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSRange(location: 0, length: alias.count)).count > 0
        } catch let e {
            error(e)
            return false
        }
    }
}
