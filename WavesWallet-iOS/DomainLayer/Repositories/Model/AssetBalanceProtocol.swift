//
//  AccountBalanceProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public protocol AssetBalanceSettingsProtocol {
    var assetId: String { get set }
    var sortLevel: Float { get set }
    var isHidden: Bool { get set }
    var isFavorite: Bool { get set }
}

public protocol AssetBalanceProtocol {
    var assetId: String { get set }
    var balance: Int64 { get set }
    var leasedBalance: Int64 { get set }
    var reserveBalance: Int64 { get set }
    var settings: AssetBalanceSettingsProtocol? { get set }
    var asset: AssetProtocol? { get set }
}

public protocol AssetProtocol {
    var ticker: String? { get set }
    var id: String { get set }
    var name: String { get set }
    var precision: Int { get set }
    var descriptionAsset: String { get set }
    var height: Int64 { get set }
    var timestamp: String { get set }
    var sender: String { get set }
    var quantity: Int64 { get set }
    var isReissuable: Bool { get set }
    var isSpam: Bool { get set }
    var isFiat: Bool { get set }
    var isGeneral: Bool { get set }
    var isMyAsset: Bool { get set }
    var isGateway: Bool { get set }
}
