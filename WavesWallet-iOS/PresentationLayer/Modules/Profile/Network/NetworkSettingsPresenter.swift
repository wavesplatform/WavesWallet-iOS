//
//  NetworkPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

protocol NetworkSettingsModuleOutput: AnyObject {
    func networkSettingSavedSetting()
}

protocol NetworkSettingsModuleInput {
    var wallet: DomainLayer.DTO.Wallet { get }
}

protocol NetworkSettingsPresenterProtocol {

    typealias Feedback = (Driver<NetworkSettingsTypes.State>) -> Signal<NetworkSettingsTypes.Event>
    var moduleOutput: NetworkSettingsModuleOutput? { get set }
    var input: NetworkSettingsModuleInput! { get set }
    func system(feedbacks: [Feedback])
}

final class NetworkSettingsPresenter: NetworkSettingsPresenterProtocol {

    fileprivate typealias Types = NetworkSettingsTypes
    weak var moduleOutput: NetworkSettingsModuleOutput?
    var input: NetworkSettingsModuleInput!

    private var accountSettingsRepository: AccountSettingsRepositoryProtocol = FactoryRepositories.instance.accountSettingsRepository
    private var environmentRepository: EnvironmentRepositoryProtocol = FactoryRepositories.instance.environmentRepository

    private let disposeBag: DisposeBag = DisposeBag()

    init(input: NetworkSettingsModuleInput) {
        self.input = input
    }

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(environmentsQuery())
        newFeedbacks.append(deffaultEnvironmentQuery())
        newFeedbacks.append(saveEnvironmentQuery())
        newFeedbacks.append(handlerExternalQuery())

        let initialState = self.initialState(wallet: input.wallet)
        let system = Driver.system(initialState: initialState,
                                   reduce: NetworkSettingsPresenter.reduce,
                                   feedback: newFeedbacks)

        system
            .drive()
            .disposed(by: disposeBag)
    }

    private func handlerExternalQuery() -> Feedback {

        return react(query: { state -> Bool? in

            if let query = state.query {

                switch query {
                case .successSaveEnvironments:
                    return true
                default:
                    return nil
                }

            } else {
                return nil
            }

        }, effects: { [weak self] address -> Signal<Types.Event> in
            self?.moduleOutput?.networkSettingSavedSetting()
            return Signal.just(.completedQuery)
        })
    }


    private func environmentsQuery() -> Feedback {

        return react(query: { state -> String? in

            if state.displayState.isAppeared == true {
                return state.wallet.address
            } else {
                return nil
            }

        }, effects: { [weak self] address -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            let environment = strongSelf
                .environmentRepository
                .accountEnvironment(accountAddress: address)

            let accountSettings = strongSelf.accountSettingsRepository
                .accountSettings(accountAddress: address)
                .sweetDebug("accountSettings")

            return Observable.zip(environment, accountSettings)
                .map { Types.Event.setEnvironmets($0.0, $0.1) }
                .asSignal(onErrorRecover: { error in
                    return Signal.just(Types.Event.handlerError(error))
                })
        })
    }

    private func deffaultEnvironmentQuery() -> Feedback {

        return react(query: { state -> String? in

            if let query = state.query, case .resetEnvironmentOnDeffault = query {
                return state.wallet.address
            } else {
                return nil
            }

        }, effects: { [weak self] address -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            let environment = strongSelf
                .environmentRepository
                .deffaultEnvironment(accountAddress: address)

            return environment
                .map { Types.Event.setDeffaultEnvironmet($0) }
                .asSignal(onErrorRecover: { error in
                    return Signal.just(Types.Event.handlerError(error))
                })
        })
    }

    private struct SaveQuery: Equatable {
        let accountAddress: String
        let url: String
        let accountSettings: DomainLayer.DTO.AccountSettings
    }

    private func saveEnvironmentQuery() -> Feedback {

        return react(query: { state -> SaveQuery? in

            if let query = state.query, case .saveEnvironments = query {

                let isEnabledSpam = state.displayState.isSpam
                let spamUrl = state.displayState.spamUrl ?? ""

                var newAccountSettings = state.accountSettings ?? DomainLayer.DTO.AccountSettings(isEnabledSpam: false)
                newAccountSettings.isEnabledSpam = isEnabledSpam

                return SaveQuery(accountAddress: state.wallet.address,
                                 url: spamUrl,
                                 accountSettings: newAccountSettings)
            } else {
                return nil
            }

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            let environment = strongSelf
                .environmentRepository
                .setSpamURL(query.url, by: query.accountAddress)

            let accountSettings = query.accountSettings

            let saveAccountSettings = strongSelf
                .accountSettingsRepository
                .saveAccountSettings(accountAddress: query.accountAddress,
                                     settings: accountSettings)

            return Observable.zip(environment, saveAccountSettings)
                .map { _ in Types.Event.successSave }
                .asSignal(onErrorRecover: { error in
                    return Signal.just(Types.Event.handlerError(error))
                })
        })
    }
}

