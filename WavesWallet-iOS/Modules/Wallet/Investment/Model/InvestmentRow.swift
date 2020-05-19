//
//  InvestmentRow.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 18.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation

// MARK: ViewModel for UITableView

enum InvestmentRow {
    enum HistoryCellType {
        case leasing
        case staking
    }

    case search
    case hidden
    case asset(DomainLayer.DTO.SmartAssetBalance)
    case assetSkeleton
    case balanceSkeleton
    case historySkeleton
    case balance(InvestmentLeasingVM.Balance)
    case leasingTransaction(SmartTransaction)
    case historyCell(HistoryCellType)
    case quickNote
    case stakingBalance(InvestmentStakingVM.Balance)
    case stakingLastPayoutsTitle
    case stakingLastPayouts([PayoutTransactionVM])
    case emptyHistoryPayouts
    case landing(InvestmentStakingVM.Landing)
}

extension InvestmentRow {
    var asset: DomainLayer.DTO.SmartAssetBalance? {
        switch self {
        case let .asset(asset):
            return asset
        default:
            return nil
        }
    }

    var leasingTransaction: SmartTransaction? {
        switch self {
        case let .leasingTransaction(tx):
            return tx
        default:
            return nil
        }
    }
}
