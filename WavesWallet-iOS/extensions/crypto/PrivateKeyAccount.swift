//
//  PrivateKeyAccount.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 10/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import _25519

class Address {
    static let AddressVersion: UInt8 = 1
    static let ChecksumLength = 4
    static let HashLength = 20
    static let AddressLength = 1 + 1 + HashLength + ChecksumLength

    class func getSchemeByte() -> UInt8 {
        return Environments.current.scheme.utf8.first!
    }
    
    class func addressFromPublicKey(publicKey: [UInt8]) -> String {
        let publicKeyHash = Hash.secureHash(publicKey)[0..<HashLength]
        let withoutChecksum: [UInt8] = [AddressVersion, getSchemeByte()] + publicKeyHash
        return Base58.encode(withoutChecksum + calcCheckSum(withoutChecksum))
    }
    
    class func calcCheckSum(_ withoutChecksum: [UInt8]) -> [UInt8] {
        return Array(Hash.secureHash(withoutChecksum)[0..<ChecksumLength])
    }
    
    class func isValidAlias(alias: String?) -> Bool {
        guard let alias = alias else { return false }
        
        return RegEx.alias(alias) &&
            alias.count >= GlobalConstants.aliasNameMinLimitSymbols &&
            alias.count <= GlobalConstants.aliasNameMaxLimitSymbols
    }
    
    class func isValidAddress(address: String?) -> Bool {
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

    class func scheme(from publicKey: String) -> String? {

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

class PublicKeyAccount: Hashable {

    let publicKey: [UInt8]
    let address: String
    
    init(publicKey: [UInt8]) {
        self.publicKey = publicKey
        self.address = Address.addressFromPublicKey(publicKey: publicKey)
    }

    convenience init(publicKey: String) {
        self.init(publicKey: Base58.decode(publicKey))
    }
    
    func getPublicKeyStr() -> String {
        return Base58.encode(publicKey)
    }

    public var hashValue: Int {
        return address.hashValue
    }

    public static func == (lhs: PublicKeyAccount, rhs: PublicKeyAccount) -> Bool {
        return lhs.address == rhs.address
    }
}

class PrivateKeyAccount: PublicKeyAccount {
    
    let privateKey: [UInt8]
    let seed: [UInt8]
    
    init(seed: [UInt8]) {
        self.seed = seed
        let nonce : [UInt8] = [0, 0, 0, 0]
        let hashSeed = Hash.sha256(Hash.secureHash(nonce + seed))
        let pair = Curve25519.generateKeyPair(Data(hashSeed))!
        privateKey = Array(pair.privateKey())
        super.init(publicKey: Array(pair.publicKey()))
    }

    var privateKeyStr: String {
        return Base58.encode(privateKey)
    }

    var words: [String] {
        return String(data: Data(seed), encoding: .utf8)?.components(separatedBy: " ") ?? []
    }
    
    var wordsStr: String {
        return String(data: Data(seed), encoding: .utf8) ?? ""
    }
    
    convenience init(seedStr: String) {
        self.init(seed: Array(seedStr.utf8))
    }
}

