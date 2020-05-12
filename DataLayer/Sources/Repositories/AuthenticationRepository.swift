//
//  AuthenticationRepositoryRemoter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import Foundation
import Moya
import RxCocoa
import RxSwift
import WavesSDK
import WavesSDKExtensions

private enum Constants {
    #if DEBUG
        static let isDebug: Bool = true
    #elseif TEST
        static let isDebug: Bool = true
    #else
        static let isDebug: Bool = false
    #endif

    static let device = "ios"
    static let url = URL(string: "https://us-central1-waves-exchange.cloudfunctions.net")!
}

final class AuthenticationRepository: AuthenticationRepositoryProtocol {
    private let serverEnvironmentRepository: ServerEnvironmentRepository

    init(serverEnvironmentRepository: ServerEnvironmentRepository) {
        self.serverEnvironmentRepository = serverEnvironmentRepository
    }

    private let firebaseRegisterTarget: MoyaProvider<FirebaseRegisterTarget> = .anyMoyaProvider()
    private let firebaseAuthTarget: MoyaProvider<FirebaseAuthTarget> = .anyMoyaProvider()

    func registration(with id: String, keyForPassword: String, passcode: String) -> Observable<Bool> {
        serverEnvironmentRepository.serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<Bool> in

                guard let self = self else { return Observable.never() }

                let firebaseAuthApiUrl = serverEnvironment.servers.firebaseAuthApiUrl
                let request = FirebaseRegisterTarget(url: firebaseAuthApiUrl,
                                                     isDebug: Constants.isDebug,
                                                     id: id,
                                                     keyForPassword: keyForPassword,
                                                     device: Constants.device,
                                                     passcode: passcode)

                return self.firebaseRegisterTarget.rx
                    .request(request)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map { _ -> Bool in true }
                    .asObservable()
            }
            .catchError { error -> Observable<Bool> in
                Observable.error(NetworkError.error(by: error))
            }
    }

    func auth(with id: String, passcode: String) -> Observable<String> {
        serverEnvironmentRepository.serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<String> in

                guard let self = self else { return Observable.never() }

                let firebaseAuthApiUrl = serverEnvironment.servers.firebaseAuthApiUrl

                let request = FirebaseAuthTarget(url: Constants.url,
                                                 isDebug: Constants.isDebug,
                                                 id: id,
                                                 device: Constants.device,
                                                 passcode: passcode)

                return self.firebaseAuthTarget.rx
                    .request(request)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .flatMap { response -> PrimitiveSequence<SingleTrait, String> in
                        guard let string = String(data: response.data, encoding: .utf8) else {
                            return Single.error(RepositoryError.fail)
                        }
                        return Single.just(string)
                    }
                    .asObservable()
            }
            .catchError { error -> Observable<String> in
                Observable.error(NetworkError.error(by: error))
            }
    }

    func changePasscode(with id: String, oldPasscode: String, passcode: String) -> Observable<Bool> {
        return auth(with: id,
                    passcode: oldPasscode)
            .flatMap { [weak self] keyForPassword -> Observable<Bool> in

                guard let self = self else { return Observable.never() }
                return self.registration(with: id,
                                         keyForPassword: keyForPassword,
                                         passcode: passcode)
            }
    }
}

private struct FirebaseRegisterTarget: Codable {
    let url: URL
    let isDebug: Bool
    let id: String
    let keyForPassword: String
    let device: String
    let passcode: String

    private enum CodingKeys: String, CodingKey {
        case url
        case id
        case isDebug
        case keyForPassword = "secret"
        case device
        case passcode
    }
}

extension FirebaseRegisterTarget: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        return url
    }

    var path: String {
        if isDebug {
            return "register_dev"
        } else {
            return "register"
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
    }
}

private struct FirebaseAuthTarget: Codable {
    let url: URL
    let isDebug: Bool
    let id: String
    let device: String
    let passcode: String

    private enum CodingKeys: String, CodingKey {
        case url
        case id
        case isDebug
        case device
        case passcode
    }
}

extension FirebaseAuthTarget: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        return url
    }

    var path: String {
        if isDebug {
            return "pass_dev"
        } else {
            return "pass"
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
    }
}

private struct FirebaseRevokeTarget: Codable {
    let url: URL
    let isDebug: Bool
    let id: String
    let device: String

    private enum CodingKeys: String, CodingKey {
        case url
        case id
        case isDebug
        case device
    }
}

extension FirebaseRevokeTarget: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        return url
    }

    var path: String {
        if isDebug {
            return "revoke_dev"
        } else {
            return "revoke"
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
    }
}
