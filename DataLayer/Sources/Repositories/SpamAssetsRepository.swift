//
//  SpamAssetsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 25.06.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import Moya
import RxSwift

final class SpamAssetsRepository: SpamAssetsRepositoryProtocol {
    
    private let spamService: SpamAssetsService = SpamAssetsService()
        
    private let environmentRepository: EnvironmentRepositoryProtocol
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol) {
        
        self.environmentRepository = environmentRepository
        self.accountSettingsRepository = accountSettingsRepository
    }
    
    func spamAssets(accountAddress: String) -> Observable<[SpamAssetId]> {
        
        return accountSettingsRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (accountEnviroment) -> Observable<[SpamAssetId]> in
                
                guard let self = self else { return Observable.never() }
                
                if let accountEnviroment = accountEnviroment,
                    let spamPath = accountEnviroment.spamUrl,
                    let spamUrl = URL(string: spamPath) {
                    return self.downloadSpamAssets(by: spamUrl)
                } else {
                    return self.downloadDeffaultSpamAssets()
                }
            })
    }
    
    private func downloadDeffaultSpamAssets() -> Observable<[SpamAssetId]> {
        
        return environmentRepository.walletEnvironment()
            .flatMap({ [weak self] (environment) -> Observable<[String]> in
                
                guard let self = self else { return Observable.empty() }
                
                return self
                    .spamService
                    .spamAssets(by: environment.servers.spamUrl)
            })
    }

    private func downloadSpamAssets(by url: URL) -> Observable<[SpamAssetId]> {
        
        return environmentRepository.walletEnvironment()
            .flatMap({ [weak self] (environment) -> Observable<[String]> in
                guard let self = self else { return Observable.empty() }
                return self
                    .spamService
                    .spamAssets(by: url)
            })
    }
}
