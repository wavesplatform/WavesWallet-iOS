//
//  AccountEnvironmentRepository.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class AccountSettingsRepository: AccountSettingsRepositoryProtocol {

    func accountSettings(accountAddress: String) -> Observable<DomainLayer.DTO.AccountSettings> {
        return Observable.never()
    }

    func saveAccountSettings(accountAddress: String, environment: DomainLayer.DTO.AccountSettings) -> Observable<DomainLayer.DTO.AccountSettings> {
        return Observable.never()
    }
}
