//
//  AccountsInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol AccountsInteractorProtocol {

    func accounts(by ids: [String]) -> AsyncObservable<[DomainLayer.DTO.Account]>
}

final class AccountsInteractorMock: AccountsInteractorProtocol {

    func accounts(by ids: [String]) -> AsyncObservable<[DomainLayer.DTO.Account]> {

        return Observable.just(ids.map { DomainLayer.DTO.Account(id: $0, contact: nil) })
    }
}
