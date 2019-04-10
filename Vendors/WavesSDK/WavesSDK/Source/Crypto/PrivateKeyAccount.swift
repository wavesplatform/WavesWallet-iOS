//
//  PrivateKeyAccount.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 10/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import Curve25519
import Base58

public class Address {
    static let AddressVersion: UInt8 = 1
    static let ChecksumLength = 4
    static let HashLength = 20
    static let AddressLength = 1 + 1 + HashLength + ChecksumLength

    public class func getSchemeByte() -> UInt8 {
        return Environment.current.scheme.utf8.first!
    }
    
    public class func addressFromPublicKey(publicKey: [UInt8]) -> String {
        let publicKeyHash = Hash.secureHash(publicKey)[0..<HashLength]
        let withoutChecksum: [UInt8] = [AddressVersion, getSchemeByte()] + publicKeyHash
        return Base58.encode(withoutChecksum + calcCheckSum(withoutChecksum))
    }
    
    public class func calcCheckSum(_ withoutChecksum: [UInt8]) -> [UInt8] {
        return Array(Hash.secureHash(withoutChecksum)[0..<ChecksumLength])
    }
    
    public class func isValidAlias(alias: String?) -> Bool {
        guard let alias = alias else { return false }
        
        return RegEx.alias(alias) &&
            alias.count >= GlobalConstants.aliasNameMinLimitSymbols &&
            alias.count <= GlobalConstants.aliasNameMaxLimitSymbols
    }
    
    public class func isValidAddress(address: String?) -> Bool {
        guard let address = address else { return false }
        
        let bytes = Base58.decode(address)
        if bytes.count == AddressLength
            && bytes[0] == AddressVersion
            && bytes[1] == getSchemeByte() {
                let checkSum = Array(bytes[bytes.count - ChecksumLength..<bytes.count])
                let checkSumGenerated = calcCheckSum(Array(bytes[0..<bytes.count - ChecksumLength]))
                return checkSum == checkSumGenerated
        }
        return false
    }

    public class func scheme(from publicKey: String) -> String? {

        let address = Address.addressFromPublicKey(publicKey: publicKey.bytes)
        let bytes = Base58.decode(address)
        guard bytes.count == AddressLength else { return nil }
        guard bytes[0] == AddressVersion else { return nil }
        let schemeBytes = bytes[1]
        let data = Data(bytes: [schemeBytes])
        guard let scheme = String(data: data, encoding: .utf8) else { return nil }

        return scheme
    }
}

public class PublicKeyAccount: Hashable {

    public let publicKey: [UInt8]
    public let address: String
    
    public init(publicKey: [UInt8]) {
        self.publicKey = publicKey
        self.address = Address.addressFromPublicKey(publicKey: publicKey)
    }

    public convenience init(publicKey: String) {
        self.init(publicKey: Base58.decode(publicKey))
    }
    
    public func getPublicKeyStr() -> String {
        return Base58.encode(publicKey)
    }

    public var hashValue: Int {
        return address.hashValue
    }

    public static func == (lhs: PublicKeyAccount, rhs: PublicKeyAccount) -> Bool {
        return lhs.address == rhs.address
    }
}

public class PrivateKeyAccount: PublicKeyAccount {
    
    public let privateKey: [UInt8]
    public let seed: [UInt8]
    
    public init(seed: [UInt8]) {
        self.seed = seed
        let nonce : [UInt8] = [0, 0, 0, 0]
        let hashSeed = Hash.sha256(Hash.secureHash(nonce + seed))
        let pair = Curve25519.generateKeyPair(Data(hashSeed))!
        privateKey = Array(pair.privateKey())
        super.init(publicKey: Array(pair.publicKey()))
    }

    public var privateKeyStr: String {
        return Base58.encode(privateKey)
    }

    public var words: [String] {
        return String(data: Data(seed), encoding: .utf8)?.components(separatedBy: " ") ?? []
    }
    
    public var wordsStr: String {
        return String(data: Data(seed), encoding: .utf8) ?? ""
    }
    
    public convenience init(seedStr: String) {
        self.init(seed: Array(seedStr.utf8))
    }
}

