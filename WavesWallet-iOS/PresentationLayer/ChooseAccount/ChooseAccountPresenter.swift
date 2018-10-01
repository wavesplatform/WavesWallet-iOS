//
//  ChooseAccountPresenter.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

protocol ChooseAccountModuleOutput: AnyObject {
    func userChoouseAccount(wallet: DomainLayer.DTO.Wallet) -> Void
}

protocol ChooseAccountModuleInput {
}

protocol ChooseAccountPresenterProtocol {

    typealias Feedback = (Driver<ChooseAccountTypes.State>) -> Signal<ChooseAccountTypes.Event>

    var input: ChooseAccountModuleInput! { get set }
    var moduleOutput: ChooseAccountModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

private struct DeleteWalletQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let indexPath: IndexPath
}

final class ChooseAccountPresenter: ChooseAccountPresenterProtocol {

    fileprivate typealias Types = ChooseAccountTypes
    
    var input: ChooseAccountModuleInput!
    weak var moduleOutput: ChooseAccountModuleOutput?

    private var walletsInteractor: WalletsInteractorProtocol = FactoryInteractors.instance.wallets

    private let disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(walletsFeedback())
        newFeedbacks.append(removeWallet())

        let initialState = self.initialState()
        let system = Driver.system(initialState: initialState,
                                   reduce: { [weak self] state, event -> Types.State in
                                       self?.reduce(state: state, event: event) ?? state
                                   },
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }

    private func walletsFeedback() -> Feedback {
        return react(query: { state -> Bool? in
            state.isAppeared == true ? true : nil
        }, effects: { [weak self] _ -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .walletsInteractor
                .wallets()
                .map { Types.Event.setWallets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func removeWallet() -> Feedback {
        return react(query: { state -> DeleteWalletQuery? in
            if let action = state.action, case .removeWallet(let wallet, let indexPath) = action {
                return DeleteWalletQuery(wallet: wallet, indexPath: indexPath)
            }

            return nil
        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .walletsInteractor
                .deleteWallet(query.wallet)
                .map { _ in Types.Event.completedDeleteWallet(indexPath: query.indexPath) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
}

// MARK: Core State

private extension ChooseAccountPresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {
        switch event {
        case .readyView:
            return state.mutate {
                $0.isAppeared = true
            }

        case .setWallets(let wallets):
            return state.mutate {
                $0.displayState.wallets = wallets
                $0.displayState.action = .reload
            }

        case .tapWallet(let wallet):
            moduleOutput?.userChoouseAccount(wallet: wallet)
            return state.mutate(transform: {
                $0.displayState.action = .none                
            })

        case .tapRemoveButton(let wallet, let indexPath):
             return state.mutate {
                $0.displayState.action = .none
                $0.action = .removeWallet(wallet, indexPath: indexPath)
            }
            
        case .completedDeleteWallet(let indexPath):

            
            return state.mutate {
                $0.action = nil
                var wallets = $0.displayState.wallets
                wallets.remove(at: indexPath.row)
                $0.displayState.wallets = wallets
                $0.displayState.action = .remove(indexPath: indexPath)
            }

        case .tapEditButton(let wallet):
            return state.mutate(transform: { $0.displayState.action = .none })

        default:
            break
        }
        return state.mutate(transform: { $0.displayState.action = .none })
    }
}

// MARK: UI State

private extension ChooseAccountPresenter {

    func initialState() -> Types.State {
        return Types.State(displayState: initialDisplayState(), action: nil, isAppeared: false)
    }

    func initialDisplayState() -> Types.DisplayState {
        return Types.DisplayState(wallets: [], action: .none)
    }
}
