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
//        newFeedbacks.append(handlerQuery())

        let initialState = self.initialState(wallet: input.wallet)
        let system = Driver.system(initialState: initialState,
                                   reduce: NetworkSettingsPresenter.reduce,
                                   feedback: newFeedbacks)

        system
            .drive()
            .disposed(by: disposeBag)
    }

    func environmentsQuery() -> Feedback {

        return react(query: { state -> String? in

            if state.displayState.isAppeared == true {
                return state.wallet.address
            } else {
                return nil
            }

        }, effects: { [weak self] address -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            let environment = strongSelf.environmentRepository
                .environment(accountAddress: address)

            let accountSettings = strongSelf.accountSettingsRepository
                .accountSettings(accountAddress: address)
                .sweetDebug("accountSettings")

            return Observable.zip(environment, accountSettings)
                .map { Types.Event.setEnvironmets($0.0, $0.1) }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
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
            state.displayState.spamUrl = environment.servers.spamUrl.absoluteString
            state.displayState.isSpam = accountSettings?.isEnabledSpam ?? false

        case .handlerError(let error):
            break

        case .inputSpam(let url):
            break

        case .switchSpam(let isOn):
            break

        case .successSave:
            break

        case .tapSetDeffault:
            break

        case .tapSave:
            break

        case .completedQuery:
            break

        default:
            break
        }
    }
}

// MARK: UI State
private extension NetworkSettingsPresenter {

    func initialState(wallet: DomainLayer.DTO.Wallet) -> Types.State {
        return Types.State(wallet: wallet,
                           accountSetting: nil,
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
                                  spamError: nil)
    }
}
