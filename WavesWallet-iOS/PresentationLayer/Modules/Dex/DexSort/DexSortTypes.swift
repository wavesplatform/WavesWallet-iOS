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
    
    struct State: Mutating {
        
        enum Action {
            case none
            case refresh
            case delete
        }
        
        var isNeedRefreshing: Bool
        var action: Action
        var section: DexSort.ViewModel.Section
        var deletedIndex: Int
    }
}

extension DexSort.ViewModel {
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case model(DexSort.DTO.DexSortModel)
    }
}

extension DexSort.DTO {
    struct DexSortModel: Hashable, Mutating {
        let id: String
        let name: String
        var sortLevel: Int
    }
}
