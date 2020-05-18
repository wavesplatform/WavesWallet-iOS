////
////  DisplayState.swift
////  WavesWallet-iOS
////
////  Created by rprokofev on 18.05.2020.
////  Copyright © 2020 Waves Platform. All rights reserved.
////
//
//import DomainLayer
//import Extensions
//import Foundation
//import RxCocoa
//import UIKit
//import WavesSDKExtensions
//
//struct InvestmentDisplayState: Mutating {
//    enum RefreshData: Equatable {
//        case none
//        case update
//        case refresh
//    }
//
//    enum Kind: Int {
//        case assets
//        case leasing
//        case staking
//    }
//
//    enum ContentAction {
//        case refresh(animated: Bool)
//        case refreshOnlyError
//        case collapsed(Int)
//        case expanded(Int)
//        case none
//    }
//
//    struct Display: Mutating {
//        var sections: [InvestmentSection]
//        var collapsedSections: [Int: Bool]
//        var isRefreshing: Bool
//        var animateType: ContentAction = .refresh(animated: false)
//        var errorState: DisplayErrorState
//    }
//
//    var kind: Kind
//    var assets: InvestmentDisplayState.Display
//    var leasing: InvestmentDisplayState.Display
//    var staking: InvestmentDisplayState.Display
//    var isAppeared: Bool
//    var listenerRefreshData: RefreshData
//    var refreshData: RefreshData
//    var listnerSignal: Signal<InvestmentEvent>?
//}
//
//
