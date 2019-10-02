//
//  MyAccountsSystem.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/1/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import RxSwift
import RxFeedback
import RxCocoa
import DomainLayer

final class MyAccountsSystem: System<MyAccountsTypes.State, MyAccountsTypes.Event> {
    
    private let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    
    override func initialState() -> MyAccountsTypes.State! {
        return MyAccountsTypes.State(action: .loadWallets, wallets: [], sections: [])
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return [wallets]
    }
    
    override func reduce(event: MyAccountsTypes.Event, state: inout MyAccountsTypes.State) {
        
        switch event {
        case .setWallets(let wallets):
            
            //TODO: Logic for lock / unlock wallet
            
            state.wallets = wallets.map { MyAccountsTypes.DTO.UIWallet(wallet: $0, isLock: true) }
            
            let selectedWallet = state.wallets.filter {$0.wallet.isLoggedIn}.map {$0.wallet}
            let unlockWallets = state.wallets.filter {$0.isLock == false && $0.wallet.isLoggedIn == false}.map {$0.wallet}
            let lockWallets = state.wallets.filter {$0.isLock }.map {$0.wallet}
            
            var sections: [MyAccountsTypes.ViewModel.Section] = []

            sections.append(.init(kind: .unlocked, rows: selectedWallet.map {.selected($0)} + unlockWallets.map {.unlock($0)}))
            
            if lockWallets.count > 0 {
                sections.append(.init(kind: .locked, rows: lockWallets.map {.lock($0)}))
            }
            
            state.sections = sections
            state.action = .update
            
        case .unlockWallet(let wallet):
            
            print("TODO")
            
        case .editWallet(let wallet):
            print("TODO")
            
        case .deleteWallet(let wallet):
            print("TODO")
            
        case .activateWallet(let wallet):
            print("TODO")
        }
    }
}

private extension MyAccountsSystem {
    
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
                .map{ MyAccountsTypes.Event.setWallets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
}
