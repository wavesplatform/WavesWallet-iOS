//
//  Array+Sort.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/18/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation


extension Array {
    mutating func shuffle() {
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swapAt(i, j)
        }
    }
}
