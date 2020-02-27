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
    
    private var kind: StakingTransfer.DTO.Kind = .card
    
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
        return [ShowCardQuery().feedBack]
        
    }

    override func reduce(event: Event, state: inout State) {
        
        switch state.core.kind {
        case .card:
            return reduceForCard(event: event, state: &state)
            
        case .deposit:
            break
            
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
            
            guard let money = state.core.data?.card?.maxAmount.money else { return }
                
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
            
            state.ui.sections = card.sections(inputCard: state.core.input?.card)
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
             
             state.core.action = .loadCard
           
         case .tapAssistanceButton(let assistanceButton):
             
             guard case .max = assistanceButton else { return }
             
             guard let money = state.core.data?.card?.maxAmount.money else { return }
                 
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
             
             state.ui.sections = card.sections(inputCard: state.core.input?.card)
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
 
    func changeCardStateAfterInput(input: Money?, indexPath: IndexPath, state: inout State) {

        guard let card = state.core.data?.card else { return }
        
        let prevInputCard = state.core.input?.card
        let minAmount = card.minAmount
        let maxAmount = card.maxAmount
        
        var error: StakingTransfer.DTO.InputCard.Error? = nil
        
        if let input = input {
            if input > maxAmount.money {
                error = .maxAmount
            } else if input < minAmount.money {
                error = .minAmount
            }
        }
        
        let newInputCard: StakingTransfer.DTO.InputCard = .init(amount: input, error: error)
        
        state.core.input = .card(newInputCard)
        state.core.action = .none
        
        let hasPrevError = prevInputCard?.error != nil
        let hasError = error != nil
        let reloadError = hasPrevError && hasError
        
        let inputField = card.inputField(inputCard: newInputCard)
        
        state.ui.remove(indexPath: indexPath)
        state.ui.add(row: inputField, indexPath: indexPath)
        
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        
        if hasPrevError {
            state.ui.remove(indexPath: nextIndexPath)
        }
        
        let rowsCount = state.ui.sections[0].rows.count
        let indexPathButton = IndexPath(row: max(rowsCount - 1, 0), section: 0)
        
        if hasError {
            if let errorRow  = card.error(inputCard: newInputCard) {
                state.ui.add(row: errorRow, indexPath: nextIndexPath)
            }
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
        
        let card: StakingTransfer.DTO.Card = StakingTransfer.DTO.Card.init(asset: .init(id: "",
                                                                                        gatewayId: "",
                                                                                        wavesId: "",
                                                                                        name: "USDN",
                                                                                        precision: 2,
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
                                                                                        gatewayType: nil),
                                                                           minAmount: balance,
                                                                           maxAmount: max)
        
        return Signal.just(.showCard(card))
    }
}
