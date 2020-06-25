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

private struct Token: Codable {
    let accessToken: String
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class WEOAuthRepository: WEOAuthRepositoryProtocol {
    private let weOAuth: MoyaProvider<WEOAuthTarget> = .anyMoyaProvider()

    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol
    private let serverEnvironmentRepository: ServerEnvironmentRepository

    init(developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol,
         serverEnvironmentRepository: ServerEnvironmentRepository) {
        self.developmentConfigsRepository = developmentConfigsRepository
        self.serverEnvironmentRepository = serverEnvironmentRepository
    }

    func oauthToken(signedWallet: SignedWallet) -> Observable<WEOAuthTokenDTO> {
        let serverEnvironment = serverEnvironmentRepository.serverEnvironment()
        let developmentConfigs = developmentConfigsRepository.developmentConfigs()

        return Observable.zip(developmentConfigs, serverEnvironment)
            .flatMap { [weak self] developmentConfigs, serverEnvironment -> Observable<WEOAuthTokenDTO> in
                guard let self = self else { return Observable.empty() }

                let url = serverEnvironment.servers.wavesExchangePublicApiUrl
                let exchangeClientSecret = developmentConfigs.exchangeClientSecret

                let token: WEOAuthTokenQuery = self.createOAuthToken(signedWallet: signedWallet,
                                                                     chainId: serverEnvironment.kind.chainId)
                return self
                    .weOAuth
                    .rx
                    .request(.token(baseURL: url,
                                    token: token),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(Token.self)
                    .map { WEOAuthTokenDTO(accessToken: $0.accessToken) }
                    .asObservable()
                    .catchError { error -> Observable<WEOAuthTokenDTO> in
                        Observable.error(NetworkError.error(by: error))
                    }
            }
    }

    private func createOAuthToken(signedWallet: SignedWallet, chainId: String) -> WEOAuthTokenQuery {
        let clientId = "waves.exchange"
        let time = Int64(round(Date().timeIntervalSince1970 + (60 * 60 * 24 * 7))) // Token for a week
        let timeString = "\(chainId):\(clientId):\(time)"

        // Read Protocol for oauth
        // https://docs.waves.exchange/en/api/auth/oauth2-token#response-parameters
        var bytes: Bytes = .init()
        bytes += [UInt8(255)]
        bytes += [UInt8(255)]
        bytes += [UInt8(255)]
        bytes += [UInt8(1)]
        bytes += timeString.utf8

        let signatureBytes = (try? signedWallet.sign(input: bytes, kind: [.none])) ?? []
        let signature = WavesCrypto.shared.base58encode(input: signatureBytes) ?? ""

        let passsword = "\(time):" + signature

        return .init(username: signedWallet.publicKey.getPublicKeyStr(),
                     password: passsword,
                     grantType: "password",
                     scope: "general",
                     clientId: clientId)
    }
}
