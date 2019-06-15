//
//  TransactionFeeRulesGitHub.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 20/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension GitHub.DTO {

    struct TransactionFeeRules: Decodable {

        struct Rule: Decodable {
            let add_smart_asset_fee: Bool?
            let add_smart_account_fee: Bool?
            let min_price_step: Int64?
            let fee: Int64?
            let price_per_transfer: Int64?
            let price_per_kb: Int64?
        }

        let smart_asset_extra_fee: Int64
        let smart_account_extra_fee: Int64
        let calculate_fee_rules: [String: Rule]
    }
}
