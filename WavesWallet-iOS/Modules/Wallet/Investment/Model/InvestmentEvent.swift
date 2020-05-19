//
//  InvestmentEvent.swift
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

enum InvestmentEvent {
    case setAssets([DomainLayer.DTO.SmartAssetBalance])
    case setLeasing(InvestmentLeasingVM)
    case setStaking(InvestmentStakingVM)
    case handlerError(Error)
    case refresh
    case completedDepositBalance(balance: DomainLayer.DTO.Balance)
    case completedWithdrawBalance(balance: DomainLayer.DTO.Balance)
    case viewWillAppear
    case viewDidDisappear
    case tapRow(IndexPath)
    case tapSection(Int)
    case tapSortButton
    case tapHistory
    case tapAddressButton
    case tapActionMenuButton
    case changeDisplay(InvestmentDisplayState.Kind)
    case showStartLease(Money)
    case presentSearch(startPoint: CGFloat)
    case updateApp
    case setCleanWalletBanner
    case isShowCleanWalletBanner(Bool)
    case completeCleanWalletBanner(Bool)
    case isHasAppUpdate(Bool)
    case openStakingFaq(fromLanding: Bool)
    case openWithdraw
    case openBuy
    case openDeposit
    case openTrade
    case openFb(String)
    case openVk(String)
    case openTw(String)
    case startStaking
}
