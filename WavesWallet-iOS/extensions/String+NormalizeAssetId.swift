//
//  String+NormalizeAssetId.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 08/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {

    var normalizeAssetId: String {
        if let id = self {
            return id
        } else {
            return Environments.Constants.wavesAssetId
        }
    }
}
