//
//  SponsorshipTransaction.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class SponsorshipTransaction: Transaction {

    var minSponsoredAssetFee: RealmOptional<Int64> = RealmOptional<Int64>()
    @objc dynamic var assetId: String = ""
}
