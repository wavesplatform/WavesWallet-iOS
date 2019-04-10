//
//  String+UInt.swift
//  Base58
//
//  Created by rprokofev on 10/04/2019.
//

import Foundation

public extension String {
    func toUInt() -> UInt? {
        let scanner = Scanner(string: self)
        var u: UInt64 = 0
        if scanner.scanUnsignedLongLong(&u)  && scanner.isAtEnd {
            return UInt(u)
        }
        return nil
    }
}
