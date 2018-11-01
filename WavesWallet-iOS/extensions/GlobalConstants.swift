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
    static let accountNameMinLimitSymbols: Int = 1
    static let minLengthPassword: Int = 2
    #else
    static let accountNameMinLimitSymbols: Int = 1
    static let minLengthPassword: Int = 8
    #endif

    static let aliasNameMinLimitSymbols: Int = 4
    static let aliasNameMaxLimitSymbols: Int = 30

    static let wavesAssetId = "WAVES"
    static let aliasPrefix = "alias:W:"

    static let WavesTransactionFeeAmount: Int64 = 100000
    static let WavesTransactionFee = Money(GlobalConstants.WavesTransactionFeeAmount, 8)

    enum Coinomat {}
}

extension GlobalConstants.Coinomat {
    
    private static let url = "https://coinomat.com/"

    static var createTunnel: String {
        return url + apiVersion(.v1) + "create_tunnel.php"
    }
    
    static var getTunnel: String {
        return url + apiVersion(.v1) + "get_tunnel.php"
    }
    
    static var getRate: String {
        return url + apiVersion(.v1) + "get_xrate.php"
    }
    
    static var getLimits: String {
        return url + apiVersion(.v2) + "indacoin/limits.php"
    }

    static var buy: String {
        return url + apiVersion(.v2) + "indacoin/buy.php"
    }
   
    private enum Version {
        case v1
        case v2
    }
    
    private static func apiVersion(_ version: Version) -> String {
        switch version {
        case .v1:
            return "api/v1/"
        
        case .v2:
            return "api/v2/"
        }
    }
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
