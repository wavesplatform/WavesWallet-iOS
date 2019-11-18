//
//  CGFloat+Min.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit

public extension CGFloat {
    public static var minValue: CGFloat {
        if #available(iOS 11.0, *) {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return CGFloat.leastNonzeroMagnitude
        }
    }
}
