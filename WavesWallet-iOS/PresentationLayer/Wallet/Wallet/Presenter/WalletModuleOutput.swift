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
    func showAsset(with currentAsset: WalletTypes.DTO.Asset, assets: [WalletTypes.DTO.Asset])
    func showLeasingTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int)
}
