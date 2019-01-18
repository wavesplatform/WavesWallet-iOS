//
//  DexMarketTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

private enum Constants {
    static let MinersRewardToken = ["4uK8i4ThRGbehENwa6MxyLtxAjAo1Rj9fduborGExarC" : "MRT"]
    static let WavesCommunityToken = ["DHgwrRvVyqJsepd32YbBqUeDH4GJ1N984X8QoekjgH8J" : "WCT"]
}

enum DexMarket {
    enum ViewModel {}

    enum Event {
        case readyView
        case setPairs([DomainLayer.DTO.Dex.SmartPair])
        case tapCheckMark(index: Int)
        case tapInfoButton(index: Int)
        case searchTextChange(text: String)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var action: Action
        var section: DexMarket.ViewModel.Section
    }
}

extension DexMarket.ViewModel {
   
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case pair(DomainLayer.DTO.Dex.SmartPair)
    }
    
}

extension DexMarket {
    static var MinersRewardToken: [String : String] {
        return Constants.MinersRewardToken
    }
    
    static var WavesCommunityToken: [String : String] {
        return Constants.WavesCommunityToken
    }
}
