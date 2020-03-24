//
//  StakingTransferTypes.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import DomainLayer
import WavesSDK

enum StakingTransfer {
    enum DTO {}
    enum ViewModel {}
}

extension StakingTransfer.DTO {
 
    enum AssistanceButton: String, Equatable {
        case max = "Max"
        case percent100 = "100%"
        case percent75 = "75%"
        case percent50 = "50%"
        case percent25 = "25%"
    }
    
    enum Kind {
        case deposit
        case withdraw
        case card
    }
    
    enum Data {
        
        struct Transfer {
            let asset: DomainLayer.DTO.Asset
            let balance: DomainLayer.DTO.Balance
            let transactionFeeBalance: DomainLayer.DTO.Balance
        }
        
        struct Card {
            let asset: DomainLayer.DTO.Asset
            let minAmount: DomainLayer.DTO.Balance
            let maxAmount: DomainLayer.DTO.Balance
        }
        
         case deposit(Transfer)
         case withdraw(Transfer)
         case card(Card)
     }
    
    
    enum InputData: Hashable {
        
        struct Card: Hashable {
            enum Error: Hashable {
                case maxAmount
                case minAmount
            }

            var amount: Money?
            var error: InputData.Card.Error?
        }
        
        struct Transfer: Hashable {
            enum Error: Hashable {
                case insufficientFunds
                case insufficientFundsOnTax
            }
            
            var amount: Money?
            var error: InputData.Transfer.Error?
        }
                
        case deposit(Transfer)
        case withdraw(Transfer)
        case card(Card)
    }
}
    
extension StakingTransfer {
    enum Event {
        case viewDidAppear
        case showCard(StakingTransfer.DTO.Data.Card)
        case showDeposit(StakingTransfer.DTO.Data.Transfer)
        case showWithdraw(StakingTransfer.DTO.Data.Transfer)
        case completedSendTransfer
        case handlerError(NetworkError)
        case tapSendButton
        case tapAssistanceButton(StakingTransfer.DTO.AssistanceButton)
        case input(Money?, IndexPath)
    }
}

protocol Test {
    var title: String { get set }
}

extension StakingTransfer {
        
    struct State: Test {
        
        struct Core {
            enum Action {
                case none
                case loadCard
                case loadDeposit
                case loadWithdraw
                case sendCard
                case sendDeposit
                case sendWithdraw
              }
            
            let kind: StakingTransfer.DTO.Kind
            var action: StakingTransfer.State.Core.Action
            
            var data: StakingTransfer.DTO.Data?
            var input: StakingTransfer.DTO.InputData?
        }
        
        struct UI: DataSourceProtocol, Test {
            enum Action {
                case none
                case update
                case updateRows(_ insertRows: [IndexPath],
                                _ deleteRows: [IndexPath],
                                _ reloadRows: [IndexPath],
                                _ updateRows: [IndexPath])
                case error(DisplayError)
            }

            var sections: [ViewModel.Section]
            var title: String
            var action: Action
        }
    
        var ui: UI
        var core: Core
        var title: String = ""
    }
}

extension StakingTransfer.ViewModel {
    
    struct Section: SectionProtocol, Equatable {
        var rows: [Row]
    }
    
    enum Row: Equatable {
        case skeletonBalance
        case balance(StakingTransferBalanceCell.Model)
        case inputField(StakingTransferInputFieldCell.Model)
        case scrollButtons(StakingTransferScrollButtonsCell.Model)
        case description(StakingTransferDescriptionCell.Model)
        case error(StakingTransferErrorCell.Model)
        case feeInfo(StakingTransferFeeInfoCell.Model)
        case button(StakingTransferButtonCell.Model)
    }
}

extension StakingTransfer.DTO.Data {
    
    var card: StakingTransfer.DTO.Data.Card? {
        switch self {
        case .card(let card):
            return card
        default:
            return nil
        }
    }
    
    var withdraw: StakingTransfer.DTO.Data.Transfer? {
        switch self {
        case .withdraw(let withdraw):
            return withdraw
        default:
            return nil
        }
    }
    
    var transfer: StakingTransfer.DTO.Data.Transfer? {
        switch self {
        case .withdraw(let withdraw):
            return withdraw
        case .deposit(let deposit):
            return deposit
        default:
            return nil
        }
    }
    
    var deposit: StakingTransfer.DTO.Data.Transfer? {
        switch self {
        case .deposit(let deposit):
            return deposit
        default:
            return nil
        }
    }
}

extension StakingTransfer.DTO.InputData {
    
    var card: StakingTransfer.DTO.InputData.Card? {
        switch self {
        case .card(let card):
            return card
        default:
            return nil
        }
    }
    
    var withdraw: StakingTransfer.DTO.InputData.Transfer? {
        switch self {
        case .withdraw(let withdraw):
            return withdraw
        default:
            return nil
        }
    }
    
    var transfer: StakingTransfer.DTO.InputData.Transfer? {
        switch self {
        case .withdraw(let withdraw):
            return withdraw
        case .deposit(let deposit):
            return deposit
        default:
            return nil
        }
    }
    
    var deposit: StakingTransfer.DTO.InputData.Transfer? {
        switch self {
        case .deposit(let deposit):
            return deposit
        default:
            return nil
        }
    }
}

