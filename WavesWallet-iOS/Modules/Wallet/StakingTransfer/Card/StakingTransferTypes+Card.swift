////
////  StakingTransferTypes+Card.swift
////  WavesWallet-iOS
////
////  Created by rprokofev on 27.02.2020.
////  Copyright © 2020 Waves Platform. All rights reserved.
////
//
//import Extensions
//import DomainLayer
//
//extension StakingTransfer.DTO {
//    
//    struct Card {
//        let asset: DomainLayer.DTO.Asset
//        let minAmount: DomainLayer.DTO.Balance
//        let maxAmount: DomainLayer.DTO.Balance
//    }
//         
//    struct InputCard {
//        enum Error {
//            case maxAmount
//            case minAmount
//        }
//        
//        var amount: Money?
//        var error: InputCard.Error?
//    }
//}
//
//extension StakingTransfer {
//        
//    struct Card {
//               
//        enum Event {
//            case viewDidAppear
//            case tapSendButton
//            case tapAssistanceButton(StakingTransfer.DTO.AssistanceButton)
//            case input(Money?, IndexPath)
//            case newData(StakingTransfer.DTO.Card)
//        }
//        
//        enum Action {
//            case none
//            case load
//            case send
//        }
//                
//        var action: StakingTransfer.Card.Action
//        
//        var data: StakingTransfer.DTO.Card?
//        var input: StakingTransfer.DTO.InputCard?
//        
//        var uiState: StakingTransfer.UI.State?
//        var setNeedUpdateUI: Bool
//    }
//}
//
//extension StakingTransfer.Card {
//    
//    func initialUIStateCard() -> StakingTransfer.UI.State {
//                        
//        let title = Localizable.Waves.Staking.Transfer.Card.title
//        
//        return StakingTransfer.UI.State(sections: [],
//                                        title: title,
//                                        action: .update)
//    }
//}
