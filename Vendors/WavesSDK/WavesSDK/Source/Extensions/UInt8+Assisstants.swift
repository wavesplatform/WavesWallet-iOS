//
//  UInt8+Byte.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return (withUnsafeBytes(of: &value) { Array($0) }).reversed()
}