// MARK: Core State

private extension NetworkSettingsPresenter {

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {

        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    static func reduce(state: inout Types.State, event: Types.Event) {
        switch event {
        case .readyView:
            state.displayState.isAppeared = true

        case .setEnvironmets(let environment, let accountSettings):
            state.environment = environment
            state.accountSettings = accountSettings
            state.displayState.spamUrl = environment.servers.spamUrl.absoluteString
            state.displayState.isSpam = accountSettings?.isEnabledSpam ?? false
            state.displayState.isEnabledSaveButton = true
            state.displayState.isEnabledSetDeffaultButton = true
            state.displayState.isEnabledSpamSwitch = true
            state.displayState.isEnabledSpamInput = true

        case .setDeffaultEnvironmet(let environment):
            state.environment = environment
            state.displayState.spamUrl = environment.servers.spamUrl.absoluteString
            state.displayState.isSpam = true
            state.displayState.isLoading = false
            state.displayState.isEnabledSaveButton = true
            state.displayState.isEnabledSetDeffaultButton = true
            state.query = nil

        case .handlerError:
            state.query = nil
            state.displayState.isLoading = false
            state.displayState.isEnabledSaveButton = true
            state.displayState.isEnabledSetDeffaultButton = true
            state.displayState.isEnabledSpamSwitch = true
            state.displayState.isEnabledSpamInput = true

        case .inputSpam(let url):

            state.displayState.spamUrl = url

            if url?.isValidUrl == false {
                state.displayState.spamError = "Error"
                state.displayState.isEnabledSaveButton = false
            } else {
                state.displayState.isEnabledSaveButton = true
                state.displayState.spamError = nil
            }

        case .switchSpam(let isOn):
            state.displayState.isSpam = isOn

        case .successSave:
            state.query = .successSaveEnvironments
            state.displayState.isLoading = false
            state.displayState.isEnabledSaveButton = true
            state.displayState.isEnabledSetDeffaultButton = true
            state.displayState.isEnabledSpamSwitch = true
            state.displayState.isEnabledSpamInput = true

        case .tapSetDeffault:
            state.query = .resetEnvironmentOnDeffault
            state.displayState.isLoading = true
            state.displayState.isEnabledSaveButton = false
            state.displayState.isEnabledSetDeffaultButton = false

        case .tapSave:
            state.query = .saveEnvironments
            state.displayState.isLoading = true
            state.displayState.isEnabledSaveButton = false
            state.displayState.isEnabledSetDeffaultButton = false
            state.displayState.isEnabledSpamSwitch = false
            state.displayState.isEnabledSpamInput = false

        case .completedQuery:
            state.query = nil
        }
    }
}

// MARK: UI State
private extension NetworkSettingsPresenter {

    func initialState(wallet: DomainLayer.DTO.Wallet) -> Types.State {
        return Types.State(wallet: wallet,
                           accountSettings: nil,
                           environment: nil,
                           displayState: initialDisplayState(),
                           query: nil,
                           isValidSpam: false)
    }

    func initialDisplayState() -> Types.DisplayState {
        return Types.DisplayState(spamUrl: "",
                                  isSpam: false,
                                  isAppeared: false,
                                  isLoading: false,
                                  isEnabledSaveButton: false,
                                  isEnabledSetDeffaultButton: false,
                                  isEnabledSpamSwitch: false,
                                  isEnabledSpamInput: false,
                                  spamError: nil)
    }
}
