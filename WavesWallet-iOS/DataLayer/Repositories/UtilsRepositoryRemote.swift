//
//  UtilsRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/12/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

private enum Constants {
    static let minDifference: Int64 = 1000 * 30
}

final class UtilsRepositoryRemote: UtilsRepositoryProtocol {
    
    private let utilsProvider: MoyaProvider<Node.Service.Utils> = .nodeMoyaProvider()
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func timestampServerDiff(accountAddress: String) -> Observable<Int64> {
        return environmentRepository.accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<Int64> in
                guard let owner = self else { return Observable.empty() }
                return owner.utilsProvider.rx.request(.init(environment: environment, kind: .time))
                .map(Node.DTO.Utils.Time.self)
                .map { timestamp in
                    let localTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
                    let diff = localTimestamp - timestamp.NTP
                    return abs(diff) > Constants.minDifference ? diff : 0
                }
                .asObservable()
            })
    }
}
