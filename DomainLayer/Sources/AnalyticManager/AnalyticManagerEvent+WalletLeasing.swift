//
//  WalletLeasing.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

//MARK: - Leasing
public extension AnalyticManagerEvent {
    enum WalletLeasing: String {
        
        /* Нажата кнопка «Start Lease» на экране Wallet. */
        case leasingStartTap = "Leasing Start Tap"
        
        /* Нажата кнопка «Start Lease» на экране с заполненными полями. */
        case leasingSendTap = "Leasing Send Tap"
        
        /* Нажата кнопка «Confirm» на экране подтверждения лизинга. */
        case leasingConfirmTap = "Leasing Confirm Tap"
    }
}
