    //
//  String+NormalizeAssetId.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 08/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer

public extension Optional where Wrapped == String {
    
    var normalizeAssetId: String {
        if let id = self {
            return id
        } else {
            return WavesSDKConstants.wavesAssetId
        }
    }
}

public extension String {
    
    func normalizeAddress(aliasScheme: String) -> String {
        
        if let range = self.range(of: aliasScheme), self.contains(aliasScheme) {
            var newString = self
            newString.removeSubrange(range)
            return newString
        }
        
        return self
    }
}
