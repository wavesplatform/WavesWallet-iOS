//
//  StakingTransferTypes.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import WavesSDK

enum StakingTransfer {
    enum DTO {}
    
    enum ViewModel {}
}

extension StakingTransfer.DTO {
 
    enum Kind {
        case deposit
        case withdraw
        case card
    }
}
    
extension StakingTransfer {
    enum Event {
        case viewDidAppear
    }
}
    
extension StakingTransfer {
        
    struct State {
        struct Core {
            
            let kind: StakingTransfer.DTO.Kind
        }
        
        struct UI {
            enum Action {
                case none
                case update
                case error(NetworkError)
            }

            var sections: [ViewModel.Section]
            var action: Action
        }
    
        let ui: UI
        let core: Core
    }
}

extension StakingTransfer.ViewModel {
    
    struct Section: SectionProtocol {
        var rows: [Row]
    }
    
    enum Row {
        case balance(StakingTransferBalanceCell.Model)
        case inputField(StakingTransferInputFieldCell.Model)
        case scrollButtons(StakingTransferScrollButtonsCell.Model)
        case error(StakingTransferErrorCell.Model)
        case feeInfo(StakingTransferFeeInfoCell.Model)
        case button(StakingTransferButtonCell.Model)
    }
}
