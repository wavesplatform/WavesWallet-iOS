//
//  DexSortTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexSort {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case readyView
        case tapDeleteButton(IndexPath)
        case dragModels(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
        case setModels([DTO.DexSortModel])
    }
    
    struct State {
        
        enum Action: Mutating {
            case none
            case refresh
            case delete
        }
        
        var isNeedRefreshing: Bool
        var action: Action
    }
}

extension DexSort.DTO {
    
    struct DexSortModel: Hashable {
        let id: String
        let name: String
        var sortLevel: Float
    }
}

extension DexSort.ViewModel {

    struct Section {
        var items: [Row]
    }
    
    enum Row {
        case models(DexSort.DTO.DexSortModel)
    }
}
