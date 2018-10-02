//
//  Base58.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 04/05/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import base58

class Base58 {
    class func encode(_ input: [UInt8]) -> String {
        var size = Int(ceil(log(256.0)/log(58)*Double(input.count))) + 1
        var data = Data(count: size)
        data.withUnsafeMutableBytes {(bytes: UnsafeMutablePointer<Int8>)->Void in
            b58enc(bytes, &size, input, input.count)
        }
        let r = data.subdata(in: 0..<(size - 1))
        //TODO: isoLatin1 ? WTF?
        return String(data: r, encoding: .utf8) ?? ""
    }
    
    class func decode(_ str: String) -> [UInt8] {
        guard validate(str) else { return [] }
        
        let c = Array(str.utf8).map{ Int8($0) }
        let csize = Int(ceil(Double(c.count)*log(58.0)/log(256.0)))
        var data = Data(count: csize)
        var size = csize
        data.withUnsafeMutableBytes {(bytes: UnsafeMutablePointer<Int8>)->Void in
            b58tobin(bytes, &size, c, c.count)
        }
        let r = data.subdata(in: (csize - size)..<csize)
        return Array(r)
    }
    
    class func decodeToStr(_ str: String) -> String {
         return String(data: Data(decode(str)), encoding: .utf8) ?? ""
    }
    
    static let Alphabet = CharacterSet(charactersIn: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
    static let WrongAlphabet = Alphabet.inverted
    
    class func validate(_ str: String) -> Bool {
        return str.rangeOfCharacter(from: WrongAlphabet) == nil
    }
}
