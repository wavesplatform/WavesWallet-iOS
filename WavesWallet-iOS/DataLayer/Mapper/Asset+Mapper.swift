//
//  Asset+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Asset {

    convenience init(asset: DomainLayer.DTO.Asset) {
        self.init()
        self.id = asset.id
        self.wavesId = asset.wavesId
        self.gatewayId = asset.gatewayId
        self.displayName = asset.displayName
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
        self.hasScript = asset.hasScript
        self.minSponsoredFee = asset.minSponsoredFee
    }
}

extension DomainLayer.DTO.Asset {

    init(_ asset: Asset) {
        self.modified = asset.modified
        self.id = asset.id
        self.wavesId = asset.wavesId
        self.gatewayId = asset.gatewayId
        self.displayName = asset.displayName
        self.precision = asset.precision
        self.description = asset.descriptionAsset
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
        self.addressRegEx = asset.addressRegEx
        self.hasScript = asset.hasScript
        self.minSponsoredFee = asset.minSponsoredFee
    }
}
