//
//  ArrayExtension.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 26/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

public extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
