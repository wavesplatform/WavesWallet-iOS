//
//  ProfilePresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol ProfileModuleInput {

}

protocol ProfileModuleOutput: AnyObject {

    func showAddressesKeys()
    func showAddressBook()
    func showLanguage()
    func showBackupPhrase(wallet: DomainLayer.DTO.Wallet, completed: @escaping ((_ isBackedUp: Bool) -> Void))
    func showChangePassword(wallet: DomainLayer.DTO.Wallet)
    func showChangePasscode(wallet: DomainLayer.DTO.Wallet)
    func showNetwork()
    func showRateApp()
    func showFeedback()
    func showSupport()
    func userSetEnabledBiometric(isOn: Bool, wallet: DomainLayer.DTO.Wallet)
    func userLogouted()
    func useerDeteedAccount()
}

protocol ProfilePresenterProtocol {

    typealias Feedback = (Driver<ProfileTypes.State>) -> Signal<ProfileTypes.Event>

    var moduleOutput: ProfileModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

public func reactQuery<State, Query: Equatable, Event, Owner: AnyObject>(owner: Owner,
                                                       query: @escaping (State) -> Query?,
                                                       effects: @escaping (Owner, Query) -> Void) -> (Driver<State>) -> Signal<Event> {

    return react(query: query, effects: { [weak owner] query -> Signal<Event> in
        guard let ownerStrong = owner else { return Signal.never() }
        effects(ownerStrong, query)
        return Signal.empty()
    })
}

final class ProfilePresenter: ProfilePresenterProtocol {

    fileprivate typealias Types = ProfileTypes

    private let disposeBag: DisposeBag = DisposeBag()

    private let blockRepository: BlockRepositoryProtocol = FactoryRepositories.instance.blockRemote
    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let walletsRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    weak var moduleOutput: ProfileModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(reactQuries())
        newFeedbacks.append(profileQuery())        
        newFeedbacks.append(blockQuery())
        newFeedbacks.append(deleteAccountQuery())
        newFeedbacks.append(logoutAccountQuery())
        newFeedbacks.append(handlerEvent())
        newFeedbacks.append(setBackupQuery())

        let initialState = self.initialState()

