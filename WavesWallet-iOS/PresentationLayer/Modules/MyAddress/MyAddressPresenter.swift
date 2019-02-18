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

protocol MyAddressModuleOutput: AnyObject {
    func myAddressShowAliases(_ aliases: [DomainLayer.DTO.Alias])
}

protocol MyAddressPresenterProtocol {

    typealias Feedback = (Driver<MyAddressTypes.State>) -> Signal<MyAddressTypes.Event>

    var moduleOutput: MyAddressModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

final class MyAddressPresenter: MyAddressPresenterProtocol {

    fileprivate typealias Types = MyAddressTypes

    private let disposeBag: DisposeBag = DisposeBag()
    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let aliasesRepository: AliasesRepositoryProtocol = FactoryRepositories.instance.aliasesRepositoryRemote

    weak var moduleOutput: MyAddressModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(getWalletQuery())
        newFeedbacks.append(getAliasesQuery())
        newFeedbacks.append(externalQuery())


        let initialState = self.initialState()

        let system = Driver.system(initialState: initialState,
                                   reduce: MyAddressPresenter.reduce,
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - Feedbacks

fileprivate extension MyAddressPresenter {

    func getWalletQuery() -> Feedback {

        return react(query: { state -> Bool? in

            if state.displayState.isAppeared == true {
                return true
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .authorizationInteractor
                .authorizedWallet()
                .map { Types.Event.setWallet($0.wallet) }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }


    func getAliasesQuery() -> Feedback {

        return react(query: { state -> String? in

            if case .getAliases? = state.query {
                return state.wallet?.address
            } else {
                return nil
            }

        }, effects: { [weak self] accountAddress -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .aliasesRepository
                .aliases(accountAddress: accountAddress)
                .map { Types.Event.setAliases($0) }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }

    func externalQuery() -> Feedback {

        return react(query: { state -> Types.Query? in


            if case .showInfo? = state.query {
                return state.query
            } else {
                return nil
            }

        }, effects: { [weak self] query -> Signal<Types.Event> in

            if case .showInfo(let aliases) = query {
                self?.moduleOutput?.myAddressShowAliases(aliases)
            }

            return Signal.just(.completedQuery)
        })
    }
}

// MARK: Core State

private extension MyAddressPresenter {

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    static func reduce(state: inout Types.State, event: Types.Event) {

        switch event {
        case .viewWillAppear:
            state.displayState.isAppeared = true
            state.query = .getWallet

        case .viewDidDisappear:
            state.displayState.isAppeared = false

        case .setWallet(let wallet):
            state.wallet = wallet

            let section = Types.ViewModel.Section(rows: [.address(wallet.address),
                                                         .skeleton,
                                                         .qrcode(address: wallet.address)])

            state.displayState.sections = [section]
            state.displayState.action = .update
            state.query = .getAliases

        case .setAliases(let aliaces):
            state.query = nil
            state.aliases = aliaces

            var sections = state.displayState.sections
            guard var section = sections.first else { return }
            var rows = section.rows

            guard rows.first != nil else { return }

            rows[1] = .aliases(aliaces.count)
            section.rows = rows
            sections[0] = section

            state.displayState.action = .update
            state.displayState.sections = sections

        case .tapShowInfo:
            state.query = .showInfo(aliases: state.aliases)

        case .completedQuery:
            state.query = nil
        }
    }
}

// MARK: UI State

private extension MyAddressPresenter {

    func initialState() -> Types.State {
        return Types.State(wallet: nil,
                           aliases: [],
                           query: nil,
                           displayState: initialDisplayState())
    }

    func initialDisplayState() -> Types.DisplayState {

        return Types.DisplayState(sections: [],
                                  isAppeared: false,
                                  action: .none)
    }
}
