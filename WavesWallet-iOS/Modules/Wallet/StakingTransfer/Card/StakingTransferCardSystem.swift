////
////  StakingTransferCardSystem.swift
////  WavesWallet-iOS
////
////  Created by rprokofev on 27.02.2020.
////  Copyright © 2020 Waves Platform. All rights reserved.
////
//
//
//import Extensions
//import DomainLayer
//import RxSwift
//import RxCocoa
//import RxFeedback
//
//final class StakingTransferCardSystem: System<StakingTransfer.Card, StakingTransfer.Card.Event> {
//        
//    private var kind: StakingTransfer.DTO.Kind = .card
//    
//    override func initialState() -> State! {
//                    
//        return StakingTransfer.Card.init(action: .none,
//                                         data: nil,
//                                         input: nil,
//                                         uiState: nil,
//                                         setNeedUpdateUI: false)
//        
//    }
//
//    override func internalFeedbacks() -> [Feedback] {
//        return [ShowCardQuery().feedBack]
//        
//    }
//
//    override func reduce(event: StakingTransfer.Card.Event, state: inout StakingTransfer.Card) {
//        switch event {
//        case .viewDidAppear:
//            
//            state.action = .load
//            state.uiState = state.initialUIStateCard()
//            
//            
//        case .newData(let card):
//            
//            guard var uiState = state.uiState else { return }
//                        
//            uiState.sections = card.sections(inputCard: nil)
//            
//            state.data = card
//            state.setNeedUpdateUI = true
//            state.uiState = uiState
//            state.uiState?.action = .update
//            state.action = .none
////            state.core.action = .none
////            state.core.data = .card(card)
////
////            state.ui.sections = card.sections(inputCard: state.core.input?.card)
////            state.ui.action = .update
//            
//        case .input(let money, let indexPath):
//            
////            state.setNeedUpdateUI = false
////            state.action = .none
//            state.uiState?.action = .none
//            
//            changeCardStateAfterInput(input: money,
//                                      indexPath: indexPath,
//                                      state: &state)
//            
//        default:
//            break
//        }
////        switch event {
////        case .input(let money, let indexPath):
////            break
////
////        case .tapAssistanceButton(let button):
////            break
////
////        case .tapSendButton:
////            break
////
////        case .viewDidAppear:
////            break
////        case .showCard:
////            break
////        }
//    }
////
////    override func reduce(event: Event, state: inout State) {
////
////        switch state.core.kind {
////        case .card:
////            return reduceForCard(event: event, state: &state)
////
////        case .deposit:
////            break
////
////        case .withdraw:
////            break
////        }
////    }
////
////    func reduceForCard(event: Event, state: inout State) {
////
////        switch event {
////        case .viewDidAppear:
////
////            switch state.core.kind {
////            case .card:
////                state.core.action = .loadCard
////
////            case .deposit:
////                state.core.action = .loadDeposit
////
////            case .withdraw:
////                state.core.action = .loadWithdraw
////
////            }
////        case .tapAssistanceButton(let assistanceButton):
////
////            guard case .max = assistanceButton else { return }
////
////            guard let money = state.core.data?.card?.maxAmount.money else { return }
////
////            let indexPath = IndexPath(row: 0, section: 0)
////
////            changeCardStateAfterInput(input: money,
////                                      indexPath: indexPath,
////                                      state: &state)
////
////        case .input(let input, let indexPath):
////
////            changeCardStateAfterInput(input: input,
////                                      indexPath: indexPath,
////                                      state: &state)
////
////        case .showCard(let card):
////
////            state.core.action = .none
////            state.core.data = .card(card)
////
////            state.ui.sections = card.sections(inputCard: state.core.input?.card)
////            state.ui.action = .update
////
////        case .tapSendButton:
////
////            guard let card = state.core.data?.card else { return }
////
////            let rowsCount = state.ui.sections[0].rows.count
////            let indexPath = IndexPath(row: max(rowsCount - 1, 0), section: 0)
////
////            state.ui.replace(row: card.button(status: .active), indexPath: indexPath)
////            state.ui.action = .updateRows([],
////                                          [],
////                                          [],
////                                          [indexPath])
////        case .showDeposit(let deposit):
////            break
////
////        case .showWithdraw(let withdraw):
////            break
////        }
////    }
//}
//
//
//private extension StakingTransferCardSystem {
// 
//    func changeCardStateAfterInput(input: Money?, indexPath: IndexPath, state: inout State) {
//
//        guard let card = state.data else { return }
//
//        let prevInputCard = state.input
//        let minAmount = card.minAmount
//        let maxAmount = card.maxAmount
//
//        var error: InputDataStakingTransfer.DTO.InputData.Card.Error? = nil
//
//        if let input = input {
//            if input > maxAmount.money {
//                error = .maxAmount
//            } else if input < minAmount.money {
//                error = .minAmount
//            }
//        }
//
//        let newInputCard: InputDataStakingTransfer.DTO.InputData.Card = .init(amount: input, error: error)
//        let hasPrevError = prevInputCard?.error != nil
//        let hasError = error != nil
//        let reloadError = hasPrevError && hasError
//
//        let inputField = card.inputField(inputCard: newInputCard)
//
//        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
//        let rowsCount = state.uiState?.sections[0].rows.count ?? 0
//        let indexPathButton = IndexPath(row: max(rowsCount - 1, 0), section: 0)
//        
//        state.uiState?.remove(indexPath: indexPath)
//        state.uiState?.add(row: inputField, indexPath: indexPath)
//        
//        if hasPrevError {
//            state.uiState?.remove(indexPath: nextIndexPath)
//        }
//        
//        if hasError {
//            if let errorRow  = card.error(inputCard: newInputCard) {
//                state.uiState?.add(row: errorRow, indexPath: nextIndexPath)
//            }
//        }
//
//        state.uiState?.replace(row: card.button(status: hasError == true ? .disabled : .active), indexPath: indexPathButton)
//
//        var insertRows: [IndexPath] = .init()
//        var deleteRows: [IndexPath] = .init()
//        var reloadRows: [IndexPath] = .init()
//        if reloadError {
//            reloadRows.append(nextIndexPath)
//        } else  {
//
//            if hasPrevError {
//                deleteRows.append(nextIndexPath)
//            }
//
//            if hasError {
//                insertRows.append(nextIndexPath)
//            }
//        }
//
//        state.input = newInputCard
//        state.action = .none
//        state.uiState?.action = .updateRows(insertRows,
//                                            deleteRows,
//                                            reloadRows,
//                                            [indexPath, indexPathButton])
//        state.setNeedUpdateUI = true
//    }
//}
//
//
//private struct ShowCardQuery: SystemQuery {
//    
//    func react(state: StakingTransfer.Card) ->  Self? {
//        return state.action == .load ? self : nil
//    }
//    
//    func effects(query: Self) -> Signal<StakingTransfer.Card.Event> {
//        
//        let balance: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
//                                                                                            ticker: "USDN"),
//                                                                            money: Money.init(0,
//                                                                                              2))
//        
//        let max: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
//                        ticker: "USDN"),
//                                                                        money: Money.init(1000,
//                                                                                          2))
//        
//        let card: StakingTransfer.DTO.Data.Card = StakingTransfer.DTO.Data.Card.init(asset: .init(id: "",
//                                                                                        gatewayId: "",
//                                                                                        wavesId: "",
//                                                                                        name: "USDN",
//                                                                                        precision: 2,
//                                                                                        description: "",
//                                                                                        height: 1,
//                                                                                        timestamp: Date(),
//                                                                                        sender: "",
//                                                                                        quantity: 10,
//                                                                                        ticker: "USDN",
//                                                                                        isReusable: false,
//                                                                                        isSpam: false,
//                                                                                        isFiat: false,
//                                                                                        isGeneral: false,
//                                                                                        isMyWavesToken: false,
//                                                                                        isWavesToken: false,
//                                                                                        isGateway: false,
//                                                                                        isWaves: false,
//                                                                                        modified: Date(),
//                                                                                        addressRegEx: "",
//                                                                                        iconLogoUrl: nil,
//                                                                                        hasScript: false,
//                                                                                        minSponsoredFee: 10,
//                                                                                        gatewayType: nil),
//                                                                           minAmount: balance,
//                                                                           maxAmount: max)
//        
//        return Signal.just(.newData(card))
//    }
//}
