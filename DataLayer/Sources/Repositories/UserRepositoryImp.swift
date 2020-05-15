//
//  UserRepository.swift
//  DataLayer
//
//  Created by rprokofev on 14.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK
import WavesSDKExtensions

struct UID: TSUD, Codable {
    var UID: String? = nil

    init() {}

    static var defaultValue: String? { nil }

    static var stringKey: String { return "com.waveswallet.repository.user.uid.v1" }
}

final class UserRepositoryImp: UserRepository {
    private let putUserIdProvider: MoyaProvider<PutUserId> = .anyMoyaProvider()
    private let postUserIdProvider: MoyaProvider<PostUserId> = .anyMoyaProvider()

    private let serverEnvironmentRepository: ServerEnvironmentRepository
    private let weOAuthRepository: WEOAuthRepositoryProtocol

    init(serverEnvironmentRepository: ServerEnvironmentRepository, weOAuthRepository: WEOAuthRepositoryProtocol) {
        self.serverEnvironmentRepository = serverEnvironmentRepository
        self.weOAuthRepository = weOAuthRepository
    }

    func userUID(wallet: DomainLayer.DTO.SignedWallet) -> Observable<String> {
        if let uid = UID.get() {
            return Observable.just(uid)
        }

        let oauthToken = weOAuthRepository.oauthToken(signedWallet: wallet)
        let serverEnvironment = serverEnvironmentRepository.serverEnvironment()

        return Observable.zip(serverEnvironment, oauthToken)
            .flatMap { [weak self] serverEnvironment, oauthToken -> Observable<String> in

                guard let self = self else { return Observable.never() }

                let wavesExchangeInternalApiUrl = serverEnvironment.servers.wavesExchangeInternalApiUrl

                let model = PutUserId(baseURL: wavesExchangeInternalApiUrl, token: oauthToken.accessToken)

                return self.putUserIdProvider.rx
                    .request(model)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .mapString(atKeyPath: "uid")
                    .asObservable()
                    .catchError { error -> Observable<String> in
                        Observable.error(NetworkError.error(by: error))
                    }
            }
    }

    func setUserUID(wallet: DomainLayer.DTO.SignedWallet, uid: String) -> Observable<String> {
        let oauthToken = weOAuthRepository.oauthToken(signedWallet: wallet)
        let serverEnvironment = serverEnvironmentRepository.serverEnvironment()

        return Observable.zip(serverEnvironment, oauthToken)
            .flatMap { [weak self] serverEnvironment, oauthToken -> Observable<String> in

                guard let self = self else { return Observable.never() }

                let wavesExchangeInternalApiUrl = serverEnvironment.servers.wavesExchangeInternalApiUrl

                let model = PostUserId(uid: uid, token: oauthToken.accessToken, baseURL: wavesExchangeInternalApiUrl)

                return self.postUserIdProvider.rx
                    .request(model)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .mapString(atKeyPath: "uid")
                    .asObservable()
                    .catchError { error -> Observable<String> in
                        Observable.error(NetworkError.error(by: error))
                    }
            }
    }
}

private struct PutUserId: TargetType {
    var sampleData: Data { Data() }
    var baseURL: URL
    var token: String

    var path: String { "/v1/user/login" }

    var headers: [String: String]? {
        var headers: [String: String] = ContentType.applicationJson.headers
        headers["Authorization"] = "Bearer \(token)"
        return headers
    }

    var method: Moya.Method {
        return .put
    }

    var task: Task {
        return .requestPlain
    }
}

private struct PostUserId: TargetType {
    let uid: String
    let token: String
    var baseURL: URL

    var sampleData: Data { Data() }

    var path: String { "/v1/user/login" }

    var headers: [String: String]? {
        var headers: [String: String] = ContentType.applicationJson.headers
        headers["Authorization"] = "Bearer \(token)"
        return headers
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        return .requestParameters(parameters: ["uid": uid], encoding: JSONEncoding.default)
    }
}
