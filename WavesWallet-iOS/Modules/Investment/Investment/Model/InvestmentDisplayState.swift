//
//  InvestmentDisplayState.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 18.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions
import Foundation
import RxCocoa
import UIKit
import WavesSDKExtensions

struct InvestmentDisplayState: Mutating {
    enum RefreshData: Equatable {
        case none
        case update
        case refresh
    }

    enum Kind: Int {
        case leasing
        case staking
    }

    enum ContentAction {
        case refresh(animated: Bool)
        case refreshOnlyError
        case collapsed(Int)
        case expanded(Int)
        case none
    }

    struct Display: Mutating {
        var sections: [InvestmentSection]
        var collapsedSections: [Int: Bool]
        var isRefreshing: Bool
        var animateType: ContentAction = .refresh(animated: false)
        var errorState: DisplayErrorState
    }

    var kind: Kind
    var leasing: InvestmentDisplayState.Display
    var staking: InvestmentDisplayState.Display
    var isAppeared: Bool
    var listenerRefreshData: RefreshData
    var refreshData: RefreshData
    var listnerSignal: Signal<InvestmentEvent>?
}

extension InvestmentDisplayState {
    static func initialState(kind: InvestmentDisplayState.Kind) -> InvestmentDisplayState {
        return InvestmentDisplayState(kind: kind,
                                      leasing: .initialState(kind: .leasing),
                                      staking: .initialState(kind: .staking),
                                      isAppeared: false,
                                      listenerRefreshData: .none,
                                      refreshData: .refresh,
                                      listnerSignal: nil)
    }

    var currentDisplay: InvestmentDisplayState.Display {
        get {
            switch kind {
            case .leasing:
                return leasing

            case .staking:
                return staking
            }
        }

        set {
            switch kind {
            case .leasing:
                leasing = newValue

            case .staking:
                staking = newValue
            }
        }
    }

    func updateCurrentDisplay(_ display: InvestmentDisplayState.Display) -> InvestmentDisplayState {
        var newState = self
        switch kind {
        case .leasing:
            newState.leasing = display
        case .staking:
            newState.staking = display
        }
        return newState
    }
}

// MARK: Get Methods

extension InvestmentDisplayState {
    var visibleSections: [InvestmentSection] {
        return currentDisplay.visibleSections
    }

    var animateType: InvestmentDisplayState.ContentAction {
        return currentDisplay.animateType
    }

    var isRefreshing: Bool {
        return currentDisplay.isRefreshing
    }
}

// MARK: Set Methods

extension InvestmentDisplayState {
    func toggleCollapse(index: Int) -> InvestmentDisplayState {
        let display = currentDisplay.toggleCollapse(index: index)
        return updateCurrentDisplay(display)
    }

    func setIsRefreshing(isRefreshing: Bool) -> InvestmentDisplayState {
        var display = currentDisplay
        display.isRefreshing = isRefreshing
        return updateCurrentDisplay(display)
    }

    func updateDisplay(kind: InvestmentDisplayState.Kind, sections: [InvestmentSection]) -> InvestmentDisplayState {
        let display: InvestmentDisplayState.Display

        switch kind {
        case .leasing:
            display = leasing

        case .staking:
            display = staking
        }

        var collapsedSections = display.collapsedSections
        sections.enumerated().forEach {
            if collapsedSections[$0.offset] == nil {
                collapsedSections[$0.offset] = !$0.element.isExpanded
            }
        }

        let newDisplay = InvestmentDisplayState.Display(sections: sections,
                                                        collapsedSections: collapsedSections,
                                                        isRefreshing: false,
                                                        animateType: .refresh(animated: false),
                                                        errorState: .none)

        return mutate {
            if kind == .leasing {
                $0.leasing = newDisplay
            } else if kind == .staking {
                $0.staking = newDisplay
            }
        }
    }
}

extension InvestmentDisplayState.Display {
    var visibleSections: [InvestmentSection] {
        return sections.enumerated().map { element -> InvestmentSection in
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

    static func initialState(kind: InvestmentDisplayState.Kind) -> InvestmentDisplayState.Display {
        let sections = skeletonSections(kind: kind)

        return .init(sections: sections,
                     collapsedSections: [:],
                     isRefreshing: false,
                     animateType: .refresh(animated: false),
                     errorState: .none)
    }

    static func skeletonSections(kind: InvestmentDisplayState.Kind) -> [InvestmentSection] {
        var section: InvestmentSection!
        if kind == .leasing {
            section = InvestmentSection(kind: .skeleton,
                                        items: [.balanceSkeleton,
                                                .historySkeleton],
                                        isExpanded: true)
        } else if kind == .staking {
            section = InvestmentSection(kind: .skeleton,
                                        items: [.balanceSkeleton,
                                                .historySkeleton],
                                        isExpanded: true)
        }
        return [section]
    }

    func toggleCollapse(index: Int) -> InvestmentDisplayState.Display {
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

extension InvestmentDisplayState.ContentAction {
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

extension InvestmentDisplayState.Kind {
    var name: String {
        switch self {        
        case .leasing:
            return Localizable.Waves.Wallet.Segmentedcontrol.leasing
        case .staking:
            return Localizable.Waves.Wallet.Segmentedcontrol.staking
        }
    }
}
