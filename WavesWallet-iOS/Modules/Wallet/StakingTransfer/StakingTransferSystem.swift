//
//  StakingTransferSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import Extensions
import DomainLayer

final class StakingTransferSystem: System<StakingTransfer.State, StakingTransfer.Event> {
    
    private var kind: StakingTransfer.DTO.Kind = .deposit
    
    override func initialState() -> State! {

        
        let core: State.Core = State.Core(kind: self.kind,
                                          action: .none,
                                          data: nil,
                                          input: nil)
        
        let ui: State.UI = .initialState(kind: self.kind)
        
        return State(ui: ui,
                     core: core)
    }

    override func internalFeedbacks() -> [Feedback] {
        return [ShowCardQuery().feedBack, ShowDepositQuery().feedBack]
        
    }

    override func reduce(event: Event, state: inout State) {
        
        switch state.core.kind {
        case .card:
            return reduceForCard(event: event, state: &state)
            
        case .deposit:
            return reduceForDeposit(event: event, state: &state)
            
        case .withdraw:
            break
        }
    }
        
    func reduceForCard(event: Event, state: inout State) {
        
        switch event {
        case .viewDidAppear:
            
            state.core.action = .loadCard
          
        case .tapAssistanceButton(let assistanceButton):
            
            guard case .max = assistanceButton else { return }
            guard let card = state.core.data?.card else { return }
            
            let money = card.maxAmount.money
                
            let indexPath = IndexPath(row: 0, section: 0)
            
            changeCardStateAfterInput(input: money,
                                      indexPath: indexPath,
                                      state: &state)
                        
        case .input(let input, let indexPath):
            
            changeCardStateAfterInput(input: input,
                                      indexPath: indexPath,
                                      state: &state)
            
        case .showCard(let card):
            
            state.core.action = .none
            state.core.data = .card(card)
            
            state.ui.sections = card.sections(input: state.core.input?.card)
            state.ui.action = .update

        case .tapSendButton:
            
            guard let card = state.core.data?.card else { return }
            
            let rowsCount = state.ui.sections[0].rows.count
            let indexPath = IndexPath(row: max(rowsCount - 1, 0), section: 0)
                                            
            state.ui.replace(row: card.button(status: .loading), indexPath: indexPath)
            state.ui.action = .updateRows([],
                                          [],
                                          [],
                                          [indexPath])
            
            state.core.action = .sendCard
        default:
            break
        }
    }
    
    func reduceForDeposit(event: Event, state: inout State) {
         
         switch event {
         case .viewDidAppear:
             
            state.ui.action = .none
            state.core.action = .loadDeposit
           
         case .tapAssistanceButton(let assistanceButton):
                         
            state.ui.action = .none
            
//             guard case .max = assistanceButton else { return }
             
//             guard let money = state.core.data?.deposit?.maxAmount.money else { return }
                 
//             let indexPath = IndexPath(row: 0, section: 0)
             
//             changeDepositStateAfterInput(input: money,
//                                          indexPath: indexPath,
//                                          state: &state)
                         
         case .input(let input, let indexPath):
             
            state.ui.action = .none
            changeDepositStateAfterInput(input: input,
                                         indexPath: indexPath,
                                         state: &state)
             
         case .showDeposit(let deposit):
             
             state.core.action = .none
             state.core.data = .deposit(deposit)
             
             state.ui.sections = deposit.sections(input: state.core.input?.deposit)
             state.ui.action = .update

         case .tapSendButton:
             
             guard let card = state.core.data?.card else { return }
             
             let rowsCount = state.ui.sections[0].rows.count
             let indexPath = IndexPath(row: max(rowsCount - 1, 0), section: 0)
                                             
             state.ui.replace(row: card.button(status: .loading), indexPath: indexPath)
             state.ui.action = .updateRows([],
                                           [],
                                           [],
                                           [indexPath])
             
             state.core.action = .sendCard
         default:
             break
         }
     }
}


private extension StakingTransferSystem {
 
    func changeDepositStateAfterInput(input: Money?, indexPath: IndexPath, state: inout State) {
        
        guard let deposit = state.core.data?.deposit else { return }
        
    }
            
