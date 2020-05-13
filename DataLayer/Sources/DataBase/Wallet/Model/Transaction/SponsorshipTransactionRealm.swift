//
//  SponsorshipTransaction.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/02/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift

final class SponsorshipTransactionRealm: TransactionRealm {

    var minSponsoredAssetFee: RealmOptional<Int64> = RealmOptional<Int64>()
    @objc dynamic var assetId: String = ""
}
