//
//  Optional+Hashable.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

#if swift(>=4.2)
#else
public extension Optional: Sequence where Wrapped: Sequence {
    public typealias Element = Wrapped.Iterator.Element
    public typealias Iterator = AnyIterator<Wrapped.Iterator.Element>

    public func makeIterator() -> AnyIterator<Wrapped.Iterator.Element> {
        return self.map { AnyIterator($0.makeIterator()) }
            ?? AnyIterator(EmptyCollection().makeIterator())
    }
}
#endif
