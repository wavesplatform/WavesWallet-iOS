//
//  WalletModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol WalletModuleOutput: AnyObject {
    func showWalletSort()
    func showMyAddress()
    func showHistoryForLeasing()
    func showAsset(with currentAsset: DomainLayer.DTO.SmartAssetBalance, assets: [DomainLayer.DTO.SmartAssetBalance])
    func showStartLease(availableMoney: Money)
    func showLeasingTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int)
}
