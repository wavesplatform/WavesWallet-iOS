//
//  NewAccountPasscodeInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol PasscodeInteractorProtocol {
    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<Bool>
}

final class PasscodeInteractor: PasscodeInteractorProtocol {

    private let walletsInteractor: WalletsInteractorProtocol = FactoryInteractors.instance.wallets

    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: String) -> Observable<Bool> {

        let query = DomainLayer.DTO.WalletRegistation.init(name: account.name,
                                               address: account.privateKey.address,
                                               privateKey: account.privateKey,
                                               isBackedUp: !account.needBackup,
                                               password: account.password,
                                               passcode: passcode)

        return walletsInteractor.registerWallet(query).map { wallet in
            print(wallet)
            return true
        }
    }
}
