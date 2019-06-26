//
//  WalletHome.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    enum WalletHome: AnalyticManagerEventInfo {
        
        private enum Constants {
            static let currency = "Currency"
        }
        
        case updateBanner
        case tokenSearch
        case tokenSortingPage
        case tokenSortingPosition
        case tokenSortingVisability
        case qrCard
        case startBalanceFromZero(assetName: String)
        
        public var name: String {
            switch self {
            case .updateBanner:
                return "Wallet Update Banner"
                
            case .tokenSearch:
                return "Wallet Token Search"
                
            case .tokenSortingPage:
                return "Wallet Token Sorting Page"
                
            case .tokenSortingPosition:
                return "Wallet Token Sorting Position"
                
            case .tokenSortingVisability:
                return "Wallet Token Sorting Visability"
                
            case .qrCard:
                return "Wallet QRCard"
                
            case .startBalanceFromZero:
                return "Wallet Start Balance from Zero"
            }
        }
        
        public var params: [String : String] {
            switch self {
            case .startBalanceFromZero(let assetName):
                return [Constants.currency: assetName]
                
            default:
                return [:]
            }
        }
    }
}
