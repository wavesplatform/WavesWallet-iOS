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
    
    private var kind: StakingTransfer.DTO.Kind = .withdraw
    
    private let assetId: String
    
    private let stakingTransferInteractor: StakingTransferInteractor = StakingTransferInteractor()
    
    init(assetId: String) {
        self.assetId = assetId
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
                querySendWithdraw()]
        
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
            
            guard case .max = assistanceButton else { return }
            let balance = state.core.data?.deposit?.balance.money
            guard let money = balance?.calculatePercent(assistanceButton.percent) else { return }
            
            let indexPath = IndexPath(row: 0, section: 0)
            
            changeTransferStateAfterInput(input: money,
                                          indexPath: indexPath,
                                          state: &state)
            
        case .input(let input, let indexPath):
            
            state.ui.action = .none
            changeTransferStateAfterInput(input: input,
                                          indexPath: indexPath,
                                          state: &state)
        case .completedSendTransfer:
            break
            
        case .showDeposit(let deposit):
            
            state.core.action = .none
            state.core.data = .deposit(deposit)
            let kind = state.core.kind
            
            state.ui.sections = deposit.sections(input: state.core.input?.deposit,
                                                 kind: kind)
            state.ui.action = .update
            
        case .showWithdraw(let withdraw):
            
            state.core.action = .none
            state.core.data = .withdraw(withdraw)
            
            state.ui.sections = withdraw.sections(input: state.core.input?.withdraw,
                                                  kind: kind)
            state.ui.action = .update
            
        case .tapSendButton:
            
            guard let transfer = state.core.data?.transfer else { return }
            
            let rowsCount = state.ui.sections[0].rows.count
            let indexPath = IndexPath(row: max(rowsCount - 1, 0), section: 0)
            let kind = state.core.kind
            
            let button = transfer.button(status: .loading,
                                         kind: kind)
            
            state.ui.replace(row: button,
                             indexPath: indexPath)
            state.ui.action = .updateRows([],
                                          [],
                                          [],
                                          [indexPath])
            
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
            state.ui.action = .error(DisplayError(error: error))
            
        default:
            state.core.action = .none
            state.ui.action = .none
        }
    }
}


// MARK: Change Trasnfer After Input

private extension StakingTransferSystem {
    
    func changeTransferStateAfterInput(input: Money?, indexPath: IndexPath, state: inout State) {
        
        guard let transfer = state.core.data?.transfer else { return }
        
        let kind = state.core.kind
        
        let balance = transfer.balance.money
        
        let transactionFeeBalance = transfer.transactionFeeBalance.money
        
        let prevInputTransfer = state.core.input?.transfer
        
        var error: StakingTransfer.DTO.InputData.Transfer.Error? = nil
        
        if let input = input {
            if input.amount > balance.amount {
                error = .insufficientFunds
            } else if (balance.amount - input.amount) < transactionFeeBalance.amount {
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
        
        state.ui.remove(indexPath: indexPath)
        state.ui.add(row: inputField, indexPath: indexPath)
        
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        
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
        state.ui.action = .updateRows(insertRows,
                                      deleteRows,
                                      reloadRows,
                                      [indexPath, indexPathButton])
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
    
    
    func querySendWithdraw() -> Feedback {
        
        return react(request: { (state) -> StakingTransfer.DTO.InputData.Transfer? in
            
            return state.core.action == .sendWithdraw ? state.core.input?.transfer : nil
            
        }, effects: { [weak self] input -> Signal<StakingTransfer.Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self
                .stakingTransferInteractor
                .sendWithdraw(transfer: input)
                .map { _ in .completedSendTransfer }
                .asSignal(onErrorRecover: { Signal.just(.handlerError(NetworkError.error(by: $0))) })
        })
    }
    
    func querySendDeposit() -> Feedback {
        
        return react(request: { (state) -> StakingTransfer.DTO.InputData.Transfer? in
            
            return state.core.action == .sendWithdraw ? state.core.input?.transfer : nil
            
        }, effects: { [weak self] input -> Signal<StakingTransfer.Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self
                .stakingTransferInteractor
                .sendDeposit(transfer: input)
                .map { _ in .completedSendTransfer }
                .asSignal(onErrorRecover: { Signal.just(.handlerError(NetworkError.error(by: $0))) })
        })
    }
}


private extension StakingTransfer.DTO.Data.Transfer {
    
    func inputField(input: StakingTransfer.DTO.InputData.Transfer?,
                    kind: StakingTransfer.DTO.Kind) -> StakingTransfer.ViewModel.Row {
        
        switch kind {
        case .withdraw:
            return inputFieldForWithdraw(input: input)
            
        case .deposit:
            return inputFieldForDeposit(input: input)
            
        case .card:
            return .skeletonBalance
        }
    }
    
    func error(by error: StakingTransfer.DTO.InputData.Transfer.Error,
               kind: StakingTransfer.DTO.Kind) -> StakingTransfer.ViewModel.Row {
        
        switch kind {
        case .withdraw:
            return errorForWithdraw(by: error)
            
        case .deposit:
            return errorForDeposit(by: error)
            
        case .card:
            return .skeletonBalance
        }
    }
    
    func button(status: BlueButton.Model.Status,
                kind: StakingTransfer.DTO.Kind) -> StakingTransfer.ViewModel.Row {
        
        switch kind {
        case .withdraw:
            return buttonForWithdraw(status: status)
            
        case .deposit:
            return buttonForDeposit(status: status)
            
        case .card:
            return .skeletonBalance
        }
    }
    
    func sections(input: StakingTransfer.DTO.InputData.Transfer?,
                  kind: StakingTransfer.DTO.Kind) -> [StakingTransfer.ViewModel.Section] {
        
        switch kind {
        case .withdraw:
            return sectionsForWithdraw(input: input)
            
        case .deposit:
            return sectionsForDeposit(input: input)
            
        case .card:
            return []
        }
    }
}


