//
//  Data.swift
//  Extensions
//
//  Created by rprokofev on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public extension Data {

    init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }

    func toArray<T>(type: T.Type) -> [T] {
        let value = self.withUnsafeBytes {
            $0.baseAddress?.assumingMemoryBound(to: T.self)
        }
        return [T](UnsafeBufferPointer(start: value, count: self.count / MemoryLayout<T>.stride))
    }
}
