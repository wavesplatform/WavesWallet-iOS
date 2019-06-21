//
//  ApplicationVersionRepository.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30/05/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import Moya
import DomainLayer

private struct Constants {
    static let lastVersion: String = "last_version"
}

final class ApplicationVersionRepository: ApplicationVersionRepositoryProtocol {
    
    private let applicationVersionService: MoyaProvider<GitHub.Service.ApplicationVersion> = .anyMoyaProvider()
    
    func version() -> Observable<String> {
        return applicationVersionService
            .rx
            .request(.get(hasProxy: true))
            .catchError({ [weak self] (_) -> PrimitiveSequence<SingleTrait, Response> in
                guard let self = self else { return Single.never() }
                return self
                    .applicationVersionService
                    .rx
                    .request(.get(hasProxy: false))
            })
            .map([String: String].self)
            .map { $0[Constants.lastVersion] }
            .asObservable()
            .flatMap({ (version) -> Observable<String> in
                guard let version = version else { return Observable.error(RepositoryError.fail) }
                
                return Observable.just(version)
            })
    }
}
