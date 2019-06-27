//
//  TokenBurn.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

//MARK: - TokenBurn
public extension AnalyticManagerEvent {
    enum TokenBurn: String {
        
        /* Нажата кнопка «Token Burn» на экране ассета. */
        case tap = "Burn Token Tap"
        
        /* Нажата кнопка «Burn» на экране с заполненными полями. */
        case continueTap = "Burn Token Continue Tap"
        
        /* Нажата кнопка «Burn» на экране подтверждения. */
        case confirmTap = "Burn Token Confirm Tap"
    }
}
