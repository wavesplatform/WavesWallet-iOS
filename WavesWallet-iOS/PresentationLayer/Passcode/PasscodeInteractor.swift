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
    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: [Int]) -> Observable<Bool>
}

final class PasscodeInteractor: PasscodeInteractorProtocol {

    func registrationAccount(_ account: PasscodeTypes.DTO.Account, passcode: [Int]) -> Observable<Bool> {
        return Observable.just(true)
    }
}
