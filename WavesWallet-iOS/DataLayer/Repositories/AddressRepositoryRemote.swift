//
//  AddressRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class AddressRepositoryRemote: AddressRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocol

    private let addressesProvider: MoyaProvider<Node.Service.Addresses> = .nodeMoyaProvider()

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func isSmartAddress(accountAddress: String) -> Observable<Bool> {

        let environment = environmentRepository.accountEnvironment(accountAddress: accountAddress)

        return environment
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .addressesProvider
                    .rx
                    .request(.init(kind: .scriptInfo(id: accountAddress), environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map(Node.DTO.AddressScriptInfo.self)
            .map { ($0.extraFee ?? 0) > 0 }
    }
}
