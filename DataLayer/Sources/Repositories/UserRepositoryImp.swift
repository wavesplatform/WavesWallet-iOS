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
    private let moyaProvider: MoyaProvider<UserTarget> = .anyMoyaProvider()

    private let serverEnvironmentRepository: ServerEnvironmentRepository
    private let weOAuthRepository: WEOAuthRepositoryProtocol

    init(serverEnvironmentRepository: ServerEnvironmentRepository, weOAuthRepository: WEOAuthRepositoryProtocol) {
        self.serverEnvironmentRepository = serverEnvironmentRepository
        self.weOAuthRepository = weOAuthRepository
    }

    func createNewUserId(wallet: SignedWallet) -> Observable<String> {
        if let uid = UID.get() {
            return Observable.just(uid)
        }

        let oauthToken = weOAuthRepository.oauthToken(signedWallet: wallet)
        let serverEnvironment = serverEnvironmentRepository.serverEnvironment()

        return Observable.zip(serverEnvironment, oauthToken)
            .flatMap { [weak self] serverEnvironment, oauthToken -> Observable<String> in

                guard let self = self else { return .never() }

                let wavesExchangeInternalApiUrl = serverEnvironment.servers.wavesExchangeInternalApiUrl

                let targetKind = UserTarget.Kind.createNewUser(token: oauthToken.accessToken)
                let target = UserTarget(kind: targetKind, baseURL: wavesExchangeInternalApiUrl)

                return self.moyaProvider
                    .rx
                    .request(target)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .mapString(atKeyPath: "uid")
                    .asObservable()
                    .catchError { error -> Observable<String> in Observable.error(NetworkError.error(by: error)) }
            }
    }

    func associateUserIdWithUser(wallet: SignedWallet, uid: String) -> Observable<String> {
        let oauthToken = weOAuthRepository.oauthToken(signedWallet: wallet)
        let serverEnvironment = serverEnvironmentRepository.serverEnvironment()

        return Observable.zip(serverEnvironment, oauthToken)
            .flatMap { [weak self] serverEnvironment, oauthToken -> Observable<String> in

                guard let self = self else { return .never() }

                let wavesExchangeInternalApiUrl = serverEnvironment.servers.wavesExchangeInternalApiUrl

                let targetKind = UserTarget.Kind.associateIdWithUser(token: oauthToken.accessToken, userId: uid)
                let target = UserTarget(kind: targetKind, baseURL: wavesExchangeInternalApiUrl)

                return self.moyaProvider
                    .rx
                    .request(target)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .mapString(atKeyPath: "uid")
                    .asObservable()
                    .catchError { error -> Observable<String> in Observable.error(NetworkError.error(by: error)) }
            }
    }

    func checkReferralAddress(wallet: SignedWallet) -> Observable<String?> {
        let oauthToken = weOAuthRepository.oauthToken(signedWallet: wallet)
        let serverEnvironment = serverEnvironmentRepository.serverEnvironment()

        return Observable.zip(oauthToken, serverEnvironment)
            .flatMap { [weak self] oauthToken, serverEnvironment -> Observable<String?> in
                guard let self = self else { return .never() }
                let wavesExchangeInternalApiUrl = serverEnvironment.servers.wavesExchangeInternalApiUrl

                let targetKind = UserTarget.Kind.checkReferralAddress(token: oauthToken.accessToken)
                let target = UserTarget(kind: targetKind, baseURL: wavesExchangeInternalApiUrl)

                return self.moyaProvider
                    .rx
                    .request(target)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(String?.self, atKeyPath: "referred_by", using: JSONDecoder(), failsOnEmptyData: false)
                    .asObservable()
                    .catchError { error in
                        // The given data was not valid JSON.
                        // когда моя пытается распарсить пустой ответ - она не может, и говорит нам что ошибка, но на самом деле пришла просто 204 потому что нет реффера
                        if let error = error as? MoyaError, error.response?.statusCode == 204 {
                            return Observable.just(nil)
                        } else {
                            return Observable.error(NetworkError.error(by: error))
                        }
                }
            }
    }
}

private struct UserTarget: TargetType {
    enum Kind {
        case createNewUser(token: String)
        case associateIdWithUser(token: String, userId: String)
        case checkReferralAddress(token: String)
    }

    private let kind: Kind

    let baseURL: URL

    var path: String {
        switch kind {
        case .createNewUser, .associateIdWithUser: return "/v1/user/login"
        case .checkReferralAddress: return "/v1/user/referral/referrer"
        }
    }

    var method: Moya.Method {
        switch kind {
        case .createNewUser: return .put
        case .associateIdWithUser: return .post
        case .checkReferralAddress: return .get
        }
    }

    let sampleData: Data = Data()

    var task: Task {
        switch kind {
        case .createNewUser:
            return .requestPlain

        case let .associateIdWithUser(_, userId):
            return .requestParameters(parameters: ["uid": userId], encoding: JSONEncoding.default)

        case .checkReferralAddress: return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = ContentType.applicationJson.headers

        switch kind {
        case let .createNewUser(token):
            headers["Authorization"] = "Bearer \(token)"
        case let .associateIdWithUser(token, _):
            headers["Authorization"] = "Bearer \(token)"
        case let .checkReferralAddress(token):
            headers["Authorization"] = "Bearer \(token)"
        }

        return headers
    }

    init(kind: Kind, baseURL: URL) {
        self.kind = kind
        self.baseURL = baseURL
    }
}
