//
//  WalletTypes+State.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 15/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension WalletTypes.State {

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

    var visibleSections: [WalletTypes.ViewModel.Section] {
        return currentDisplayState.visibleSections
    }

    var animateType: WalletTypes.AnimateType {
        return currentDisplayState.animateType
    }

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

    static func initialState() -> WalletTypes.State {
        return WalletTypes.State(display: .assets,
                                 assets: WalletTypes.State.DisplayState.initialState(),
                                 leasing: WalletTypes.State.DisplayState.initialState())
    }
}

extension WalletTypes.State.DisplayState {

    var visibleSections: [WalletTypes.ViewModel.Section] {
        return sections.enumerated().map { element -> WalletTypes.ViewModel.Section in
            var newSection = element.element
            if collapsedSections[element.offset] == true {
                newSection.isExpanded = false
                newSection.items = [.hidden]
            } else {
                newSection.isExpanded = true
            }
            return newSection
        }
    }

    static func initialState() -> WalletTypes.State.DisplayState {
        return .init(sections: [], collapsedSections: [:], isRefreshing: false, animateType: .refresh)
    }

    func toggleCollapse(index: Int) -> WalletTypes.State.DisplayState {
        var newState = self
        let isCollapsed = newState.collapsedSections[index] ?? false
        let newIsCollapsed = !isCollapsed
        newState.collapsedSections[index] = newIsCollapsed
        if newIsCollapsed {
            newState.animateType = .collapsed(index)
        } else {
            newState.animateType = .expanded(index)
        }
        return newState
    }
}

extension WalletTypes.State {

    static func mutate(_ mutation: @escaping (inout WalletTypes.State) -> ()) -> (WalletTypes.State) -> WalletTypes.State {
        return { state in
            var newState = state
            mutation(&newState)
            return newState
        }
    }
}
