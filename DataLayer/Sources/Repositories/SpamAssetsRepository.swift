//
//  SpamAssetsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 25.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import Moya
import RxSwift

private enum Constants {
    
    static let urlSpam: URL = URL(string: "https://raw.githubusercontent.com/wavesplatform/waves-community/master/Scam%20tokens%20according%20to%20the%20opinion%20of%20Waves%20Community.csv")!    
    static let urlSpamProxy: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/waves-community/master/Scam%20tokens%20according%20to%20the%20opinion%20of%20Waves%20Community.csv")!
}


final class SpamAssetsRepository: SpamAssetsRepositoryProtocol {
    
    private let spamService: SpamAssetsService = SpamAssetsService()
    
    private let environmentRepository: EnvironmentRepositoryProtocols
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocols,
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
                    .spamAssets(by: Constants.urlSpamProxy)
                    .catchError({ [weak self] _ -> Observable<[String]> in
                        
                        guard let self = self else { return Observable.empty() }
                        
                        return self.spamService.spamAssets(by: Constants.urlSpam)
                    })
                
            })
    }

    private func downloadSpamAssets(by url: URL) -> Observable<[SpamAssetId]> {
        
        return environmentRepository.walletEnvironment()
            .flatMap({ [weak self] (environment) -> Observable<[String]> in
                guard let self = self else { return Observable.empty() }
                return self.spamService.spamAssets(by: url)
            })
    }
}
