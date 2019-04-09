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
    static let bitcoinPrefixScan = ":"
    static let addressKeyScan = "recipient"
    static let amountKeyScan = "amount"

    static let sendStartUrl = "client.wavesplatform.com/#send/"
}

final class QRCodeParser {

    static func parseAssetID(_ string: String) -> String? {

        let rangeStart = (string.lowercased() as NSString).range(of: Constants.sendStartUrl)
        if rangeStart.location != NSNotFound && (string as NSString).range(of: "?").location != NSNotFound {
            let start = (string as NSString).substring(from: rangeStart.location + rangeStart.length)
            return (start as NSString).substring(to: (start as NSString).range(of: "?").location)
        }
        return nil
    }

    static func parseAddress(_ string: String) -> String {
        if let address = urlValues(string)[Constants.addressKeyScan] {
            return address
        }

        let wavesPrefixRange = (string.lowercased() as NSString).range(of: Constants.wavesPrefixScan)
        if wavesPrefixRange.location != NSNotFound {
            return (string as NSString).substring(from: wavesPrefixRange.location + wavesPrefixRange.length)
        }

        let btcPrefixRange = (string.lowercased() as NSString).range(of: Constants.bitcoinPrefixScan)
        if btcPrefixRange.location != NSNotFound {
            return (string as NSString).substring(from: btcPrefixRange.location + btcPrefixRange.length)
        }
        return string
    }

    static func parseAmount(_ string: String) -> Double {
        if let amount = urlValues(string)[Constants.amountKeyScan] {
            let value = (amount as NSString).doubleValue
            return value
        }
        return 0
    }
}

private extension QRCodeParser {

    static func urlValues(_ string: String) -> [String : String] {

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
}
