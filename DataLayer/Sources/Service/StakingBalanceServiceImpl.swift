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

//TODO: Dont use the authorizationUseCase. The Class use for DomainLayer or PresentationLayer
public final class StakingBalanceServiceImpl: StakingBalanceService {
        
    private let authorizationService: AuthorizationUseCaseProtocol
    private let devConfig: DevelopmentConfigsRepositoryProtocol
    private let enviroment: ExtensionsEnvironmentRepositoryProtocols
    private let accountBalanceService: AccountBalanceUseCaseProtocol
    
    init(authorizationService: AuthorizationUseCaseProtocol,
         devConfig: DevelopmentConfigsRepositoryProtocol,
         enviroment: ExtensionsEnvironmentRepositoryProtocols,
         accountBalanceService: AccountBalanceUseCaseProtocol) {
        self.authorizationService = authorizationService
        self.devConfig = devConfig
        self.enviroment = enviroment
        self.accountBalanceService = accountBalanceService
    }
    
    public func getAvailableStakingBalance() -> Observable<AvailableStakingBalance> {
        Observable
            .zip(authorizationService.authorizedWallet(),
                 devConfig.developmentConfigs())
            .flatMap { [weak self] signedWallet, devConfig -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                guard let strongSelf = self else { return Observable.never() }
                let assetId = devConfig.staking.first?.neutrinoAssetId ?? ""
                
                return strongSelf.accountBalanceService.balance(by: assetId, wallet: signedWallet)
            }
            .map { smartBalance -> AvailableStakingBalance in
                AvailableStakingBalance(balance: smartBalance.totalBalance,
                                        assetTicker: smartBalance.asset.ticker,
                                        precision: smartBalance.asset.precision,
                                        logoUrl: smartBalance.asset.iconLogoUrl,
                                        assetLogo: smartBalance.asset.iconLogo)
            }
    }
    
    public func totalStakingBalance() -> Observable<TotalStakingBalance> {
        
        Observable
            .zip(getAvailableStakingBalance(),
                 getDepositeStakingBalance())
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
                 enviroment.servicesEnvironment(),
                 devConfig.developmentConfigs())
            .flatMap { [weak self] signedWallet, servicesConfig, devConfig -> Observable<NodeService.DTO.AddressesData> in
                guard let sself = self else { return Observable.never() }
                let walletAddress = signedWallet.wallet.address
                let addressSmartContract = devConfig.staking.first?.addressStakingContract ?? ""
                let neutrinoAssetId = devConfig.staking.first?.neutrinoAssetId ?? ""
                let key = sself.buildStakingDepositeBalanceKey(neutrinoAssetId: neutrinoAssetId, walletAddress: walletAddress)
                return servicesConfig
                    .wavesServices
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
