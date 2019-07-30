//
//  WidgetSettingsType.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import Extensions
import DomainLayer

enum WidgetSettings {
        
    struct State {
        
        struct UI {
            
            enum Action {
                case none
                case update
            }
            
            var sections: [Section]
            var action: Action
        }
        
        struct Core {
            
            enum Action {
                case none
            }
            
            var action: Action
        }
        
        var ui: UI
        var core: Core
    }
    
    enum Event {
        case viewDidAppear
        case handlerError(_ error: Error)
    }
    
    struct Section: SectionProtocol {
        var rows: [Row]
    }
    
    enum Row {
        case asset(WidgetSettingsAssetCell.Model)
//        case general(TransactionCardGeneralCell.Model)
//        case address(TransactionCardAddressCell.Model)
//        case keyValue(TransactionCardKeyValueCell.Model)
//        case keyBalance(TransactionCardKeyBalanceCell.Model)
//        case massSentRecipient(TransactionCardMassSentRecipientCell.Model)
//        case dashedLine(TransactionCardDashedLineCell.Model)
//        case actions(TransactionCardActionsCell.Model)
//        case description(TransactionCardDescriptionCell.Model)
//        case exchange(TransactionCardExchangeCell.Model)
//        case order(TransactionCardOrderCell.Model)
//        case assetDetail(TransactionCardAssetDetailCell.Model)
//        case showAll(TransactionCardShowAllCell.Model)
//        case status(TransactionCardStatusCell.Model)
//        case asset(TransactionCardAssetCell.Model)
//        case sponsorshipDetail(TransactionCardSponsorshipDetailCell.Model)
//        case keyLoading(TransactionCardKeyLoadingCell.Model)
//        case invokeScript(DomainLayer.DTO.SmartTransaction.InvokeScript)
//        case orderFilled(TransactionCardOrderFilledCell.Model)
//        case exchangeFee(TransactionCardExchangeFeeCell.Model)
    }
}
