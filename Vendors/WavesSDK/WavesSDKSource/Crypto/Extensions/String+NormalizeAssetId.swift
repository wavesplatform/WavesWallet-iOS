//
//  String+NormalizeAssetId.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 08/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension Optional where Wrapped == String {

    var normalizeAssetId: String {
        if let id = self {
            return id
        } else {
            return WavesSDKCryptoConstants.wavesAssetId
        }
    }
}

public extension String {

    func normalizeAddress(environment: Environment) -> String {

        if let range = self.range(of: environment.aliasScheme), self.contains(environment.aliasScheme) {
            var newString = self
            newString.removeSubrange(range)
            return newString
        }

        return self
    }
}
