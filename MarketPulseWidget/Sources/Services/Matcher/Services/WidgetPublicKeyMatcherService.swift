//
//  PublicKeyMatcherService.swift
//  Alamofire
//
//  Created by rprokofev on 06/05/2019.
//

import DataLayer
import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK

final class WidgetPublicKeyMatcherService: PublicKeyMatcherServiceProtocol {
    private typealias MatcherPublicKeyTarget = WidgetMatcherService.Target.MatcherPublicKey

    private let publicKeyProvider: MoyaProvider<MatcherPublicKeyTarget> = InternalWidgetService.moyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func publicKey() -> Observable<String> {
        environmentRepository.walletEnvironment()
            .flatMap { [weak self] environment -> Observable<String> in

                guard let self = self else { return Observable.never() }

                return self
                    .publicKeyProvider
                    .rx
                    .request(.init(matcherUrl: environment.servers.matcherUrl),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError { error -> Single<Response> in Single<Response>.error(NetworkError.error(by: error)) }
                    .flatMap { response -> Single<String> in
                        do {
                            // codable!!!!!!!
                            let data = response.data
                            guard let key = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? String
                            else {
                                return Single.error(NetworkError.none)
                            }
                            return Single.just(key)
                        } catch {
                            return Single.error(error)
                        }
                    }
                    .asObservable()
            }
    }
}