        let system = Driver.system(initialState: initialState,
                                   reduce: ProfilePresenter.reduce,
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - Feedbacks
fileprivate extension ProfilePresenter {

    fileprivate static func needQuery(_ state: Types.State) -> Types.Query? {

        guard let query = state.query else { return nil }

        switch query {
        case .showAddressesKeys,
             .showAddressBook,
             .showLanguage,
             .showBackupPhrase,
             .showChangePassword,
             .showChangePasscode,
             .showNetwork,
             .showRateApp,
             .showFeedback,
             .showSupport,
             .setEnabledBiometric:

            return query
        default:
            break
        }

        return nil
    }

    fileprivate static func handlerQuery(owner: ProfilePresenter, query: Types.Query) {

        switch query {
        case .showAddressesKeys:
            owner.moduleOutput?.showAddressesKeys()

        case .showAddressBook:
            owner.moduleOutput?.showAddressBook()

        case .showLanguage:
            owner.moduleOutput?.showLanguage()

        case .showBackupPhrase(let wallet):
            owner.moduleOutput?.showBackupPhrase(wallet: wallet) { [weak owner] isBackedUp in
                owner?.eventInput.onNext(.setBackedUp(isBackedUp))
            }

        case .showChangePassword(let wallet):
            owner.moduleOutput?.showChangePassword(wallet: wallet)

        case .showChangePasscode(let wallet):
            owner.moduleOutput?.showChangePasscode(wallet: wallet)

        case .showNetwork:
            owner.moduleOutput?.showNetwork()

        case .showRateApp:
            owner.moduleOutput?.showRateApp()

        case .showFeedback:
            owner.moduleOutput?.showFeedback()

        case .showSupport:
            owner.moduleOutput?.showSupport()

        case .setEnabledBiometric(let isOn, let wallet):
            owner.moduleOutput?.userSetEnabledBiometric(isOn: isOn, wallet: wallet)

//        case .logoutAccount:
//            owner.moduleOutput?.userTapLogout()
//
//        case .deleteAccount:
//            owner.moduleOutput?.useTapDelete()
        default:
            break
        }
    }

    func reactQuries() -> Feedback {
        return reactQuery(owner: self, query: { state -> Types.Query? in
            return ProfilePresenter.needQuery(state)
        }) { owner, query in
            ProfilePresenter.handlerQuery(owner: owner, query: query)
        }
    }

    func handlerEvent() -> Feedback {
        return react(query: { state -> Bool? in
            return true
        }, effects: { [weak self] isOn -> Signal<Types.Event> in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.eventInput.asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    func setBackupQuery() -> Feedback {

        return react(query: { state -> DomainLayer.DTO.Wallet? in

            guard let query = state.query else { return nil }
            guard let wallet = state.wallet else { return nil }
            if case .setBackedUp(let isBackedUp) = query {
                var newWallet = wallet
                newWallet.isBackedUp = isBackedUp
                return newWallet
            } else {
                return nil
            }

        }, effects: { [weak self] wallet -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            
            return strongSelf
                .authorizationInteractor
                .changeWallet(wallet)
                .map { $0.isBackedUp }
                .map { Types.Event.setBackedUp($0)}
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }

    func profileQuery() -> Feedback {

        return react(query: { state -> Bool? in

            if state.displayState.isAppeared == true {
                return true
            } else {
                return nil
            }

        }, effects: { [weak self] isOn -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .authorizationInteractor
                .authorizedWallet()
                .flatMap({ [weak self] wallet -> Observable<DomainLayer.DTO.Wallet> in
                    guard let strongSelf = self else { return Observable.empty() }
                    return strongSelf.walletsRepository.listenerWallet(by: wallet.wallet.publicKey)
                })
                .map { Types.Event.setWallet($0) }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }


    func blockQuery() -> Feedback {

        return react(query: { state -> Bool? in

            if state.displayState.isAppeared == true {
                return true
            } else {
                return nil
            }

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .blockRepository
                .height()
                .map { Types.Event.setBlock($0) }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }

    func logoutAccountQuery() -> Feedback {

        return react(query: { state -> Bool? in

            guard let query = state.query else { return nil }
            if case .logoutAccount = query {
                return true
            } else {
                return nil
            }

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .authorizationInteractor
                .logout()
                .do(onNext: { [weak self] _ in
                    self?.moduleOutput?
                        .userLogouted()
                })
                .map { _ in
                    return Types.Event.none
                }
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }

    func deleteAccountQuery() -> Feedback {

        return react(query: { state -> Bool? in
            guard let query = state.query else { return nil }
            if case .deleteAccount = query {
                return true
            } else {
                return nil
            }

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .authorizationInteractor.logout()
                .flatMap({ [weak self] wallet -> Observable<Types.Event> in
                    guard let strongSelf = self else { return Observable.empty() }
                    return strongSelf
                        .authorizationInteractor
                        .deleteWallet(wallet)
                        .map { _ in
                            return Types.Event.none
                        }
                })
                .do(onNext: { [weak self] _ in
                    self?.moduleOutput?.useerDeteedAccount()
                })
                .asSignal(onErrorRecover: { _ in
                    return Signal.empty()
                })
        })
    }
}

// MARK: Core State

private extension ProfilePresenter {

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    static func reduce(state: inout Types.State, event: Types.Event) {

        state.displayState.action = nil

        switch event {
        case .viewDidDisappear:
            state.displayState.isAppeared = false
            state.query = nil

        case .viewDidAppear:
            state.displayState.isAppeared = true

        case .setWallet(let wallet):

            let generalSettings = Types.ViewModel.Section(rows: [.addressesKeys,
                                                                 .addressbook,
                                                                 .pushNotifications,
                                                                 .language(Language.currentLanguage)], kind: .general)

            let security = Types.ViewModel.Section(rows: [.backupPhrase(isBackedUp: wallet.isBackedUp),
                                                          .changePassword,
                                                          .changePasscode,
                                                          .biometric(isOn: wallet.hasBiometricEntrance),
                                                          .network], kind: .security)

            let other = Types.ViewModel.Section(rows: [.rateApp,
                                                       .feedback,
                                                       .supportWavesplatform,
                                                       .info(version: Bundle.main.version, height: nil)], kind: .other)

            state.displayState.sections = [generalSettings,
                                           security,
                                           other]
            state.wallet = wallet
            state.displayState.action = .update

        case .tapRow(let row):

            guard let wallet = state.wallet else { return }

            switch row {
            case .addressbook:
                state.query = .showAddressBook

            case .addressesKeys:
                state.query = .showAddressesKeys

            case .language:
                state.query = Types.Query.showLanguage

            case .backupPhrase:
                if wallet.isBackedUp == false {
                    state.query = Types.Query.showBackupPhrase(wallet: wallet)
                }
                
            case .changePassword:
                state.query = Types.Query.showChangePassword(wallet: wallet)

            case .changePasscode:
                state.query = Types.Query.showChangePasscode(wallet: wallet)

            case .network:
                state.query = Types.Query.showNetwork

            case .rateApp:
                state.query = Types.Query.showRateApp

            case .feedback:
                state.query = Types.Query.showFeedback

            case .supportWavesplatform:
                state.query = Types.Query.showSupport
                
            default:
                break
            }

        case .setBlock(let block):
            state.block = block
            guard let section = state
                .displayState
                .sections
                .enumerated()
                .first(where: { $0.element.kind == .other }) else { return }

            guard let index = section
                .element
                .rows
                .enumerated()
                .first(where: { element in
                    if case .info = element.element {
                        return true
                    }
                    return false
                }) else {
                    return
                }

            state
                .displayState
                .sections[section.offset]
                .rows[index.offset] = .info(version: Bundle.main.version, height: "\(block)")
            state
                .displayState.action = .update

        case .setBackedUp(let isBackedUp):

            guard let section = state
                .displayState
                .sections
                .enumerated()
                .first(where: { $0.element.kind == .security }) else { return }

            guard let index = section
                .element
                .rows
                .enumerated()
                .first(where: { element in
                    if case .backupPhrase = element.element {
                        return true
                    }
                    return false
                }) else {
                    return
            }
            state
                .displayState
                .sections[section.offset]
                .rows[index.offset] = .backupPhrase(isBackedUp: isBackedUp)
            state.displayState.action = nil
            state.query = .setBackedUp(isBackedUp)

        case .setEnabledBiometric(let isOn):

            guard let section = state
                .displayState
                .sections
                .enumerated()
                .first(where: { $0.element.kind == .security }) else { return }

            guard let index = section
                .element
                .rows
                .enumerated()
                .first(where: { element in
                    if case .biometric = element.element {
                        return true
                    }
                    return false
                }) else {
                    return
            }

            if let wallet = state.wallet {
                state.query = .setEnabledBiometric(isOn, wallet: wallet)
            }
            state
                .displayState
                .sections[section.offset]
                .rows[index.offset] = .biometric(isOn: isOn)
            state
                .displayState.action = nil

        case .tapLogout:
            state.query = Types.Query.logoutAccount

        case .tapDelete:
            state.query = Types.Query.deleteAccount

        default:
            break
        }
    }
}

// MARK: UI State

private extension ProfilePresenter {

    func initialState() -> Types.State {
        return Types.State(query: nil, wallet: nil, block: nil, displayState: initialDisplayState())
    }

    func initialDisplayState() -> Types.DisplayState {
        return Types.DisplayState(sections: [], isAppeared: false, action: nil)
    }
}
