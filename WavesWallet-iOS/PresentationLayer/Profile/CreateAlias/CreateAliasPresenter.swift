//
//  CreateAliasPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol CreateAliasModuleOutput: AnyObject {
//    func addressesKeysNeedPrivateKey(wallet: DomainLayer.DTO.Wallet, callback: @escaping ((DomainLayer.DTO.SignedWallet) -> Void))
//    func addressesKeysShowAliases(_ aliases: [DomainLayer.DTO.Alias])
}

protocol CreateAliasModuleInput {
//    var wallet: DomainLayer.DTO.Wallet { get }
}

protocol CreateAliasPresenterProtocol {

    typealias Feedback = (Driver<CreateAliasTypes.State>) -> Signal<CreateAliasTypes.Event>

    var moduleOutput: CreateAliasModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

final class CreateAliasPresenter: CreateAliasPresenterProtocol {

    fileprivate typealias Types = CreateAliasTypes

    private let disposeBag: DisposeBag = DisposeBag()

    weak var moduleOutput: CreateAliasModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
//        newFeedbacks.append(getAliasesQuery())
//        newFeedbacks.append(getPrivateKeyQuery())
//        newFeedbacks.append(externalQuery())


        let initialState = self.initialState()

        let system = Driver.system(initialState: initialState,
                                   reduce: CreateAliasPresenter.reduce,
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - Feedbacks

fileprivate extension CreateAliasPresenter {

//    func getAliasesQuery() -> Feedback {
//
//        return react(query: { state -> String? in
//
//            if state.displayState.isAppeared == true {
//                return state.wallet.address
//            } else {
//                return nil
//            }
//
//        }, effects: { [weak self] accountAddress -> Signal<Types.Event> in
//
//            guard let strongSelf = self else { return Signal.empty() }
//
//            return strongSelf
//                .aliasesRepository
//                .aliases(accountAddress: accountAddress)
//                .map { Types.Event.setAliases($0) }
//                .sweetDebug("getAliasesQuery")
//                .asSignal(onErrorRecover: { _ in
//                    return Signal.empty()
//                })
//        })
//    }
//
//    func getPrivateKeyQuery() -> Feedback {
//
//        return react(query: { state -> DomainLayer.DTO.Wallet? in
//
//            if case .getPrivateKey? = state.query {
//                return state.wallet
//            } else {
//                return nil
//            }
//
//        }, effects: { [weak self] wallet -> Signal<Types.Event> in
//
//            return Observable.create({ [weak self] (observer) -> Disposable in
//
//                guard let strongSelf = self else { return Disposables.create() }
//
//                strongSelf
//                    .moduleOutput?
//                    .addressesKeysNeedPrivateKey(wallet: wallet, callback: { signedWallet in
//                        observer.onNext(.setPrivateKey(signedWallet))
//                        observer.onCompleted()
//                    })
//
//                return Disposables.create()
//            })
//                .asSignal(onErrorRecover: { _ in
//                    return Signal.empty()
//                })
//        })
//    }
//
//    func externalQuery() -> Feedback {
//
//        return react(query: { state -> Types.Query? in
//
//
//            if case .showInfo? = state.query {
//                return state.query
//            } else {
//                return nil
//            }
//
//        }, effects: { [weak self] query -> Signal<Types.Event> in
//
//            if case .showInfo(let aliases) = query {
//                self?.moduleOutput?.addressesKeysShowAliases(aliases)
//            }
//
//            return Signal.just(.completedQuery)
//        })
//    }
}

// MARK: Core State

private extension CreateAliasPresenter {

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    static func reduce(state: inout Types.State, event: Types.Event) {

        switch event {
        case .viewWillAppear:
            state.displayState.isAppeared = true
            let section = Types.ViewModel.Section(rows: [.input(state.displayState.input)])
            state.displayState.sections = [section]
            state.displayState.action = .update
            
        case .viewDidDisappear:
            state.displayState.isAppeared = false

        case .input(let text):
            state.displayState.input = text
            state.displayState.action = .none

        case .completedQuery:
            state.query = nil
        }
    }
}

// MARK: UI State

private extension CreateAliasPresenter {

    func initialState() -> Types.State {
        return Types.State(query: nil,
                           displayState: initialDisplayState())
    }

    func initialDisplayState() -> Types.DisplayState {

        return Types.DisplayState(sections: [],
                                  input: nil,
                                  isAppeared: false,
                                  action: .update)
    }
}

