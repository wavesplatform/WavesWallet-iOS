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

//TODO: Rename to service
final class WEOAuthRepository: WEOAuthRepositoryProtocol {
    
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol
    
    private let weOAuth: MoyaProvider<WEOAuth.Service> = .anyMoyaProvider()

    init(developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol) {
        self.developmentConfigsRepository = developmentConfigsRepository
    }

    func oauthToken(serverEnvironment: ServerEnvironment,
                    signedWallet: DomainLayer.DTO.SignedWallet) -> Observable<WEOAuthTokenDTO> {
        return developmentConfigsRepository.developmentConfigs()
            .flatMap { [weak self] developmentConfigs -> Observable<WEOAuthTokenDTO> in
                guard let self = self else { return Observable.empty() }

                let url = serverEnvironment.servers.wavesExchangeApiUrl
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
                    .map { WEOAuthTokenDTO(accessToken: $0.accessToken) }
                    .asObservable()
                    .catchError { error -> Observable<WEOAuthTokenDTO> in
                        Observable.error(NetworkError.error(by: error))
                    }
            }
    }

    private func createOAuthToken(signedWallet: DomainLayer.DTO.SignedWallet,
                                  chainId: String,
                                  exchangeClientSecret: String) -> WEOAuth.Query.Token {

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
