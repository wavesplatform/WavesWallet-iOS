//
//  WalletSearchTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/3/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions

enum WalletSearch {
    enum DTO {}
    enum ViewModel {}
    
    
    enum Event {
        case readyView
        case search(String)

    }
    
    struct State: Mutating {
        
        enum Action {
            case none
            case refresh
        }
        
        var assets: [DomainLayer.DTO.SmartAssetBalance]
        var sections: [ViewModel.Section]
        var action: Action
    }
}

extension WalletSearch.ViewModel {
    
    enum Kind {
        case assets
        case hidden
        case spam
    }
    
    struct Section {
        
        let kind: Kind
        var items: [Row]
    }
    
    enum Row {
        case asset(DomainLayer.DTO.SmartAssetBalance)
        case header(Kind)
    }
}

extension WalletSearch.State {
    
    var hasGeneralAssets: Bool {
        return sections.first(where: {$0.kind == .assets}) != nil
    }
}
