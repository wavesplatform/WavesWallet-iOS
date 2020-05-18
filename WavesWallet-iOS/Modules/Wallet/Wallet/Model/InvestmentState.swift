//
//  InvestmentState.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 18.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import UIKit
import WavesSDKExtensions

struct InvestmentState: Mutating {
    enum Action {
        case none
        case refreshError
        case update
    }

    var assets: [DomainLayer.DTO.SmartAssetBalance]
    var leasing: InvestmentLeasingVM?
    var staking: InvestmentStakingVM?
    var prevStaking: InvestmentStakingVM?
    var displayState: InvestmentDisplayState
    var isShowCleanWalletBanner: Bool
    var isNeedCleanWalletBanner: Bool
    var isHasAppUpdate: Bool
    var action: Action
    var hasSkipLanding: Bool
}

extension InvestmentState {
    static func initialState(kind: InvestmentDisplayState.Kind) -> InvestmentState {
        return InvestmentState(assets: [],
                                 leasing: nil,
                                 displayState: .initialState(kind: kind),
                                 isShowCleanWalletBanner: false,
                                 isNeedCleanWalletBanner: false,
                                 isHasAppUpdate: false,
                                 action: .none,
                                 hasSkipLanding: false)
    }

    func changeDisplay(state: inout InvestmentState, kind: InvestmentDisplayState.Kind) {
        var display: InvestmentDisplayState.Display!

        switch kind {
        case .assets:
            display = state.displayState.assets
        case .leasing:
            display = state.displayState.leasing
        case .staking:
            display = state.displayState.staking
        }

        display.animateType = .refresh(animated: false)

        state.displayState.kind = kind
        state.displayState = state.displayState.updateCurrentDisplay(display)
    }

    var hasData: Bool {
        switch displayState.kind {
        case .assets:
            return !assets.isEmpty

        case .leasing:
            return leasing != nil

        case .staking:
            return staking != nil
        }
    }
}
