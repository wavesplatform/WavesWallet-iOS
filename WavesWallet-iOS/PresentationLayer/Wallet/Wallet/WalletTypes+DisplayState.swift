//
//  WalletTypes+DisplayState.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension WalletTypes.DisplayState {

    static func initialState(kind: WalletTypes.DisplayState.Kind) -> WalletTypes.DisplayState {
        return WalletTypes.DisplayState(kind: kind,
                                        assets: .initialState(kind: .assets),
                                        leasing: .initialState(kind: .leasing),
                                        isAppeared: false)
    }

    var currentDisplay: WalletTypes.DisplayState.Display {
        switch kind {
        case .assets:
            return assets

        case .leasing:
            return leasing
        }
    }

    func updateCurrentDisplay(_ display: WalletTypes.DisplayState.Display) -> WalletTypes.DisplayState {
        var newState = self
        switch kind {
        case .assets:
            newState.assets = display
        case .leasing:
            newState.leasing = display
        }
        return newState
    }
}


// TODO: Get Methods

extension WalletTypes.DisplayState {

    var visibleSections: [WalletTypes.ViewModel.Section] {
        return currentDisplay.visibleSections
    }

    var animateType: WalletTypes.DisplayState.AnimateType {
        return currentDisplay.animateType
    }

    var isRefreshing: Bool {
        return currentDisplay.isRefreshing
    }
}

// TODO: Set Methods

extension WalletTypes.DisplayState {

    func toggleCollapse(index: Int) -> WalletTypes.DisplayState {
        let display = currentDisplay.toggleCollapse(index: index)
        return updateCurrentDisplay(display)
    }

    func setIsAppeared(_ isAppeared: Bool) -> WalletTypes.DisplayState {
        var newState = self
        newState.isAppeared = isAppeared
        return newState
    }

    func setIsRefreshing(isRefreshing: Bool) -> WalletTypes.DisplayState {
        var display = currentDisplay
        display.isRefreshing = isRefreshing
        return updateCurrentDisplay(display)
    }

    func setAssets(assets: WalletTypes.DisplayState.Display) -> WalletTypes.DisplayState {
        var newState = self
        newState.assets = assets
        return newState
    }

    func setLeasing(leasing: WalletTypes.DisplayState.Display) -> WalletTypes.DisplayState {
        var newState = self
        newState.leasing = leasing
        return newState
    }

    func updateDisplay(kind: WalletTypes.DisplayState.Kind, sections: [WalletTypes.ViewModel.Section]) -> WalletTypes.DisplayState {

        let display = kind == .assets ? assets : leasing
        
        var collapsedSections = display.collapsedSections
        sections.enumerated().forEach {
            if collapsedSections[$0.offset] == nil {
                collapsedSections[$0.offset] = !$0.element.isExpanded
            }
        }

        let newDisplay = WalletTypes.DisplayState.Display(sections: sections,
                                                          collapsedSections: collapsedSections,
                                                          isRefreshing: false,
                                                          animateType: .refresh)

        return mutate {
            if kind == .assets {
                $0.assets = newDisplay
            } else {
                $0.leasing = newDisplay
            }
        }
    }
}

extension WalletTypes.DisplayState.Display {
    
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

    static func initialState(kind: WalletTypes.DisplayState.Kind) -> WalletTypes.DisplayState.Display {
        var section: WalletTypes.ViewModel.Section!
        if kind == .assets {
            section = WalletTypes.ViewModel.Section(header: nil,
                                                    items: [.assetSkeleton,
                                                            .assetSkeleton,
                                                            .assetSkeleton,
                                                            .assetSkeleton,
                                                            .assetSkeleton],
                                                    isExpanded: true)
        } else {
            section = WalletTypes.ViewModel.Section(header: nil,
                                                    items: [.balanceSkeleton,
                                                            .historySkeleton],
                                                    isExpanded: true)
        }

        return .init(sections: [section],
                     collapsedSections: [:],
                     isRefreshing: false,                     
                     animateType: .refresh)
    }

    func toggleCollapse(index: Int) -> WalletTypes.DisplayState.Display {
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

// MARK: Get Methods

extension WalletTypes.DisplayState.AnimateType {
    
    var isRefresh: Bool {
        switch self {
        case .refresh:
            return true
        default:
            return false
        }
    }

    var isCollapsed: Bool {
        switch self {
        case .collapsed:
            return true
        default:
            return false
        }
    }

    var isExpanded: Bool {
        switch self {
        case .expanded:
            return true
        default:
            return false
        }
    }

    var sectionIndex: Int? {
        switch self {
        case .expanded(let section):
            return section
        case .collapsed(let section):
            return section
        default:
            return nil
        }
    }
}
