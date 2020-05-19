//
//  WalletModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit
import DomainLayer
import Extensions

protocol WalletModuleOutput: AnyObject {
    func showWalletSort(balances: [DomainLayer.DTO.SmartAssetBalance])
    func showMyAddress()
//    func showHistoryForLeasing()
    func showAccountHistory()
//    func showStartLease(availableMoney: Money)
//    func showLeasingTransaction(transactions: [SmartTransaction], index: Int)
//    func openStakingFaq(fromLanding: Bool)
//    func openTrade(neutrinoAsset: Asset)
//    func openBuy(neutrinoAsset: Asset)
//    func openDeposit(neutrinoAsset: Asset)
//    func openWithdraw(neutrinoAsset: Asset)
//    func openTw(sharedText: String)
//    func openVk(sharedText: String)
//    func openFb(sharedText: String)
//    func showPayout(payout: PayoutTransactionVM)
//    func showPayoutsHistory()
    func showAsset(with currentAsset: DomainLayer.DTO.SmartAssetBalance, assets: [DomainLayer.DTO.SmartAssetBalance])
    func presentSearchScreen(from startPoint: CGFloat, assets: [DomainLayer.DTO.SmartAssetBalance])
    func openAppStore()
    func openActionMenu()
}
