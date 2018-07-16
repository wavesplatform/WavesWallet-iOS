//
//  WalletTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources
import UIKit

enum WalletTypes {}

extension WalletTypes {
    enum ViewModel {}
    enum DTO {}
}

extension WalletTypes {
    enum Display {
        case assets
        case leasing
    }

    enum AnimateType {
        case refresh
        case collapsed(Int)
        case expanded(Int)

        var isRefresh: Bool {
            switch self {
            case .refresh:
                return true
            default:
                return false
            }
        }

        var isCollapsed: Bool {
            switch self {
            case .collapsed:
                return true
            default:
                return false
            }
        }

        var isExpanded: Bool {
            switch self {
            case .expanded:
                return true
            default:
                return false
            }
        }

        var sectionIndex: Int? {
            switch self {
            case .expanded(let section):
                return section
            case .collapsed(let section):
                return section
            default:
                return nil
            }
        }
    }

    struct State {
        struct DisplayState {
            var sections: [ViewModel.Section]
            var collapsedSections: [Int: Bool]
            var isRefreshing: Bool
            var animateType: AnimateType = .refresh
        }

        var display: Display = .assets
        var assets: DisplayState
        var leasing: DisplayState
    }

    enum Event {
        case none
        case responseAssets([AssetBalance])
        case refresh
        case readyView
        case tapSection(Int)
        case changeDisplay(Display)
    }
}
