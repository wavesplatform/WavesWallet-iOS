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

private struct Constants {
    static let lastVersion: String = "last_version"
}

final class ApplicationVersionRepository: ApplicationVersionRepositoryProtocol {
    
    private let applicationNewsService: MoyaProvider<GitHub.Service.ApplicationVersion> = .nodeMoyaProvider()
    
    func version() -> Observable<String> {
        return applicationNewsService
            .rx
            .request(.get)
            .map([String: String].self)
            .map { $0[Constants.lastVersion] }
            .asObservable()
            .flatMap({ (version) -> Observable<String> in
                guard let version = version else { return Observable.error(RepositoryError.fail) }
                
                return Observable.just(version)
            })
    }
}
