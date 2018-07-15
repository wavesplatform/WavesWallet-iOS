//
//  Asset+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Asset {
    convenience init(model: API.Model.Asset) {
        self.init()
        id = model.id
        name = model.name
        precision = model.precision
        descriptionAsset = model.description
        height = model.height
        timestamp = model.timestamp
        sender = model.sender
        quantity = model.quantity
        reissuable = model.reissuable
    }
}
