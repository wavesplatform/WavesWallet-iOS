//
//  Asset+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer

extension AssetRealm {

    convenience init(asset: Asset) {
        self.init()
        self.id = asset.id
        self.wavesId = asset.wavesId
        self.gatewayId = asset.gatewayId
        self.name = asset.name
        self.precision = asset.precision
        self.descriptionAsset = asset.description
        self.height = asset.height
        self.timestamp = asset.timestamp
        self.sender = asset.sender
        self.quantity = asset.quantity
        self.ticker = asset.ticker
        self.isReusable = asset.isReusable
        self.isSpam = asset.isSpam
        self.isFiat = asset.isFiat
        self.isGeneral = asset.isGeneral
        self.isMyWavesToken = asset.isMyWavesToken
        self.isWavesToken = asset.isWavesToken
        self.isGateway = asset.isGateway
        self.isWaves = asset.isWaves
        self.modified = asset.modified
        self.addressRegEx = asset.addressRegEx
        self.iconLogoUrl = asset.iconLogoUrl
        self.hasScript = asset.hasScript
        self.minSponsoredFee = asset.minSponsoredFee
    }
}

extension Asset {
    
    init(_ asset: AssetRealm) {
        
        self.init(id: asset.id,
                  gatewayId: asset.gatewayId,
                  wavesId: asset.wavesId,
                  name: asset.name,
                  precision: asset.precision,
                  description: asset.descriptionAsset,
                  height: asset.height,
                  timestamp: asset.timestamp,
                  sender: asset.sender,
                  quantity: asset.quantity,
                  ticker: asset.ticker,
                  isReusable: asset.isReusable,
                  isSpam: asset.isSpam,
                  isFiat: asset.isFiat,
                  isGeneral: asset.isGeneral,
                  isMyWavesToken: asset.isMyWavesToken,
                  isWavesToken: asset.isWavesToken,
                  isGateway: asset.isGateway,
                  isWaves: asset.isWaves,
                  modified: asset.modified,
                  addressRegEx: asset.addressRegEx,
                  iconLogoUrl: asset.iconLogoUrl,
                  hasScript: asset.hasScript,
                  minSponsoredFee: asset.minSponsoredFee,
                  gatewayType: asset.gatewayType)            
    }
}
