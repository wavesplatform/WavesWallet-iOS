//
//  WalletDisplayState.swift
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

struct WalletDisplayState: Mutating {
    enum RefreshData: Equatable {
        case none
        case update
        case refresh
    }

    enum Kind: Int {
        case assets
    }

    enum ContentAction {
        case refresh(animated: Bool)
        case refreshOnlyError
        case collapsed(Int)
        case expanded(Int)
        case none
    }

    struct Display: Mutating {
        var sections: [WalletSectionVM]
        var collapsedSections: [Int: Bool]
        var isRefreshing: Bool
        var animateType: ContentAction = .refresh(animated: false)
        var errorState: DisplayErrorState
    }

    var kind: Kind
    var assets: WalletDisplayState.Display
    var isAppeared: Bool
    var listenerRefreshData: RefreshData
    var refreshData: RefreshData
    var listnerSignal: Signal<WalletEvent>?
}

extension WalletDisplayState {
    static func initialState(kind: WalletDisplayState.Kind) -> WalletDisplayState {
        return WalletDisplayState(kind: kind,
                                        assets: .initialState(kind: .assets),
                                        isAppeared: false,
                                        listenerRefreshData: .none,
                                        refreshData: .refresh,
                                        listnerSignal: nil)
    }

    var currentDisplay: WalletDisplayState.Display {
        get {
            switch kind {
            case .assets:
                return assets
            }
        }

        set {
            switch kind {
            case .assets:
                assets = newValue
            }
        }
    }

    func updateCurrentDisplay(_ display: WalletDisplayState.Display) -> WalletDisplayState {
        var newState = self
        switch kind {
        case .assets:
            newState.assets = display
        }
        return newState
    }
}

// MARK: Get Methods

extension WalletDisplayState {
    var visibleSections: [WalletSectionVM] {
        return currentDisplay.visibleSections
    }

    var animateType: WalletDisplayState.ContentAction {
        return currentDisplay.animateType
    }

    var isRefreshing: Bool {
        return currentDisplay.isRefreshing
    }
}

// MARK: Set Methods

extension WalletDisplayState {
    func toggleCollapse(index: Int) -> WalletDisplayState {
        let display = currentDisplay.toggleCollapse(index: index)
        return updateCurrentDisplay(display)
    }

    func setIsRefreshing(isRefreshing: Bool) -> WalletDisplayState {
        var display = currentDisplay
        display.isRefreshing = isRefreshing
        return updateCurrentDisplay(display)
    }

    func updateDisplay(kind: WalletDisplayState.Kind, sections: [WalletSectionVM]) -> WalletDisplayState {
        let display: WalletDisplayState.Display

        switch kind {
        case .assets:
            display = assets
        }

        var collapsedSections = display.collapsedSections
        sections.enumerated().forEach {
            if collapsedSections[$0.offset] == nil {
                collapsedSections[$0.offset] = !$0.element.isExpanded
            }
        }

        let newDisplay = WalletDisplayState.Display(sections: sections,
                                                    collapsedSections: collapsedSections,
                                                    isRefreshing: false,
                                                    animateType: .refresh(animated: false),
                                                    errorState: .none)

        return mutate {
            if kind == .assets {
                $0.assets = newDisplay
            }
        }
    }
}

extension WalletDisplayState.Display {
    var visibleSections: [WalletSectionVM] {
        return sections.enumerated().map { element -> WalletSectionVM in
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

    static func initialState(kind: WalletDisplayState.Kind) -> WalletDisplayState.Display {
        let sections = skeletonSections(kind: kind)

        return .init(sections: sections,
                     collapsedSections: [:],
                     isRefreshing: false,
                     animateType: .refresh(animated: false),
                     errorState: .none)
    }

    static func skeletonSections(kind: WalletDisplayState.Kind) -> [WalletSectionVM] {
        var section: WalletSectionVM!
        if kind == .assets {
            section = WalletSectionVM(kind: .skeleton,
                                      items: [.assetSkeleton,
                                              .assetSkeleton,
                                              .assetSkeleton,
                                              .assetSkeleton,
                                              .assetSkeleton],
                                      isExpanded: true)
        }
        return [section]
    }

    func toggleCollapse(index: Int) -> WalletDisplayState.Display {
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

extension WalletDisplayState.ContentAction {
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
        case let .expanded(section):
            return section
        case let .collapsed(section):
            return section
        default:
            return nil
        }
    }
}
