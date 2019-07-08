//
//  NewWalletSort+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension WalletSort.ViewModel {
    
    static func map(assets: [WalletSort.DTO.Asset]) -> [WalletSort.ViewModel.Section] {

        var favoritiesAssets = assets
            .filter { $0.isFavorite }
            .sorted(by: { $0.sortLevel < $1.sortLevel })
            .map { WalletSort.ViewModel.Row.favorityAsset($0) }
        if favoritiesAssets.count == 0 {
            favoritiesAssets.append(.emptyAssets(.favourite))
        }
        favoritiesAssets.append(.separator(isShowHiddenTitle: false))
        
        var defaultAssets = assets
            .filter { $0.isFavorite == false && $0.isHidden == false }
            .sorted(by: { $0.sortLevel < $1.sortLevel })
            .map { WalletSort.ViewModel.Row.list($0) }
        if defaultAssets.count == 0 {
            defaultAssets.append(.emptyAssets(.list))
        }
        
        var hiddenAssets = assets
            .filter { $0.isHidden }
            .sorted(by: { $0.sortLevel < $1.sortLevel })
            .map { WalletSort.ViewModel.Row.hidden($0) }
        
        defaultAssets.append(.separator(isShowHiddenTitle: hiddenAssets.count > 0))

        if hiddenAssets.count == 0 {
            hiddenAssets.append(.emptyAssets(.hidden))
        }

        return [WalletSort.ViewModel.Section(kind: .top, items: [.top]),
                WalletSort.ViewModel.Section(kind: .favorities, items: favoritiesAssets),
                WalletSort.ViewModel.Section(kind: .list, items: defaultAssets),
                WalletSort.ViewModel.Section(kind: .hidden, items: hiddenAssets)]
    }
}
