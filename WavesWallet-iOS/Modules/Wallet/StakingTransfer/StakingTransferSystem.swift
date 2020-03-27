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
import WavesSDK

final class StakingTransferSystem: System<StakingTransfer.State, StakingTransfer.Event> {
    
    private let kind: StakingTransfer.DTO.Kind
    
    private let assetId: String
    
    private let stakingTransferInteractor: StakingTransferInteractor = StakingTransferInteractor()
    
    init(assetId: String, kind: StakingTransfer.DTO.Kind) {
        self.assetId = assetId
        self.kind = kind
    }
    
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
        return [queryCard(),
                queryDeposit(),
                queryWithdraw(),
                querySendDeposit(),
                querySendWithdraw(),
                querySendCard()]
        
    }
    
    override func reduce(event: Event, state: inout State) {
        
        switch state.core.kind {
        case .card:
            return reduceForCard(event: event, state: &state)
            
        case .deposit:
            return reduceForTransfer(event: event, state: &state)
            
        case .withdraw:
            return reduceForTransfer(event: event, state: &state)
        }
    }
    
}

// MARK: Reduce Card

private extension StakingTransferSystem {
    
    func reduceForCard(event: Event, state: inout State) {
                        
        switch event {
        case .viewDidAppear:
            
            let updateRows = updateCardButton(state: &state,
                                              status: .loading)
            
            state.ui.action = .update(updateRows, error: nil)
            
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
            
        case .completedSendCard(let url):

            state.core.action = .none
            let updateRows = updateCardButton(state: &state,
                                              status: .active)
            
            state.ui.action = .completedCard(updateRows, url)
            
            
        case .handlerError(let error):
            state.core.action = .none
            let updateRows = updateCardButton(state: &state,
                                              status: .active)
            
            state.ui.action = .update(updateRows, error: DisplayError(error: error))
            
        case .showCard(let card):
            
            state.core.action = .none
            state.core.data = .card(card)
            
            state.ui.sections = card.sections(input: state.core.input?.card)
            state.ui.action = .update(nil, error: nil)
            
        case .tapSendButton:
            
            let updateRows = updateCardButton(state: &state, status: .active)
            state.core.action = .sendCard
            state.ui.action = .update(updateRows, error: nil)
        default:
            state.core.action = .none
            state.ui.action = .none
        }
    }
}

// MARK: Reduce Deposit

private extension StakingTransferSystem {
    
    func reduceForTransfer(event: Event, state: inout State) {
        
        switch event {
        case .viewDidAppear:
            
            state.ui.action = .none
            
            switch state.core.kind {
            case .deposit:
                state.core.action = .loadDeposit
            case .withdraw:
                state.core.action = .loadWithdraw
            default:
                state.core.action = .none
            }
            
        case .tapAssistanceButton(let assistanceButton):
            
            let balance = state.core.data?.transfer?.balance.money
            guard let money = balance?.calculatePercent(assistanceButton.percent) else { return }
            
            let indexPath = IndexPath(row: 1, section: 0)
            
            changeTransferStateAfterInput(input: money,
                                          inputIndexPath: indexPath,
                                          state: &state)
            
        case .input(let input, let indexPath):
            
            state.ui.action = .none
            changeTransferStateAfterInput(input: input,
                                          inputIndexPath: indexPath,
                                          state: &state)
        case .completedSendWithdraw(let tx):

            guard let asset = state.core.data?.transfer?.asset else {
                state.ui.action = .none
                state.core.action = .none
                return
            }
            guard let amount = state.core.input?.transfer?.amount else {
                state.ui.action = .none
                state.core.action = .none
                return
            }
            
            let balance: DomainLayer.DTO.Balance = asset.balance(amount.amount)
            
            let updateRows = updateTransferButton(state: &state,
                                                  status: .active)
            
            state.ui.action = .completedWithdraw(updateRows, transactions: tx, amount: balance)
            
        case .completedSendDeposit(let tx):
            
            guard let asset = state.core.data?.transfer?.asset else {
                state.ui.action = .none
                state.core.action = .none
                return
            }
            guard let amount = state.core.input?.transfer?.amount else {
                state.ui.action = .none
                state.core.action = .none
                return
            }
            
            let balance: DomainLayer.DTO.Balance = asset.balance(amount.amount)
                        
            let updateRows = updateTransferButton(state: &state,
                                                  status: .active)
            state.ui.action = .completedDeposit(updateRows, transactions: tx, amount: balance)
            
        case .showDeposit(let deposit):
            
            state.core.action = .none
            state.core.data = .deposit(deposit)
            let kind = state.core.kind
            
            state.ui.sections = deposit.sections(input: state.core.input?.deposit,
                                                 kind: kind)
            state.ui.action = .update(nil, error: nil)
            
        case .showWithdraw(let withdraw):
            
            state.core.action = .none
            state.core.data = .withdraw(withdraw)
            
            state.ui.sections = withdraw.sections(input: state.core.input?.withdraw,
                                                  kind: kind)
            state.ui.action = .update(nil, error: nil)
            
        case .tapSendButton:
            
            let updateRows = updateTransferButton(state: &state, status: .loading)
            
            state.ui.action = .update(updateRows, error: nil)
            
            switch state.core.kind {
            case .deposit:
                state.core.action = .sendDeposit
            case .withdraw:
                state.core.action = .sendWithdraw
            default:
                state.core.action = .none
            }
            
        case .handlerError(let error):
            
            state.core.action = .none
            let updateRows = updateTransferButton(state: &state,
                                                  status: .active)
            
            state.ui.action = .update(updateRows, error: DisplayError(error: error))
        default:
            state.core.action = .none
            state.ui.action = .none
        }
    }
    
