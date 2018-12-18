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

protocol ProfileModuleOutput: AnyObject {

    func showAddressesKeys(wallet: DomainLayer.DTO.Wallet)
    func showAddressBook()
    func showLanguage()
    func showBackupPhrase(wallet: DomainLayer.DTO.Wallet, saveBackedUp: @escaping ((_ isBackedUp: Bool) -> Void))
    func showChangePassword(wallet: DomainLayer.DTO.Wallet)
    func showChangePasscode(wallet: DomainLayer.DTO.Wallet)
    func showNetwork(wallet: DomainLayer.DTO.Wallet)
    func showRateApp()
    func showFeedback()
    func showSupport()
    func accountSetEnabledBiometric(isOn: Bool, wallet: DomainLayer.DTO.Wallet)
    func accountLogouted()
    func accountDeleted()
    func showAlertForEnabledBiometric()
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
             .setEnabledBiometric,
             .showAlertForEnabledBiometric:

            return query
        default:
            break
        }

        return nil
    }

    fileprivate static func handlerQuery(owner: ProfilePresenter, query: Types.Query) {

        switch query {
        case .showAddressesKeys(let wallet):
            owner.moduleOutput?.showAddressesKeys(wallet: wallet)

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

        case .showNetwork(let wallet):
            owner.moduleOutput?.showNetwork(wallet: wallet)

        case .showRateApp:
            owner.moduleOutput?.showRateApp()

        case .showAlertForEnabledBiometric:
            owner.moduleOutput?.showAlertForEnabledBiometric()

        case .showFeedback:
            owner.moduleOutput?.showFeedback()

        case .showSupport:
            owner.moduleOutput?.showSupport()

        case .setEnabledBiometric(let isOn, let wallet):
            owner.moduleOutput?.accountSetEnabledBiometric(isOn: isOn, wallet: wallet)

        default:
            break
        }
    }

    func reactQuries() -> Feedback {

        return react(query: { state -> Types.Query? in
            return ProfilePresenter.needQuery(state)
        }, effects: { [weak self] query -> Signal<Types.Event> in
            guard let owner = self else { return Signal.empty() }
            ProfilePresenter.handlerQuery(owner: owner, query: query)
            return Signal.just(.completedQuery)
        })
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

        return react(query: { state -> String? in

            if state.displayState.isAppeared == true, state.wallet != nil {
                return state.wallet?.address
            } else {
                return nil
            }

        }, effects: { [weak self] address -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .blockRepository
                .height(accountAddress: address)
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
                        .accountLogouted()
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
                    self?.moduleOutput?.accountDeleted()
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


            var securityRows: [Types.ViewModel.Row] = [.backupPhrase(isBackedUp: wallet.isBackedUp),
                                                       .changePassword,
                                                       .changePasscode]

            if BiometricType.enabledBiometric != .none {
                securityRows.append(.biometric(isOn: wallet.hasBiometricEntrance))
            } else {
                securityRows.append(.biometricDisabled)
            }

            securityRows.append(.network)

            let security = Types.ViewModel.Section(rows: securityRows, kind: .security)

            let other = Types.ViewModel.Section(rows: [.rateApp,
                                                       .feedback,
                                                       .supportWavesplatform,
                                                       .info(version: Bundle.main.version, height: nil, isBackedUp: wallet.isBackedUp)], kind: .other)

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
                state.query = .showAddressesKeys(wallet: wallet)

            case .language:
                state.query = .showLanguage

            case .backupPhrase:
                state.query = .showBackupPhrase(wallet: wallet)

            case .changePassword:
                state.query = .showChangePassword(wallet: wallet)

            case .changePasscode:
                state.query = .showChangePasscode(wallet: wallet)

            case .network:
                state.query = .showNetwork(wallet: wallet)

            case .rateApp:
                state.query = .showRateApp

            case .feedback:
                state.query = .showFeedback

            case .supportWavesplatform:
                state.query = .showSupport

            case .biometricDisabled:
                state.query = .showAlertForEnabledBiometric
                
            default:
                break
            }

        case .setBlock(let block):
            state.block = block
            updateInfo(state: &state, block: block, isBackedUp: state.wallet?.isBackedUp ?? false)
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

        case .completedQuery:
            state.query = nil

        default:
            break
        }
    }

    static func updateInfo(state: inout Types.State, block: Int64, isBackedUp: Bool) {

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
            .rows[index.offset] = .info(version: Bundle.main.version,
                                        height: "\(block)",
                isBackedUp: isBackedUp)
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