    func changeCardStateAfterInput(input: Money?, indexPath: IndexPath, state: inout State) {

        guard let card = state.core.data?.card else { return }
        
        let prevInputCard = state.core.input?.card
        let minAmount = card.minAmount
        let maxAmount = card.maxAmount
        
        var error: StakingTransfer.DTO.InputData.Card.Error? = nil
        
        if let input = input {
            if input > maxAmount.money {
                error = .maxAmount
            } else if input < minAmount.money {
                error = .minAmount
            }
        }
        
        let newInputCard: StakingTransfer.DTO.InputData.Card = .init(amount: input, error: error)
        
        state.core.input = .card(newInputCard)
        state.core.action = .none
        
        let hasPrevError = prevInputCard?.error != nil
        let hasError = error != nil
        let reloadError = hasPrevError && hasError
        
        let inputField = card.inputField(input: newInputCard)
        
        state.ui.remove(indexPath: indexPath)
        state.ui.add(row: inputField, indexPath: indexPath)
        
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        
        if hasPrevError {
            state.ui.remove(indexPath: nextIndexPath)
        }
        
        let rowsCount = state.ui.sections[0].rows.count
        let indexPathButton = IndexPath(row: max(rowsCount - 1, 0), section: 0)
        
        if let error = newInputCard.error, hasError == true {
            state.ui.add(row: card.error(by: error), indexPath: nextIndexPath)
        }
        
        state.ui.replace(row: card.button(status: hasError == true ? .disabled : .active), indexPath: indexPathButton)
        
        var insertRows: [IndexPath] = .init()
        var deleteRows: [IndexPath] = .init()
        var reloadRows: [IndexPath] = .init()
        
        if reloadError {
            reloadRows.append(nextIndexPath)
        } else  {
            
            if hasPrevError {
                deleteRows.append(nextIndexPath)
            }
            
            if hasError {
                insertRows.append(nextIndexPath)
            }
        }
        
        state.core.action = .none
        state.ui.action = .updateRows(insertRows,
                                      deleteRows,
                                      reloadRows,
                                      [indexPath, indexPathButton])
    }
}

fileprivate extension DomainLayer.DTO.Asset {
    
    static func assetUSDN() -> DomainLayer.DTO.Asset {
        return .init(id: "",
                     gatewayId: "",
                     wavesId: "",
                     name: "USDN",
                     precision: 6,
                     description: "",
                     height: 1,
                     timestamp: Date(),
                     sender: "",
                     quantity: 10,
                     ticker: "USDN",
                     isReusable: false,
                     isSpam: false,
                     isFiat: false,
                     isGeneral: false,
                     isMyWavesToken: false,
                     isWavesToken: false,
                     isGateway: false,
                     isWaves: false,
                     modified: Date(),
                     addressRegEx: "",
                     iconLogoUrl: nil,
                     hasScript: false,
                     minSponsoredFee: 10,
                     gatewayType: nil)
    }
}


private struct ShowCardQuery: SystemQuery {
    
    func react(state: StakingTransfer.State) ->  Self? {
        return state.core.action == .loadCard ? self : nil
    }
    
    func effects(query: Self) -> Signal<StakingTransfer.Event> {
        
        let balance: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
                                                                                            ticker: "USDN"),
                                                                            money: Money.init(0,
                                                                                              2))
        
        let max: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
                        ticker: "USDN"),
                                                                        money: Money.init(1000,
                                                                                          2))
        
        let card: StakingTransfer.DTO.Data.Card = StakingTransfer.DTO.Data.Card.init(asset: .assetUSDN(),
                                                                                     minAmount: balance,
                                                                                     maxAmount: max)
        
        return Signal.just(.showCard(card))
    }
}

private struct ShowDepositQuery: SystemQuery {
    
    func react(state: StakingTransfer.State) ->  Self? {
        return state.core.action == .loadDeposit ? self : nil
    }
    
    func effects(query: Self) -> Signal<StakingTransfer.Event> {
        
        let balance: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
                                                                                            ticker: "USDN"),
                                                                            money: Money.init(0, 2))
        
        let max: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
                                                                                        ticker: "USDN"),
                                                                        money: Money.init(1000,
                                                                                          2))
        
        let deposit: StakingTransfer.DTO.Data.Deposit = .init(asset: DomainLayer.DTO.Asset.assetUSDN(),
                                                              availableBalance: balance,
                                                              transactionFeeBalance: max)
        
        return Signal.just(.showDeposit(deposit))
    }
}
