//
//  HistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxDataSources

enum HistoryTypes {
    enum DTO {}
    enum ViewModel {}
    
    enum Display {
        case all
        case sent
        case received
        case exchanged
        case leased
        case issued
        case activeNow
        case canceled
    }
    
    struct State: Mutating {
        enum AnimateType  {
            case refresh
            case collapsed(Int)
            case expanded(Int)
        }
        
        struct DisplayState: Mutating {
            var sections: [HistoryTypes.ViewModel.Section]
            var isRefreshing: Bool
            var isNeedRefreshing: Bool
            var animateType: AnimateType = .refresh
        }
        
        var display: Display
        var all: DisplayState
        var sent: DisplayState
        var received: DisplayState
        var exchanged: DisplayState
        var leased: DisplayState
        var issued: DisplayState
        var activeNow: DisplayState
        var canceled: DisplayState
    }
    
    enum Event {
        case responseAll([DTO.Asset])
        case readyView
        case refresh
        case changeDisplay(Display)
    }
}

extension HistoryTypes.DTO {
    struct Asset: Hashable, Mutating {
        let id: String
        let name: String
    }
}

