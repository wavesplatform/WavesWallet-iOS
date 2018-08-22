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

extension WalletTypes {
    enum ViewModel {}
    enum DTO {}
}

extension WalletTypes {
    enum Display {
        case assets
        case leasing
    }

    struct State: Mutating {
        //TODO: Rename
        enum AnimateType  {
            case refresh
            case collapsed(Int)
            case expanded(Int)
        }

        struct DisplayState: Mutating {
            var sections: [ViewModel.Section]
            var collapsedSections: [Int: Bool]
            var isRefreshing: Bool
            var animateType: AnimateType = .refresh
        }

        var display: Display
        var assets: DisplayState
        var leasing: DisplayState
        var isAppeared: Bool
    }

    enum Event {
        //TODO: Rename
        case responseAssets([DTO.Asset])
        //TODO: Rename
        case responseLeasing(DTO.Leasing)
        case refresh
        case readyView
        case tapRow(IndexPath)
        case tapSection(Int)
        case tapSortButton
        case tapAddressButton
        case changeDisplay(Display)
    }
}
