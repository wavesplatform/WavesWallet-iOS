//
//  ApplicationVersionRepository.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30/05/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import Moya
import RxSwift

private struct Constants {
    static let lastVersion: String = "last_version"
    static let forceUpdateVersion: String = "force_update_version"
}

// TODO: Rename to service
final class ApplicationVersionRepository: ApplicationVersionRepositoryProtocol {
    private let applicationVersionService: MoyaProvider<ResourceAPI.Service.ApplicationVersion> = .anyMoyaProvider()

    func version() -> Observable<String> {
        return versionByMappingKey(key: Constants.lastVersion)
    }

    func forceUpdateVersion() -> Observable<String> {
        return versionByMappingKey(key: Constants.forceUpdateVersion)
    }
}

private extension ApplicationVersionRepository {
    func versionByMappingKey(key: String) -> Observable<String> {
        return applicationVersionService
            .rx
            .request(.get(isDebug: ApplicationDebugSettings.isEnableVersionUpdateTest))
            .map([String: String].self)
            .map { $0[key] }
            .asObservable()
            .flatMap { (version) -> Observable<String> in
                guard let version = version else { return Observable.error(RepositoryError.fail) }

                return Observable.just(version)
            }
    }
}
