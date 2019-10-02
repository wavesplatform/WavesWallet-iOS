//
//  MigrateAccountsSystem.swift
//  WavesWallet-iOS
//
//  Created by Лера on 9/30/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import RxSwift
import RxFeedback
import RxCocoa
import DomainLayer

final class MigrateAccountsSystem: System<MigrateAccountsTypes.State, MigrateAccountsTypes.Event> {
    
    private let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization

    override func initialState() -> MigrateAccountsTypes.State! {
        return MigrateAccountsTypes.State(action: .loadWallets, wallets: [], sections: [])
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return [wallets]
    }
    
    override func reduce(event: MigrateAccountsTypes.Event, state: inout MigrateAccountsTypes.State) {
        
        switch event {
        case .setWallets(let wallets):
            
            //TODO: Logic for lock / unlock wallet
            state.wallets = wallets.map { MigrateAccountsTypes.DTO.UIWallet(wallet: $0, isLock: true) }

            let unlockWallets = state.wallets.filter {$0.isLock == false}.map {$0.wallet}
            let lockWallets = state.wallets.filter {$0.isLock }.map {$0.wallet}

            var sections: [MigrateAccountsTypes.ViewModel.Section] = []
            sections.append(.init(kind: .title, rows: [.title]))
            sections.append(.init(kind: .unlocked, rows: unlockWallets.map {.unlock($0)}))
            sections.append(.init(kind: .locked, rows: lockWallets.map {.lock($0)}))

            state.sections = sections
            state.action = .update
            
        case .unlockWallet(let wallet):
            
            //TODO: Logic
            state.action = .none
        }
    }
}

private extension MigrateAccountsSystem {
    
    var wallets: Feedback {
        return react(request: { (state) -> Bool? in
            if case .loadWallets = state.action {
                return true
            }
            
            return nil
        }, effects: { [weak self] _ -> Signal<Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self.authorizationInteractor
                    .wallets()
                    .map{ MigrateAccountsTypes.Event.setWallets($0) }
                    .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
}
