//
//  AssetTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 14.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AssetTypes {}

extension AssetTypes {
    enum ViewModel {}
    enum DTO {}
}

extension AssetTypes {
    enum Display {
        case assets
        case leasing
    }

    struct State: Mutating {
        //TODO: Rename
        enum AnimateType  {
            case refresh
            case collapsed(Int)
            case expanded(Int)
        }

//        var displayState: DisplayState
//        var lastEvent: Event?
    }

    struct DisplayState {

    }

    enum DisplayEvent {
        case readyView
    }

    enum Event {
        case updated(DisplayState)
    }
}

extension AssetTypes.DTO {

    struct Asset: Hashable {
        let id: String
        let name: String
        let isMyWavesToken: Bool
        let isWaves: Bool
        let isFavorite: Bool
        let isFiat: Bool
        let isSpam: Bool
        let isGateway: Bool
        let sortLevel: Float
    }
//
//    struct Leasing: Hashable {
//
//        struct Transaction: Hashable {
//            let id: String
//            let balance: Money
//        }
//
//        struct Balance: Hashable {
//            let totalMoney: Money
//            let avaliableMoney: Money
//            let leasedMoney: Money
//            let leasedInMoney: Money
//        }
//
//        let balance: Balance
//        let transactions: [Transaction]
//    }
}

