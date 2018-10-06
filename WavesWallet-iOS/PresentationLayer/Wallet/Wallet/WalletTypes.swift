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

    struct DisplayState: Mutating {

        enum Kind {
            case assets
            case leasing
        }

        //TODO: Rename to Action
        enum AnimateType  {
            case refresh
            case collapsed(Int)
            case expanded(Int)
        }

        struct Display: Mutating {
            var sections: [ViewModel.Section]
            var collapsedSections: [Int: Bool]
            var isRefreshing: Bool
            var animateType: AnimateType = .refresh
        }

        var kind: Kind
        var assets: DisplayState.Display
        var leasing: DisplayState.Display
        var isAppeared: Bool
    }

    struct State: Mutating {

        var assets: [WalletTypes.DTO.Asset]
        var displayState: DisplayState
    }

    enum Event {
        case setAssets([DTO.Asset])
        case setLeasing(DTO.Leasing)
        case refresh
        case readyView
        case tapRow(IndexPath)
        case tapSection(Int)
        case tapSortButton
        case tapAddressButton
        case changeDisplay(DisplayState.Kind)
        case showStartLease(Money)
    }
}
