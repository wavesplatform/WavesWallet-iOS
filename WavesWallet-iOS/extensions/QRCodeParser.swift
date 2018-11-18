//
//  QRCode+Address.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/18/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

private enum Constants {
    static let wavesPrefixScan = "waves://"
    static let addressKeyScan = "recipient"
    static let amountKeyScan = "amount"
}

final class QRCodeParser {
    
    static private func urlValues(_ string: String) -> [String : String] {
        
        var values: [String : String] = [:]
        
        if (string as NSString).range(of: "://").location != NSNotFound &&
            (string.lowercased() as NSString).range(of: Constants.wavesPrefixScan).location == NSNotFound {
            
            if let components = string.components(separatedBy: "?").last {
                let pairs = components.components(separatedBy: "&")
                for pair in pairs {
                    let pairComponents = pair.components(separatedBy: "=")
                    if let key = pairComponents.first, let value = pairComponents.last {
                        values[key] = value
                    }
                }
            }
        }
        
        return values
    }
    
    static func parseAddress(_ string: String) -> String {
        if let address = urlValues(string)[Constants.addressKeyScan] {
            return address
        }
        
        let wavesPrefixRange = (string.lowercased() as NSString).range(of: Constants.wavesPrefixScan)
        if wavesPrefixRange.location != NSNotFound {
            return (string as NSString).substring(from: wavesPrefixRange.location + wavesPrefixRange.length)
        }
        
        return string
    }
    
    static func parseAmount(_ string: String, decimals: Int) -> Money? {
        if let amount = urlValues(string)[Constants.amountKeyScan] {
            let value = (amount as NSString).doubleValue
            if value > 0 {
                return Money(value:Decimal(value), decimals)
            }
        }
        return nil
    }
}
