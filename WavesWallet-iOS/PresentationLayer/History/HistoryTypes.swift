//
//  HistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

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
        struct DisplayState: Mutating {
            var sections: [HistoryTypes.ViewModel.Section]
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
        
    }
}

extension HistoryTypes.ViewModel {
    struct Section: Mutating {
        enum Kind {
            case all
        }
        
        let kind: Kind
        var items: [Row]
    }
    
    enum Row {
        case asset(HistoryTypes.DTO.Asset)
        case assetSkeleton
    }
}

extension HistoryTypes.DTO {
    struct Asset: Hashable, Mutating {
        let id: String
        let name: String
    }
}

