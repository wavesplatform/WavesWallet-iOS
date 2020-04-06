//
//  Wallet+TSUD.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 26.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions

/// Структура предназначена для понимания нужно ли показывать лендинг (true - нужно показать, false показать не нужно)
struct WalletLandingSetting: TSUD {
            
    static var defaultValue: [String: Bool] = [:]
    
    typealias ValueType = [String: Bool]
}

