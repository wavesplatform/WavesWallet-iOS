//
//  AssetsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Extensions

final class AssetsUseCase: AssetsUseCaseProtocol {

    private let assetsRepositoryLocal: AssetsRepositoryProtocol
    private let assetsRepositoryRemote: AssetsRepositoryProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentRepository

    init(assetsRepositoryLocal: AssetsRepositoryProtocol,
         assetsRepositoryRemote: AssetsRepositoryProtocol,
         serverEnvironmentUseCase: ServerEnvironmentRepository) {
        self.assetsRepositoryLocal = assetsRepositoryLocal
        self.assetsRepositoryRemote = assetsRepositoryRemote
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }

    func assetsSync(by ids: [String], accountAddress: String) -> SyncObservable<[Asset]> {

        return remoteAssets(by: ids, accountAddress: accountAddress)
            .map({ assets in
                return .remote(assets)
            })
            .catchError { [weak self] remoteError -> SyncObservable<[Asset]> in

                guard let self = self else { return Observable.never() }

                return self
                    .localeAssets(by: ids, accountAddress: accountAddress)
                    .map({ assets in
                        if assets.count > 0 {
                            return .local(assets, error: remoteError)
                        } else {
                            return .error(remoteError)
                        }
                    })
                    .catchError({ (localError) -> SyncObservable<[Asset]> in
                        return SyncObservable<[Asset]>.just(.error(remoteError))
                    })
            }
            .take(1)
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }

    private func remoteAssets(by ids: [String], accountAddress: String) -> Observable<[Asset]> {
        
        return serverEnvironmentUseCase
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<[Asset]> in
                
                guard let self = self else { return Observable.never() }
                
                return self
                    .assetsRepositoryRemote
                    .assets(serverEnvironment: serverEnvironment,
                            ids: ids,
                            accountAddress: accountAddress)
            }
            .flatMapLatest({ [weak self] assets -> Observable<[Asset]> in
                guard let self = self else { return Observable.never() }
                return self
                    .assetsRepositoryLocal
                    .saveAssets(assets, by: accountAddress)
                    .map({ _ -> [Asset] in
                        return assets
                    })
            })
    }

    private func localeAssets(by ids: [String], accountAddress: String) -> Observable<[Asset]> {
        
        return serverEnvironmentUseCase
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<[Asset]> in
            
                guard let self = self else { return Observable.never() }
                
                return self
                    .assetsRepositoryLocal
                    .assets(serverEnvironment: serverEnvironment, ids: ids, accountAddress: accountAddress)
            }
    }

    func assets(by ids: [String], accountAddress: String) -> Observable<[Asset]> {

        return assetsSync(by: ids,
                          accountAddress: accountAddress)
            .flatMap({ (sync) -> Observable<[Asset]> in

                if let remote = sync.resultIngoreError {
                    return Observable.just(remote)
                }

                switch sync {
                case .remote(let model):
                    return Observable.just(model)

                case .local(_, let error):
                    return Observable.error(error)

                case .error(let error):
                    return Observable.error(error)
                }
            })            
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }
}
