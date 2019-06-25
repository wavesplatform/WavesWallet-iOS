//
//  AccountSettingsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public enum AccountSettingsRepositoryError: Error {
    case invalid
}

public protocol AccountSettingsRepositoryProtocol {
    
    func saveAccountEnvironment(_ accountEnvironment: DomainLayer.DTO.AccountEnvironment,
                                accountAddress: String) -> Observable<Bool>
    func accountEnvironment(accountAddress: String) -> Observable<DomainLayer.DTO.AccountEnvironment?>
    
    func accountSettings(accountAddress: String) -> Observable<DomainLayer.DTO.AccountSettings?>
    func saveAccountSettings(accountAddress: String, settings: DomainLayer.DTO.AccountSettings) -> Observable<DomainLayer.DTO.AccountSettings>
    func setSpamURL(_ url: String, by accountAddress: String) -> Observable<Bool>
}
