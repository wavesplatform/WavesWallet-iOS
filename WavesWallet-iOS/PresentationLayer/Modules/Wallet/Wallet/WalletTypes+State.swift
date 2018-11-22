//
//  WalletTypes+State.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 15/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation


extension WalletTypes.State {

    static func initialState() -> WalletTypes.State {
        return WalletTypes.State(assets: [],
                                 displayState: .initialState(kind: .assets))
    }

    func changeDisplay(kind: WalletTypes.DisplayState.Kind) -> WalletTypes.State {
        
        var newState = self

        var display: WalletTypes.DisplayState.Display!

        switch kind {
        case .assets:
            display = newState.displayState.assets
        case .leasing:
            display = newState.displayState.leasing
        }

        display.animateType = .refresh(animated: false)

        newState.displayState.kind = kind
        newState.displayState = newState.displayState.updateCurrentDisplay(display)

        return newState
    }
}
