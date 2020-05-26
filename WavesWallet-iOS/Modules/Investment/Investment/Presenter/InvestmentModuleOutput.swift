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

protocol InvestmentModuleOutput: AnyObject {
    func showHistoryForLeasing()
    func showAccountHistory()
    func showStartLease(availableMoney: Money)
    func showLeasingTransaction(transactions: [SmartTransaction], index: Int)    
    func openAppStore()
    func openStakingFaq(fromLanding: Bool)
    func openTrade(neutrinoAsset: Asset)
    func openBuy(neutrinoAsset: Asset)
    func openDeposit(neutrinoAsset: Asset)
    func openWithdraw(neutrinoAsset: Asset)    
    func openTw(sharedText: String)
    func openVk(sharedText: String)
    func openFb(sharedText: String)    
    func showPayoutsHistory()
}
