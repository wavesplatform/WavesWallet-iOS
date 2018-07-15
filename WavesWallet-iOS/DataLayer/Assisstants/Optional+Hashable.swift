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
extension Optional: Sequence where Wrapped: Sequence {
    public typealias Element = Wrapped.Iterator.Element
    public typealias Iterator = AnyIterator<Wrapped.Iterator.Element>

    public func makeIterator() -> AnyIterator<Wrapped.Iterator.Element> {
        return self.map { AnyIterator($0.makeIterator()) }
            ?? AnyIterator(EmptyCollection().makeIterator())
    }
}

extension Optional: Hashable where Wrapped: Hashable {
    public var hashValue: Int {
        switch self {
        case .none:
            return 0
        case .some(let v):
            return v.hashValue
        }
    }
}
#endif
