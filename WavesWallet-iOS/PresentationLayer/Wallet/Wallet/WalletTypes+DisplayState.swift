//
//  WalletTypes+DisplayState.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

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

    static func initialState(display: WalletTypes.Display) -> WalletTypes.State.DisplayState {
        var section: WalletTypes.ViewModel.Section!
        if display == .assets {
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

// MARK: Get Methods

extension WalletTypes.State.AnimateType {
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
