//
//  UIFeedbackGenerator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

enum ImpactFeedbackGenerator {
    static func impactOccurred() {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        }
    }
}
