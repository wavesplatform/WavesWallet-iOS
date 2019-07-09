//
//  Address.swift
//  Base58
//
//  Created by rprokofev on 11/04/2019.
//

import Foundation
import WavesSDK
import WavesSDKCrypto

public class Address {
    static let AddressVersion: UInt8 = 1
    static let ChecksumLength = 4
    static let HashLength = 20
    static let AddressLength = 1 + 1 + HashLength + ChecksumLength
    
    private class func getSchemeByte() -> UInt8 {        
        return WalletEnvironment.current.scheme.utf8.first!
    }
    
    public class func addressFromPublicKey(publicKey: [UInt8]) -> String {
        let publicKeyHash = Hash.secureHash(publicKey)[0..<HashLength]
        let withoutChecksum: [UInt8] = [AddressVersion, getSchemeByte()] + publicKeyHash
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
    
    public class func isValidAddress(address: String?) -> Bool {
        return isValidAddress(address: address, schemeBytes: getSchemeByte())
    }
    
    public class func isValidVostokAddress(address: String?) -> Bool {
        return isValidAddress(address: address, schemeBytes: WalletEnvironment.current.vostokScheme.utf8.first!)
    }
    
    public class func scheme(from publicKey: String) -> String? {
        
        let address = Address.addressFromPublicKey(publicKey: publicKey.bytes)
        let bytes = Base58Encoder.decode(address)
        guard bytes.count == AddressLength else { return nil }
        guard bytes[0] == AddressVersion else { return nil }
        let schemeBytes = bytes[1]
        let data = Data(bytes: [schemeBytes])
        guard let scheme = String(data: data, encoding: .utf8) else { return nil }
        
        return scheme
    }
}
