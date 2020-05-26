//
//  WalletRowVM.swift
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

enum WalletRowVM {
    enum HistoryCellType {
        case leasing
        case staking
    }

    case separator
    case hidden
    case asset(DomainLayer.DTO.SmartAssetBalance)
    case assetSkeleton
}

extension WalletRowVM {
    var asset: DomainLayer.DTO.SmartAssetBalance? {
        switch self {
        case let .asset(asset):
            return asset
        default:
            return nil
        }
    }
}
