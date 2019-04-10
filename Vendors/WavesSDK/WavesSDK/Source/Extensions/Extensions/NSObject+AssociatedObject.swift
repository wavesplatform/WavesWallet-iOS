//
//  NSObject+AssociatedObject.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 10/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension NSObject {

    func associatedObject<T>(for key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }

    func setAssociatedObject<T>(_ object: T, for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
