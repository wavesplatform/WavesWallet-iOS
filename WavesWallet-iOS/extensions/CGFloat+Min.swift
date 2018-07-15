//
//  CGFloat+Min.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    static var minValue: CGFloat {
        if #available(iOS 11.0, *) {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return 1.0 + CGFloat.leastNonzeroMagnitude
        }
    }
}
