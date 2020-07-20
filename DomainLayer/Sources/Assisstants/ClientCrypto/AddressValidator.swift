//
//  Address.swift
//  Base58
//
//  Created by rprokofev on 11/04/2019.
//

import Foundation
import WavesSDK
import WavesSDKCrypto

private struct Constants {
    static let vostokMainNetScheme = "V"
    static let vostokTestNetScheme = "F"
}

public class AddressValidator {
    static let AddressVersion: UInt8 = 1
    static let ChecksumLength = 4
    static let HashLength = 20
    static let AddressLength = 1 + 1 + HashLength + ChecksumLength
    
    public class func addressFromPublicKey(publicKey: [UInt8], environmentKind: WalletEnvironment.Kind) -> String {
        let publicKeyHash = Hash.secureHash(publicKey)[0..<HashLength]
        let withoutChecksum: [UInt8] = [AddressVersion, environmentKind.chainIdByte] + publicKeyHash
        return Base58Encoder.encode(withoutChecksum + calcCheckSum(withoutChecksum))
    }
    
    public class func calcCheckSum(_ withoutChecksum: [UInt8]) -> [UInt8] {
        return Array(Hash.secureHash(withoutChecksum)[0..<ChecksumLength])
    }
    
    public class func isValidAlias(alias: String?) -> Bool {
        guard let alias = alias else { return false }
        
        return RegEx.alias(alias) &&
            alias.count >= WavesSDKConstants.aliasNameMinLimitSymbols &&
            alias.count <= WavesSDKConstants.aliasNameMaxLimitSymbols
    }
    private class func isValidAddress(address: String?, schemeBytes: UInt8) -> Bool {
        guard let address = address else { return false }
        
        let bytes = Base58Encoder.decode(address)
        if bytes.count == AddressLength
            && bytes[0] == AddressVersion
            && bytes[1] == schemeBytes {
            let checkSum = Array(bytes[bytes.count - ChecksumLength..<bytes.count])
            let checkSumGenerated = calcCheckSum(Array(bytes[0..<bytes.count - ChecksumLength]))
            return checkSum == checkSumGenerated
        }
        return false
    }
    
    public class func isValidAddress(address: String?, environmentKind: WalletEnvironment.Kind) -> Bool {
        return isValidAddress(address: address, schemeBytes: environmentKind.chainIdByte)
    }
    
    public class func isValidVostokAddress(address: String?, environmentKind: WalletEnvironment.Kind) -> Bool {
        
        let vostokScheme: String = environmentKind == .testnet ? Constants.vostokTestNetScheme : Constants.vostokMainNetScheme
        
        return isValidAddress(address: address, schemeBytes: vostokScheme.utf8.first ?? 0)
    }
    
    
    public class func scheme(from publicKey: String, environmentKind: WalletEnvironment.Kind
    ) -> String? {
        
        let address = AddressValidator.addressFromPublicKey(publicKey: publicKey.bytes,
                                                            environmentKind: environmentKind)
        let bytes = Base58Encoder.decode(address)
        guard bytes.count == AddressLength else { return nil }
        guard bytes[0] == AddressVersion else { return nil }
        let schemeBytes = bytes[1]
        let data = Data([schemeBytes])
        guard let scheme = String(data: data, encoding: .utf8) else { return nil }
        
        return scheme
    }
}
