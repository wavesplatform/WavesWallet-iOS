//
//  Array+Hashable.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

#if swift(>=4.2)
#else
extension Array: Hashable where Element: Hashable {
    public var hashValue: Int {
        return reduce(5381) {
            ($0 << 5) &+ $0 &+ $1.hashValue
        }
    }
}
#endif
