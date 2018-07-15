//
//  WalletTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources
import UIKit

enum WalletTypes {}

extension WalletTypes {
    enum ViewModel {}
}

extension WalletTypes {

    enum Display {
        case assets
        case leasing
    }

    struct State {

        struct DisplayState {
            var sections: [ViewModel.Section]
            var collapsedSections: [Int: Bool]
            var isRefreshing: Bool
        }

        var display: Display = .assets
        var assets: DisplayState
        var leasing: DisplayState
    }

    enum Event {
        case none
        case responseAssets([AssetBalance])
        case refresh
        case readyView
        case tapSection(Int)
        case changeDisplay(Display)
    }
}
