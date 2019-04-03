//
//  CGSize.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

public extension CGSize: Hashable {
    public var hashValue: Int {
        return width.hashValue ^ height.hashValue
    }
}