    private func updateTransferButton(state: inout State,
                                      status: BlueButton.Model.Status) -> StakingTransfer.State.UI.UpdateRows? {
        
        guard let transfer = state.core.data?.transfer else { return nil }
        
        let rowsCount = state.ui.sections[0].rows.count
        let indexPath = IndexPath(row: max(rowsCount - 1, 0), section: 0)
        let kind = state.core.kind
        
        let button = transfer.button(status: status,
                                     kind: kind)
        
        state.ui.replace(row: button,
                         indexPath: indexPath)
        
        return .init(insertRows: [],
                     deleteRows: [],
                     reloadRows: [],
                     updateRows: [indexPath])
    }
    
    private func updateCardButton(state: inout State,
                                  status: BlueButton.Model.Status) -> StakingTransfer.State.UI.UpdateRows? {
        
        guard let card = state.core.data?.card else { return nil }
        
        let rowsCount = state.ui.sections[0].rows.count
        let indexPath = IndexPath(row: max(rowsCount - 1, 0), section: 0)
            
        let button = card.button(status: status)
        
        state.ui.replace(row: button,
                         indexPath: indexPath)
        
        return .init(insertRows: [],
                     deleteRows: [],
                     reloadRows: [],
                     updateRows: [indexPath])
    }
}


// MARK: Change Trasnfer After Input

private extension StakingTransferSystem {
    
    func changeTransferStateAfterInput(input: Money?, inputIndexPath: IndexPath, state: inout State) {
        
        guard let transfer = state.core.data?.transfer else { return }
        
        let kind = state.core.kind
        
        let balance = transfer.balance.money
        
        let avaliableBalanceForFee = transfer.avaliableBalanceForFee.money
        
        let transactionFeeBalance = transfer.transactionFeeBalance.money
        
        let prevInputTransfer = state.core.input?.transfer
        
        var error: StakingTransfer.DTO.InputData.Transfer.Error? = nil
        
        if let input = input {
            
            if input.amount > balance.amount {
                error = .insufficientFunds
            } else if avaliableBalanceForFee.amount < transactionFeeBalance.amount {
                error = .insufficientFundsOnTax
            }
        }
        
        let newInputTrasnfer: StakingTransfer.DTO.InputData.Transfer = .init(amount: input, error: error)
        
        switch kind {
        case .withdraw:
            state.core.input = .withdraw(newInputTrasnfer)
        case .deposit:
            state.core.input = .deposit(newInputTrasnfer)
        default:
            state.core.input = nil
        }
        
        state.core.action = .none
        
        let hasPrevError = prevInputTransfer?.error != nil
        let hasError = error != nil
        let reloadError = hasPrevError && hasError
        
        let inputField = transfer.inputField(input: newInputTrasnfer,
                                             kind: kind)
        
        state.ui.remove(indexPath: inputIndexPath)
        state.ui.add(row: inputField, indexPath: inputIndexPath)
        
        let nextIndexPath = IndexPath(row: inputIndexPath.row + 1, section: inputIndexPath.section)
        
        if hasPrevError {
            state.ui.remove(indexPath: nextIndexPath)
        }
        
        let rowsCount = state.ui.sections[0].rows.count
        let indexPathButton = IndexPath(row: max(rowsCount - 1, 0), section: 0)
        
        if let error = newInputTrasnfer.error, hasError == true {
            
            let errorRow = transfer.error(by: error, kind: kind)
            state.ui.add(row: errorRow, indexPath: nextIndexPath)
        }
        
        let button = transfer.button(status: hasError == true ? .disabled : .active,
                                     kind: kind)
        
        state.ui.replace(row: button,
                         indexPath: indexPathButton)
        
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
        state.ui.action = .update(.init(insertRows: insertRows,
                                        deleteRows: deleteRows,
                                        reloadRows: reloadRows,
                                        updateRows: [inputIndexPath, indexPathButton]),
                                  error: nil)
    }
    
