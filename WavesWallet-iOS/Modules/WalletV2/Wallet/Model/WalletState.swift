//
//  WalletState.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import UIKit
import WavesSDKExtensions

struct WalletState: Mutating {
    enum Action {
        case none
        case refreshError
        case update
    }

    var assets: [DomainLayer.DTO.SmartAssetBalance]
    var displayState: WalletDisplayState
    var isHasAppUpdate: Bool
    var action: Action
}

extension WalletState {
    static func initialState(kind: WalletDisplayState.Kind) -> WalletState {
        return WalletState(assets: [],
                           displayState: .initialState(kind: kind),
                           isHasAppUpdate: false,
                           action: .none)
    }

    func changeDisplay(state: inout WalletState, kind: WalletDisplayState.Kind) {
        var display: WalletDisplayState.Display!

        switch kind {
        case .assets:
            display = state.displayState.assets
        }

        display.animateType = .refresh(animated: false)

        state.displayState.kind = kind
        state.displayState = state.displayState.updateCurrentDisplay(display)
    }

    var hasData: Bool {
        switch displayState.kind {
        case .assets:
            return !assets.isEmpty
        }
    }
}
