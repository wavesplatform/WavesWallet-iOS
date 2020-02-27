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

//TODO remove
import RxSwift
import RxCocoa

enum StakingTransfer {
    enum DTO {}
    
    enum ViewModel {}
}

extension StakingTransfer.DTO {
 
    enum AssistanceButton: String {
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
    
    struct Deposit {
        let asset: DomainLayer.DTO.Asset
        let availableBalance: DomainLayer.DTO.Balance
        let transactionFeeBalance: DomainLayer.DTO.Balance
    }
    
    struct Withdraw {
        let asset: DomainLayer.DTO.Asset
        let stakingBalance: DomainLayer.DTO.Balance
        let transactionFeeBalance: DomainLayer.DTO.Balance
    }
    
    struct Card {
        let asset: DomainLayer.DTO.Asset
        let minAmount: DomainLayer.DTO.Balance
        let maxAmount: DomainLayer.DTO.Balance
    }
    
    enum Data {
        case deposit(Deposit)
        case withdraw(Withdraw)
        case card(Card)
    }
    
    struct InputCard {
        enum Error {
            case maxAmount
            case minAmount
        }
        
        var amount: Money?
        var error: InputCard.Error?
    }
    
    enum InputData {
        case card(InputCard)
    }
}
    
//Cordinator -> Kind.deposit ->

extension StakingTransfer {
    enum Event {
        case viewDidAppear
        
        case showCard(StakingTransfer.DTO.Card)
        case showDeposit(StakingTransfer.DTO.Deposit)
        case showWithdraw(StakingTransfer.DTO.Withdraw)
        case tapSendButton
        case tapAssistanceButton(StakingTransfer.DTO.AssistanceButton)
        case input(Money?, IndexPath)
    }
}

/*

 
 Event -> Mutate State -> State
 
 UI Event ->
 
 Backend Event -> x


*/

extension StakingTransfer {
        
//    struct State {
//        
//        struct Core {
//            enum Action {
//                case none
//                case loadCard
//                case loadDeposit
//                case loadWithdraw
//                case send
//              }
//            
//            let kind: StakingTransfer.DTO.Kind
//            var action: StakingTransfer.State.Core.Action
//            
//            var data: StakingTransfer.DTO.Data?
//            var input: StakingTransfer.DTO.InputData?
//        }
//        
//        struct UI: DataSourceProtocol {
//            enum Action {
//                case none
//                case update
//                case updateRows(_ insertRows: [IndexPath],
//                                _ deleteRows: [IndexPath],
//                                _ reloadRows: [IndexPath],
//                                _ updateRows: [IndexPath])
//                case error(NetworkError)
//            }
//
//            var sections: [ViewModel.Section]
//            var title: String
//            var action: Action
//        }
//    
//        var ui: UI
//        var core: Core
//    }
}

extension StakingTransfer.ViewModel {
    
    struct Section: SectionProtocol {
        var rows: [Row]
    }
    
    enum Row: Hashable {
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
    
    var card: StakingTransfer.DTO.Card? {
        switch self {
        case .card(let card):
            return card
        default:
            return nil
        }
    }
}

extension StakingTransfer.DTO.InputData {
    
    var card: StakingTransfer.DTO.InputCard? {
        switch self {
        case .card(let card):
            return card
        default:
            return nil
        }
    }
}



extension StakingTransfer {
    
    struct Card {
        struct State {
            
                        enum Action {
                            case none
                            case loadCard
                            case loadDeposit
                            case loadWithdraw
                            case send
                          }
            
                        let kind: StakingTransfer.DTO.Kind
                        var action: StakingTransfer.State.Core.Action
            
                        var data: StakingTransfer.DTO.Data?
                        var input: StakingTransfer.DTO.InputData?
        }
        
        enum Event {
            case uiCommand(StakingTransfer.UI.Command)
            case showCard
        }
        
        var state: State
        var uiEvent: StakingTransfer.UI.Event?
    }
}

extension StakingTransfer {
   
    struct UI {
        struct State: DataSourceProtocol {
            enum Action {
                case none
                case update
                case updateRows(_ insertRows: [IndexPath],
                                _ deleteRows: [IndexPath],
                                _ reloadRows: [IndexPath],
                                _ updateRows: [IndexPath])
                case error(NetworkError)
            }

            var sections: [ViewModel.Section]
            var title: String
            var action: Action
        }
        
        enum Command {
            case viewDidAppear
            case tapSendButton
            case tapAssistanceButton(StakingTransfer.DTO.AssistanceButton)
            case input(Money?, IndexPath)
        }
        
        enum Event {
            case viewDidAppear
            case tapSendButton
            case tapAssistanceButton(StakingTransfer.DTO.AssistanceButton)
            case input(Money?, IndexPath)
            case update(State)
        }
        
        var state: State
        var command: StakingTransfer.UI.Command?
    }
}


//class ViewController {
//    var stakingTransferUISystem: StakingTransferCardUISystem = StakingTransferCardUISystem()
//
//
//    init() {
//
//        stakingTransferUISystem.start()
//    }
//}
