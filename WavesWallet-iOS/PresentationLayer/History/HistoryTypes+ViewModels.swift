//
//  HistoryTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Mac on 06/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension HistoryTypes.ViewModel {
    struct Section: Hashable {
        var header: String
        var items: [Row]
    }
    
    enum Row: Hashable {
        case asset(HistoryTypes.DTO.Transaction)
        case assetSkeleton
    }
}


extension HistoryTypes.ViewModel.Section {
    static func filter(from transactions: [HistoryTypes.DTO.Transaction], filter: HistoryTypes.Filter) -> [HistoryTypes.ViewModel.Section] {
        
        let generalItems = transactions
            .filter { filter.kinds.contains($0.kind) }
            .sorted(by: { (transaction1, transaction2) -> Bool in
                return transaction1.id < transaction2.id
            })
            .map { HistoryTypes.ViewModel.Row.asset($0) }
        
        let generalSection: HistoryTypes.ViewModel.Section = .init(header: "Итемы",
                                                                   items: generalItems)
        
        return [generalSection]
        
    }
    
    static func map(from assets: [HistoryTypes.DTO.Transaction]) -> [HistoryTypes.ViewModel.Section] {
        let generalItems = assets
            .sorted(by: { (asset1, asset2) -> Bool in
                
//                if asset1.isWaves == true {
//                    return true
//                }
//
//                if asset1.isFavorite == true && asset2.isFavorite == false {
//                    return true
//                } else if asset1.isFavorite == false && asset2.isFavorite == true {
//                    return false
//                }
                
                return asset1.id < asset2.id
            })
            .map { HistoryTypes.ViewModel.Row.asset($0) }
        
        let generalSection: HistoryTypes.ViewModel.Section = .init(header: "Итемы",
                                                                  items: generalItems)

        return [generalSection]
    }
}
