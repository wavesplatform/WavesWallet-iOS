//
//  AddressesKeysPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol AddressesKeysModuleOutput: AnyObject {
    func addressesKeysNeedPrivateKey(wallet: DomainLayer.DTO.Wallet, callback: @escaping ((DomainLayer.DTO.SignedWallet) -> Void))
}

protocol AddressesKeysModuleInput {
    var wallet: DomainLayer.DTO.Wallet { get }
}

protocol AddressesKeysPresenterProtocol {

    typealias Feedback = (Driver<AddressesKeysTypes.State>) -> Signal<AddressesKeysTypes.Event>

    var moduleOutput: AddressesKeysModuleOutput? { get set }
    var moduleInput: AddressesKeysModuleInput! { get set }
    func system(feedbacks: [Feedback])
}

final class AddressesKeysPresenter: AddressesKeysPresenterProtocol {

    fileprivate typealias Types = AddressesKeysTypes

    private let disposeBag: DisposeBag = DisposeBag()
    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let aliasesRepository: AliasesRepositoryProtocol = FactoryRepositories.instance.aliasesRepository

    var moduleInput: AddressesKeysModuleInput!

//    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    weak var moduleOutput: AddressesKeysModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(getAliasesQuery())
        newFeedbacks.append(getPrivateKeyQuery())
//        newFeedbacks.append(blockQuery())
//        newFeedbacks.append(deleteAccountQuery())
//        newFeedbacks.append(logoutAccountQuery())
//        newFeedbacks.append(handlerEvent())
//        newFeedbacks.append(setBackupQuery())

        let initialState = self.initialState(moduleInput: moduleInput)

        let system = Driver.system(initialState: initialState,
                                   reduce: AddressesKeysPresenter.reduce,
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - Feedbacks

fileprivate extension AddressesKeysPresenter {

    func getAliasesQuery() -> Feedback {

        return react(query: { state -> String? in

            if state.displayState.isAppeared == true {
                return state.wallet.address
            } else {
                return nil
            }

        }, effects: { [weak self] accountAddress -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .aliasesRepository
                .aliases(accountAddress: accountAddress)
                .map { Types.Event.setAliaces($0) }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }

    func getPrivateKeyQuery() -> Feedback {

        return react(query: { state -> DomainLayer.DTO.Wallet? in

            if case .getPrivateKey? = state.query {
                return state.wallet
            } else {
                return nil
            }

        }, effects: { [weak self] wallet -> Signal<Types.Event> in

            return Observable.create({ [weak self] (observer) -> Disposable in

                guard let strongSelf = self else { return Disposables.create() }
                
                strongSelf
                    .moduleOutput?
                    .addressesKeysNeedPrivateKey(wallet: wallet, callback: { signedWallet in
                        observer.onNext(.setPrivateKey(signedWallet))
                        observer.onCompleted()
                    })

                return Disposables.create()
            })
            .asSignal(onErrorRecover: { _ in
                return Signal.empty()
            })
        })
    }
}

// MARK: Core State

private extension AddressesKeysPresenter {

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    static func reduce(state: inout Types.State, event: Types.Event) {

        switch event {
        case .viewWillAppear:
            state.displayState.isAppeared = true
            state.displayState.action = .update

            let sections = [Types.ViewModel.Section(rows: [.skeleton,
                                                           .address(state.wallet.address),
                                                           .publicKey(state.wallet.publicKey),
                                                           .hiddenPrivateKey])]
            state.displayState.sections = sections

        case .setAliaces(let aliaces):
            state.aliaces = aliaces

            var sections = state.displayState.sections
            guard var section = sections.first else { return }
            var rows = section.rows

            guard rows.first != nil else { return }

            rows[0] = .aliases(aliaces.count)
            section.rows = rows
            sections[0] = section

            state.displayState.action = .update
            state.displayState.sections = sections

        case .tapShowPrivateKey:
            state.query = .getPrivateKey

        case .setPrivateKey(let signedWallet):


            var sections = state.displayState.sections
            guard var section = sections.first else { return }
            var rows = section.rows

            guard rows.first != nil else { return }

            let key = signedWallet.privateKey.words.joined(separator: " ")
            rows[3] = .privateKey(key)
            section.rows = rows
            sections[0] = section

            state.displayState.action = .update
            state.displayState.sections = sections

        case .completedQuery:
            state.query = nil

        }

    }
}

// MARK: UI State

private extension AddressesKeysPresenter {

    func initialState(moduleInput: AddressesKeysModuleInput) -> Types.State {
        return Types.State(wallet: moduleInput.wallet,
                           aliaces: [],
                           query: nil,
                           displayState: initialDisplayState())
    }

    func initialDisplayState() -> Types.DisplayState {

//        let sections = [Types.ViewModel.Section.init(rows: [.aliases(8),
//                                                            .address("3PCjZftzzhtY4ZLLBfsyvNxw8RwAgXZVZJW"),
//                                                            .publicKey("4T25bAunzydwvzkJcQ9f378UzGRqyUcDXLS4xgam7JQQ 4T25bAunzydwvzkJcQ9f378UzGRqyUcDXLS4xgam7JQQ"),
//                                                            .hiddenPrivateKey])]
        return Types.DisplayState(sections: [],
                                  isAppeared: false,
                                  action: nil)
    }
}
