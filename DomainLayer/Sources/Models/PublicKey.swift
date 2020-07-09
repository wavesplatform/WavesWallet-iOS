//
//  PublicKeyAccount.swift
//  Base58
//
//  Created by rprokofev on 11/04/2019.
//

import Foundation
import WavesSDKCrypto

public extension DomainLayer.DTO {

    class PublicKey: Hashable {
        
        public let publicKey: [UInt8]
        public let address: String
        
        public init(publicKey: [UInt8], enviromentKind: WalletEnvironment.Kind) {
            self.publicKey = publicKey
            self.address = AddressValidator.addressFromPublicKey(publicKey: publicKey,
                                                                 environmentKind: enviromentKind)
        }
        
        public convenience init(publicKey: String, enviromentKind: WalletEnvironment.Kind) {
            self.init(publicKey: Base58Encoder.decode(publicKey), enviromentKind: enviromentKind)
        }
        
        public func getPublicKeyStr() -> String {
            return Base58Encoder.encode(publicKey)
        }
        
        public var hashValue: Int {
            return address.hashValue
        }
        
        public static func == (lhs: DomainLayer.DTO.PublicKey, rhs: DomainLayer.DTO.PublicKey) -> Bool {
            return lhs.address == rhs.address
        }
    }
}
