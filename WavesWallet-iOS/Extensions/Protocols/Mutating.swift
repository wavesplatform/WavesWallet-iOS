//
//  Mutating.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol Mutating {
    func mutate(transform: (inout Self) -> ()) -> Self
}

extension Mutating {
    func mutate(transform: (inout Self) -> ()) -> Self {
        var value = self
        transform(&value)
        return value
    }
}

extension Array where Element: Mutating {

    func mutate(transform: (inout Element) -> ()) -> [Element] {
        return self.map({ element -> Element in
            return element.mutate(transform: { ref in
                transform(&ref)
            })
        })
    }
}
