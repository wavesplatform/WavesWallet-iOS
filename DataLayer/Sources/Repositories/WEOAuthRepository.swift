//
//  WEOAuthRepository.swift
//  DataLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions

private enum Constants {
    static let sessionLifeTime: Int64 = 12_000_000
    static let grantType: String = "password"
    static let scope: String = "client"
}

private struct Token: Codable {
    let access_token: String
}

// TODO: Split Usecase and services
final class WEOAuthRepository: WEOAuthRepositoryProtocol {
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol

    private let weOAuth: MoyaProvider<WEOAuth.Service> = .anyMoyaProvider()

    init(developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol) {
        self.developmentConfigsRepository = developmentConfigsRepository
    }

    func oauthToken(serverEnvironment: ServerEnvironment,
                    signedWallet: DomainLayer.DTO.SignedWallet) -> Observable<DomainLayer.DTO.WEOAuth.Token> {
        return developmentConfigsRepository.developmentConfigs()
            .flatMap { [weak self] developmentConfigs -> Observable<DomainLayer.DTO.WEOAuth.Token> in
                guard let self = self else { return Observable.empty() }

                let url = serverEnvironment.servers.wavesExchangeApiUrl!
                let exchangeClientSecret = developmentConfigs.exchangeClientSecret

                let token: WEOAuth.Query.Token = self.createOAuthToken(signedWallet: signedWallet,
                                                                       chainId: serverEnvironment.kind.chainId,
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
                    .catchError { error -> Observable<DomainLayer.DTO.WEOAuth.Token> in
                        Observable.error(NetworkError.error(by: error))
                    }
                    .debug("Tee", trimOutput: false)
            }
    }

    private func createOAuthToken(signedWallet: DomainLayer.DTO.SignedWallet,
                                  chainId: String,
                                  exchangeClientSecret _: String) -> WEOAuth.Query.Token {
        let time = round(Date().timeIntervalSinceNow + (60 * 60 * 24 * 7)) // Token for a week
        let timeString = "\(chainId):waves.exchange:\(time)"

        // Read Protocol for oauth
        // https://docs.waves.exchange/en/api/auth/oauth2-token#response-parameters
        var bytes: Bytes = .init()
        bytes += toByteArray(255)
        bytes += toByteArray(255)
        bytes += toByteArray(255)
        bytes += toByteArray(1)
        bytes += timeString.utf8

//        bytes += signedWallet.publicKey.publicKey
//        bytes += toByteArray(time)

        let signatureBytes = (try? signedWallet.sign(input: bytes, kind: [.none])) ?? []
        let signature = WavesCrypto.shared.base58encode(input: signatureBytes) ?? ""

        let passsword = "\(time):" + signature

        return .init(username: signedWallet.publicKey.getPublicKeyStr(),
                     password: passsword,
                     grantType: Constants.grantType,
                     scope: Constants.scope)
    }
}

// val time = (System.currentTimeMillis() + SESSION_LIFE_TIME_WEEK) / 1000
// val timeString = "${netCode}:waves.exchange:${time}"
// val prefix = byteArrayOf(255.toByte(), 255.toByte(), 255.toByte(), 1.toByte())
// val timeBytes = Bytes.concat(prefix, timeString.toByteArray(Charsets.UTF_8))
// val signatureBytes = WavesCrypto.signBytesWithSeed(timeBytes, seed)
// return "${time}:${WavesCrypto.base58encode(signatureBytes)}"
