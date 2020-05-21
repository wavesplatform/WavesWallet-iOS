//
//  WalletSectionVM.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import UIKit
import WavesSDKExtensions

struct WalletSectionVM {
    enum Kind {
        case search
        case skeleton        
        case info
        case general
        case spam(count: Int)
        case hidden(count: Int)
    }

    var kind: Kind
    var items: [WalletRowVM]
    var isExpanded: Bool
}

extension WalletSectionVM {
    static func map(from assets: [DomainLayer.DTO.SmartAssetBalance]) -> [WalletSectionVM] {
        let generalItems = assets
            .filter { $0.asset.isSpam != true && $0.settings.isHidden != true }
            .map { WalletRowVM.asset($0) }

        let generalSection: WalletSectionVM = .init(kind: .general,
                                                    items: generalItems,
                                                    isExpanded: true)
        let hiddenItems = assets
            .filter { $0.settings.isHidden == true }
            .map { WalletRowVM.asset($0) }

        let spamItems = assets
            .filter { $0.asset.isSpam == true }
            .map { WalletRowVM.asset($0) }

        var sections: [WalletSectionVM] = [WalletSectionVM]()
        sections.append(generalSection)

        if !hiddenItems.isEmpty {
            let hiddenSection: WalletSectionVM = .init(kind: .hidden(count: hiddenItems.count),
                                                       items: hiddenItems,
                                                       isExpanded: false)
            sections.append(hiddenSection)
        }

        if !spamItems.isEmpty {
            let spamSection: WalletSectionVM = .init(kind: .spam(count: spamItems.count),
                                                     items: spamItems,
                                                     isExpanded: false)
            sections.append(spamSection)
        }

        return sections
    }
}
