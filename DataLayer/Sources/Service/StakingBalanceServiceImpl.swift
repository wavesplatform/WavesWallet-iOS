//
//  StakingBalanceService.swift
//  DataLayer
//
//  Created by vvisotskiy on 24.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK

// TODO: Dont use the authorizationUseCase. The Class use for DomainLayer or PresentationLayer
public final class StakingBalanceServiceImpl: StakingBalanceService {
    private let authorizationService: AuthorizationUseCaseProtocol
    private let devConfig: DevelopmentConfigsRepositoryProtocol
    private let accountBalanceService: AccountBalanceUseCaseProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentRepository
    private let wavesSDKServices: WavesSDKServices

    init(authorizationService: AuthorizationUseCaseProtocol,
         devConfig: DevelopmentConfigsRepositoryProtocol,
         accountBalanceService: AccountBalanceUseCaseProtocol,
         serverEnvironmentUseCase: ServerEnvironmentRepository,
         wavesSDKServices: WavesSDKServices) {
        self.authorizationService = authorizationService
        self.devConfig = devConfig
        self.accountBalanceService = accountBalanceService
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
        self.wavesSDKServices = wavesSDKServices
    }

    public func getAvailableStakingBalance() -> Observable<AvailableStakingBalance> {
        Observable
            .zip(authorizationService.authorizedWallet(), devConfig.developmentConfigs())
            .flatMap { [weak self] signedWallet, devConfig -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                guard let strongSelf = self else { return Observable.never() }
                let assetId = devConfig.staking.first?.neutrinoAssetId ?? ""

                return strongSelf.accountBalanceService.balance(by: assetId, wallet: signedWallet)
            }
            .map { smartBalance -> AvailableStakingBalance in
                AvailableStakingBalance(balance: smartBalance.availableBalance,
                                        assetTicker: smartBalance.asset.ticker,
                                        precision: smartBalance.asset.precision,
                                        logoUrl: smartBalance.asset.iconLogoUrl,
                                        assetLogo: smartBalance.asset.iconLogo)
            }
    }

    public func totalStakingBalance() -> Observable<TotalStakingBalance> {
        Observable
            .zip(getAvailableStakingBalance(), getDepositeStakingBalance())
            .map { availableBalance, depositeBalance -> TotalStakingBalance in
                TotalStakingBalance(availbleBalance: availableBalance.balance,
                                    depositeBalance: depositeBalance.value,
                                    assetTicker: availableBalance.assetTicker,
                                    precision: availableBalance.precision,
                                    logoUrl: availableBalance.logoUrl,
                                    assetLogo: availableBalance.assetLogo)
            }
    }

    public func getDepositeStakingBalance() -> Observable<NodeService.DTO.AddressesData> {
        Observable
            .zip(authorizationService.authorizedWallet(),
                 serverEnvironmentUseCase.serverEnvironment(),
                 devConfig.developmentConfigs())
            .flatMap { [weak self] signedWallet, serverEnviroment, devConfig -> Observable<NodeService.DTO.AddressesData> in
                guard let self = self else { return Observable.never() }
                let walletAddress = signedWallet.wallet.address
                let addressSmartContract = devConfig.staking.first?.addressStakingContract ?? ""
                let neutrinoAssetId = devConfig.staking.first?.neutrinoAssetId ?? ""
                let key = self.buildStakingDepositeBalanceKey(neutrinoAssetId: neutrinoAssetId, walletAddress: walletAddress)

                return self
                    .wavesSDKServices
                    .wavesServices(environment: serverEnviroment)
                    .nodeServices
                    .addressesNodeService
                    .getAddressData(addressSmartContract: addressSmartContract, key: key)
            }
            .catchErrorJustReturn(NodeService.DTO.AddressesData(type: "", value: 0, key: ""))
    }
}

extension StakingBalanceServiceImpl {
    private func buildStakingDepositeBalanceKey(neutrinoAssetId: String, walletAddress: String) -> String {
        "rpd_balance_\(neutrinoAssetId)_\(walletAddress)"
    }
}
