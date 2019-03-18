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
    static let accountNameMaxLimitSymbols: Int = 24
    static let minLengthPassword: Int = 2
    static let minimumSeedLength = 0
    #else
    static let accountNameMinLimitSymbols: Int = 2
    static let accountNameMaxLimitSymbols: Int = 24
    static let minLengthPassword: Int = 6
    static let minimumSeedLength = 25
    #endif

    static let aliasNameMinLimitSymbols: Int = 4
    static let aliasNameMaxLimitSymbols: Int = 30

    static let wavesAssetId = "WAVES"
    
    static let WavesTransactionFeeAmount: Int64 = 100000
    static let WavesDecimals: Int = 8
    static let WavesTransactionFee = Money(GlobalConstants.WavesTransactionFeeAmount, GlobalConstants.WavesDecimals)
    static let FiatDecimals: Int = 2
}

enum RegEx {
    static let alias = "^[a-z0-9\\.@_-]*$"

    static func alias(_ alias: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: RegEx.alias)
            return regex.matches(in: alias, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSRange(location: 0, length: alias.count)).count > 0
        } catch let e {
            SweetLogger.error(e)
            return false
        }
    }
}