    func changeCardStateAfterInput(input: Money?, indexPath: IndexPath, state: inout State) {
        
        guard let card = state.core.data?.card else { return }
        
        let prevInputCard = state.core.input?.card
        let minAmount = card.minAmount
        let maxAmount = card.maxAmount
        
        var error: StakingTransfer.DTO.InputData.Card.Error? = nil
        
        if let input = input {
            error = card.errorKind(amount: input)
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
        
        if let error = newInputCard.error, hasError == true {
            state.ui.add(row: card.error(by: error), indexPath: nextIndexPath)
        }
        
        let rowsCount = state.ui.sections[0].rows.count
        let indexPathButton = IndexPath(row: max(rowsCount - 1, 0), section: 0)
        
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
        
        state.ui.action = .update(.init(insertRows: insertRows,
                                        deleteRows: deleteRows,
                                        reloadRows: reloadRows,
                                        updateRows: [indexPath, indexPathButton]),
                                  error: nil)
    }
}

// TODO: Move
extension DomainLayer.DTO.Asset {
    
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

private extension StakingTransferSystem {
    
    func queryCard() -> Feedback {
        
        return react(request: { (state) -> Bool? in
            
            return state.core.action == .loadCard ? true : nil
            
        }, effects: { [weak self] _ -> Signal<StakingTransfer.Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self
                .stakingTransferInteractor
                .card(assetId: self.assetId)
                .map { .showCard($0) }
                .asSignal(onErrorRecover: { Signal.just(.handlerError(NetworkError.error(by: $0))) })
        })
    }
    
    func queryDeposit() -> Feedback {
        
        return react(request: { (state) -> Bool? in
            
            return state.core.action == .loadDeposit ? true : nil
            
        }, effects: { [weak self] _ -> Signal<StakingTransferSystem.Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self
                .stakingTransferInteractor
                .deposit(assetId: self.assetId)
                .map { .showDeposit($0) }
                .asSignal(onErrorRecover: { Signal.just(.handlerError(NetworkError.error(by: $0))) })
        })
    }
    
    func queryWithdraw() -> Feedback {
        
        return react(request: { (state) -> Bool? in
            
            return state.core.action == .loadWithdraw ? true : nil
            
        }, effects: { [weak self] _ -> Signal<StakingTransfer.Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self
                .stakingTransferInteractor
                .withdraw(assetId: self.assetId)
                .map {  .showWithdraw($0) }
                .asSignal(onErrorRecover: { Signal.just(.handlerError(NetworkError.error(by: $0))) })
        })
    }
    
    private struct TransferQuery: Hashable {
        let amount: Money
        let assetId: String
    }
    
    func querySendWithdraw() -> Feedback {
        
        return react(request: { [weak self] (state) -> TransferQuery? in
            
            guard let self = self else { return nil }
            
            if state.core.action == .sendWithdraw, let amount = state.core.input?.transfer?.amount {
                return TransferQuery(amount: amount,
                                     assetId: self.assetId)
            }
            
            return nil
            
            }, effects: { [weak self] query -> Signal<StakingTransfer.Event> in
                
                guard let self = self else { return Signal.empty() }
                
                return self
                    .stakingTransferInteractor
                    .sendWithdraw(amount: query.amount, assetId: query.assetId)
                    .map { .completedSendWithdraw($0) }
                    .asSignal(onErrorRecover: { Signal.just(.handlerError(NetworkError.error(by: $0))) })
        })
    }
    
    func querySendDeposit() -> Feedback {
        
        return react(request: { [weak self] (state) -> TransferQuery? in
            
            guard let self = self else { return nil }
            
            if state.core.action == .sendDeposit, let amount = state.core.input?.transfer?.amount {
                return TransferQuery(amount: amount,
                                     assetId: self.assetId)
            }
            
            return nil
            
            }, effects: { [weak self] query -> Signal<StakingTransfer.Event> in
                
                guard let self = self else { return Signal.empty() }
                
                return self
                    .stakingTransferInteractor
                    .sendDeposit(amount: query.amount,
                                 assetId: query.assetId)
                    .map { .completedSendDeposit($0) }
                    .asSignal(onErrorRecover: { Signal.just(.handlerError(NetworkError.error(by: $0))) })
        })
    }
    
    func querySendCard() -> Feedback {
        
        return react(request: { [weak self] (state) -> TransferQuery? in
            
            guard let self = self else { return nil }
            
            if state.core.action == .sendCard, let amount = state.core.input?.card?.amount{
                return TransferQuery(amount: amount,
                                     assetId: self.assetId)
            }
            
            return nil
            
            }, effects: { [weak self] query -> Signal<StakingTransfer.Event> in
                
                guard let self = self else { return Signal.empty() }
                
                return self
                    .stakingTransferInteractor
                    .sendCard(amount: query.amount, assetId: query.assetId)
                    .map { .completedSendCard($0) }
                    .asSignal(onErrorRecover: { Signal.just(.handlerError(NetworkError.error(by: $0))) })
        })
    }
}
