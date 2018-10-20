//
//  SendModuleValidation.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

final class SendModuleValidation {
    
    var address:(() -> String)?
    var asset:(() -> DomainLayer.DTO.AssetBalance)?
    
    var canValidateAlias: Bool {
        
        if let address = address {
            let alias = address()
            return alias.count >= Send.ViewModel.minimumAliasLength &&
                alias.count <= Send.ViewModel.maximumAliasLength

        }
        return false
    }
    
    var isValidLocalAddress: Bool {
        if let address = address {
            return Address.isValidAddress(address: address())
        }
        return true
    }
    
    var isValidCryptocyrrencyAddress: Bool {
        
        if let address = address, let asset = asset {
            if let regExp = asset().asset?.regularExpression {
                return NSPredicate(format: "SELF MATCHES %@", regExp).evaluate(with: address())
            }
        }
        return false
    }
    
    func isValidAddress(_ address: String, isValidAlias: Bool) -> Bool {
        
        if let asset = asset {
            guard let asset = asset().asset else { return true }

            if asset.isWaves || asset.isWavesToken || asset.isFiat {
                return isValidLocalAddress || isValidAlias
            }
            else {
                return isValidLocalAddress || isValidCryptocyrrencyAddress || isValidAlias
            }
        }
        return true
    }
    
}
