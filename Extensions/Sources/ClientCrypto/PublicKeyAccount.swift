//
//  PublicKeyAccount.swift
//  Base58
//
//  Created by rprokofev on 11/04/2019.
//

import Foundation
import Curve25519
import Base58

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
