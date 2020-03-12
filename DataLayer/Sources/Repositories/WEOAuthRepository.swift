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
    static let sessionLifeTime: Int64 = 1200000
}

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
                    .map([String: String].self)
                    .asObservable()
                    .map { (_) -> DomainLayer.DTO.WEOAuth.Token in
                        return DomainLayer.DTO.WEOAuth.Token.init(accessToken: "a")
                    }
                
            })
                         
        return Observable.never()
    }
    
    private func createOAuthToken(signedWallet: DomainLayer.DTO.SignedWallet,
                                  exchangeClientSecret: String) -> WEOAuth.Query.Token {
        
        let time = Date().millisecondsSince1970 + Constants.sessionLifeTime
        var bytes: Bytes = .init()
        bytes += signedWallet.publicKey.publicKey
        bytes += toByteArray(time)
        
        let signatureBytes = (try? signedWallet.sign(input: bytes, kind: [.none])) ?? []
        let signature = WavesCrypto.shared.base58encode(input: signatureBytes) ?? ""
        
        let passsword = "$time:" + signature
        
        return .init(token: exchangeClientSecret,
                     username: signedWallet.publicKey.getPublicKeyStr(),
                     password: passsword,
                     grantType: "password",
                     scope: "client")
        
        //        SESSION_LIFE_TIME
        //        val time = currentTimeMillis + SESSION_LIFE_TIME // время жизни токена

        //        val bytes = Bytes.concat(
        //                        WavesCrypto.base58decode(getPublicKeyStr()),
        //                        Longs.toByteArray(time))
        //        val privateKeyBytes = WavesCrypto.base58encode(
        //                        App.accessManager.getWallet()?.privateKey
        //                                ?: byteArrayOf())
        //        val password = "$time:" +
        //                        WavesCrypto.base58encode(
        //                                WavesCrypto.signBytesWithPrivateKey(bytes, privateKeyBytes))
                
    }
}

//@FormUrlEncoded
//@POST("oauth/token")
//fun oauthToken(@Header("Authorization") token: String, // как сделать смотри выше
//                   @Field("username") username: String = WavesWallet.getPublicKeyStr(), // ключ пользователя
//                   @Field("password") password: String, // как сделать смотри выше
//                   @Field("grant_type") grantType: String = "password", // константа
//                   @Field("scope") scope: String = "client") // константа
//                   : Observable<AuthDataResponse>

//data class AuthDataResponse(
//    @SerializedName("access_token")
//    var accessToken: String = "", // нужен только токен
//    @SerializedName("token_type")
//    var tokenType: String  = "bearer",
//    @SerializedName("expires_in")
//    var expiresIn: Long = 0L,
//    @SerializedName("scope")
//    var scope: String  = "client",
//    @SerializedName("cred_message")
//    var credMessage: String  = "",
//    @SerializedName("pub_key")
//    var pubKey: String  = "",
//    @SerializedName("requested_expiration")
//    var requestedExpiration: Long = 0L,
//    @SerializedName("signature")
//    var signature: String  = "",
//    @SerializedName("jti")
//    var jti: String  = ""
//)
