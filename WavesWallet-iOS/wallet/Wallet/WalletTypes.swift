//
//  WalletTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

enum WalletTypes {}

// MARK: Models
struct AssetViewModel {

    enum Kind {
        case gateway
        case fiatMoney
        case wavesToken
    }

    enum State {
        case none
        case favorite
        case hidden
        case spam
    }

    let name: String
    let icon: UIImage
    let balance: Money
    let king: Kind
    let state: State
}
