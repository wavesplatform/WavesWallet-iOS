//
//  Thread+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension Thread {

    static func threadSharedObject<T: AnyObject>(key: String, create: () -> T) -> T {
        if let cachedObj = Thread.current.threadDictionary[key] as? T {
            return cachedObj
        } else {
            let newObject = create()
            Thread.current.threadDictionary[key] = newObject
            return newObject
        }
    }
}
