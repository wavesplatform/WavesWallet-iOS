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
        
        switch event {
        case .viewDidAppear:
            
            switch state.core.kind {
            case .card:
                state.core.action = .loadCard
                
            case .deposit:
                state.core.action = .loadDeposit
                
            case .withdraw:
                state.core.action = .loadWithdraw
                
            }
        case .tapAssistanceButton(let assistanceButton):
            
            switch assistanceButton {
            case .max:
                break
            case .percent100:
                break
            case .percent75:
                break
            case .percent50:
                break
            case .percent25:
                break
            }
            
        case .input(let input):
            
            guard let card = state.core.data?.card else { return }
                        
            let minAmount = card.minAmount
            let maxAmount = card.maxAmount
            
            var error: StakingTransfer.DTO.InputCard.Error? = nil
            
            if input > maxAmount.money {
                error = .maxAmount
            } else if input < minAmount.money {
                error = .minAmount
            }
                        
            state.core.input = .card(.init(amount: input, error: error))
            state.core.action = .none
            
            state.ui.sections = card.sections(inputCard: state.core.input?.card)
            state.ui.action = .update
            
            break
        case .showCard(let card):
            
            state.core.action = .none
            state.core.data = .card(card)
            
            state.ui.sections = card.sections(inputCard: state.core.input?.card)
            state.ui.action = .update
            
        case .showDeposit(let deposit):
            break
            
        case .showWithdraw(let withdraw):
            break
        }
    }
}


private extension StakingTransferSystem {
    
}


private struct ShowCardQuery: SystemQuery {
    
    func react(state: StakingTransfer.State) ->  Self? {
        return state.core.action == .loadCard ? self : nil
    }
    
    func effects(query: Self) -> Signal<StakingTransfer.Event> {
        
        let balance: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
                                                                                            ticker: "USDN"),
                                                                            money: Money.init(1000000,
                                                                                              10))
        
        let card: StakingTransfer.DTO.Card = StakingTransfer.DTO.Card.init(asset: .init(id: "",
                                                                                        gatewayId: "",
                                                                                        wavesId: "",
                                                                                        name: "USDN",
                                                                                        precision: 10,
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
                                                                           maxAmount: balance)
        
        return Signal.just(.showCard(card))
    }
}
