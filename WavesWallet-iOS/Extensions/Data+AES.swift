//
//  Data+AES.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 23/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import CryptoSwift
import Foundation
import Base58

fileprivate enum Constants {
    static let iterations: Int = 5000
    static let keyLength: Int = 32
}

extension Data {

    func aesEncrypt(withKey key: String) -> Data? {

        let iv: Array<UInt8> = AES.randomIV(AES.blockSize)
        let keyBytes = try! PKCS5.PBKDF2(password: key.bytes,
                                         salt: iv,
                                         iterations: Constants.iterations,
                                         keyLength: Constants.keyLength,
                                         variant: .sha256).calculate()

        do {
            let aes = try AES(key: keyBytes, blockMode: CBC(iv: iv))
            let encrypt = try aes.encrypt(self.bytes)

            var combine = [UInt8]()
            combine.append(contentsOf: iv)
            combine.append(contentsOf: encrypt)
            return Base58.encode(combine).data(using: .utf8)
        } catch _ {
            return nil
        }
    }

    func aesDecrypt(withKey key: String) -> Data? {

        guard let stringFromData =  String(data: self, encoding: .utf8) else { return nil }

        let dataBase58 =  Base58.decode(stringFromData)

        let iv: Array<UInt8> = Array(dataBase58[0..<AES.blockSize])

        let keyBytes = try! PKCS5.PBKDF2(password: key.bytes,
                                     salt: iv,
                                     iterations: 5000,
                                     keyLength: 32,
                                     variant: .sha256).calculate()
        do {

            let aes = try AES(key: keyBytes, blockMode: CBC(iv: iv))
            let dataBytes = dataBase58[AES.blockSize..<dataBase58.count]
            let decrypt = try aes.decrypt(dataBytes)

            return Data(bytes: decrypt)

        } catch let error {
            print(error)
        }

        return nil
    }
}

extension String {

    func aesEncrypt(withKey key: String) -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        guard let  encrypt = data.aesEncrypt(withKey: key) else { return nil }

        return String(data: encrypt, encoding: .utf8)
    }

    func aesDecrypt(withKey key: String) -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        guard let  decrypt = data.aesDecrypt(withKey: key) else { return nil }

        return String(data: decrypt, encoding: .utf8)
    }
}
