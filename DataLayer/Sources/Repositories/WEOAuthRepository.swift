//
//  WEOAuthRepository.swift
//  DataLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDKCrypto
import WavesSDKExtensions
import DomainLayer

private enum Constants {
    static let sessionLifeTime: Int64 = 12000000
    static let grantType: String = "password"
    static let scope: String = "client"
}

private struct Token: Codable {
    let access_token: String
}

//TODO: Split Usecase and services
final class WEOAuthRepository: WEOAuthRepositoryProtocol {
    
    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol
    
    private let weOAuth: MoyaProvider<WEOAuth.Service> = .anyMoyaProvider()
    
    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols,
         developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol) {
        self.environmentRepository = environmentRepository
        self.developmentConfigsRepository = developmentConfigsRepository
    }
    
    func oauthToken(signedWallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.WEOAuth.Token> {
                
        return Observable.zip(environmentRepository.servicesEnvironment(),
                              developmentConfigsRepository.developmentConfigs())
            .flatMap({ [weak self] (servicesEnvironment, developmentConfigs) ->  Observable<DomainLayer.DTO.WEOAuth.Token> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.authUrl
                let exchangeClientSecret = developmentConfigs.exchangeClientSecret
                
                let token: WEOAuth.Query.Token = self.createOAuthToken(signedWallet: signedWallet,
                                                                       exchangeClientSecret: exchangeClientSecret)
                
                return self
                    .weOAuth
                    .rx
                    .request(.token(baseURL: url,
                                    token: token),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(Token.self)
                    .map { DomainLayer.DTO.WEOAuth.Token(accessToken: $0.access_token) }
                    .asObservable()
            })
    }
    
    private func createOAuthToken(signedWallet: DomainLayer.DTO.SignedWallet,
                                  exchangeClientSecret: String) -> WEOAuth.Query.Token {
        
        let time = Date().millisecondsSince1970 + Constants.sessionLifeTime
        var bytes: Bytes = .init()
        bytes += signedWallet.publicKey.publicKey
        bytes += toByteArray(time)
        
        let signatureBytes = (try? signedWallet.sign(input: bytes, kind: [.none])) ?? []
        let signature = WavesCrypto.shared.base58encode(input: signatureBytes) ?? ""
        
        let passsword = "\(time):" + signature
        
        return .init(token: exchangeClientSecret,
                     username: signedWallet.publicKey.getPublicKeyStr(),
                     password: passsword,
                     grantType: Constants.grantType,
                     scope: Constants.scope)
                
    }
}
