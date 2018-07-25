//
//  WalletTypes+State.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 15/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

fileprivate extension WalletTypes.State {
    var currentDisplayState: WalletTypes.State.DisplayState {
        switch display {
        case .assets:
            return assets

        case .leasing:
            return leasing
        }
    }

    func updateCurrentDisplay(state: DisplayState) -> WalletTypes.State {
        var newState = self
        switch display {
        case .assets:
            newState.assets = state

        case .leasing:
            newState.leasing = state
        }
        return newState
    }
}

// TODO: Get Methods

extension WalletTypes.State {
    var visibleSections: [WalletTypes.ViewModel.Section] {
        return currentDisplayState.visibleSections
    }

    var animateType: AnimateType {
        return currentDisplayState.animateType
    }

    var isRefreshing: Bool {
        return currentDisplayState.isRefreshing
    }
}

// TODO: Set Methods

extension WalletTypes.State {
    func toggleCollapse(index: Int) -> WalletTypes.State {
        let displayState = currentDisplayState.toggleCollapse(index: index)
        return updateCurrentDisplay(state: displayState)
    }

    func setIsRefreshing(isRefreshing: Bool) -> WalletTypes.State {
        var displayState = currentDisplayState
        displayState.isRefreshing = isRefreshing
        return updateCurrentDisplay(state: displayState)
    }

    func setAssets(assets: DisplayState) -> WalletTypes.State {
        var newState = self
        newState.assets = assets
        return newState
    }

    func setLeasing(leasing: DisplayState) -> WalletTypes.State {
        var newState = self
        newState.leasing = leasing
        return newState
    }

    func setDisplay(display: WalletTypes.Display) -> WalletTypes.State {
        var newState = self
        newState.display = display
        var displayState = newState.currentDisplayState
        displayState.animateType = .refresh
        return newState.updateCurrentDisplay(state: displayState)
    }
}

extension WalletTypes.State {
    static func initialState() -> WalletTypes.State {
        return WalletTypes.State(display: .assets,
                                 assets: .initialState(display: .assets),
                                 leasing: .initialState(display: .leasing))
    }
}
