//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DataLayer
import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions

final class WalletInteractor: WalletInteractorProtocol {
    private let authorizationInteractor: AuthorizationUseCaseProtocol
    private let accountBalanceInteractor: AccountBalanceUseCaseProtocol
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol
    private let applicationVersionUseCase: ApplicationVersionUseCaseProtocol

    private let disposeBag = DisposeBag()

    init(authorizationInteractor: AuthorizationUseCaseProtocol,
         accountBalanceInteractor: AccountBalanceUseCaseProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol,
         applicationVersionUseCase: ApplicationVersionUseCaseProtocol) {
        self.authorizationInteractor = authorizationInteractor
        self.accountBalanceInteractor = accountBalanceInteractor
        self.accountSettingsRepository = accountSettingsRepository
        self.applicationVersionUseCase = applicationVersionUseCase
    }

    func isHasAppUpdate() -> Observable<Bool> { applicationVersionUseCase.isHasNewVersion() }

    func assets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.never() }

                let assets = self.accountBalanceInteractor.balances(by: wallet)
                let settings = self.accountSettingsRepository.accountSettings(accountAddress: wallet.address)

                return Observable.zip(assets, settings)
                    .map { assets, settings -> [DomainLayer.DTO.SmartAssetBalance] in

                        if let settings = settings, settings.isEnabledSpam {
                            return assets.filter { $0.asset.isSpam == false }
                        }

                        return assets
                    }
            }
    }
}
