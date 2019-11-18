//
//  UIFeedbackGenerator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import AudioToolbox

public enum ImpactFeedbackGenerator {

    public static func impactOccurred() {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        }
    }

    public static func impactOccurredOrVibrate() {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}

