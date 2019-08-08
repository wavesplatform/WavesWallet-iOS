//
//  Mutating.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//
import Foundation

public protocol Mutating {
    func mutate(transform: (inout Self) -> ()) -> Self
}

public extension Mutating {
    func mutate(transform: (inout Self) -> ()) -> Self {
        var value = self
        transform(&value)
        return value
    }
}

public extension Array where Element: Mutating {

    func mutate(transform: (inout Element) -> ()) -> [Element] {
        return self.map({ element -> Element in
            return element.mutate(transform: { ref in
                transform(&ref)
            })
        })
    }
}
