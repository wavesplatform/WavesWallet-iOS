//
//  AssetsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions

final class AssetsUseCase: AssetsUseCaseProtocol {

    private let repositoryLocal: AssetsRepositoryProtocol
    private let repositoryRemote: AssetsRepositoryProtocol

    init(assetsRepositoryLocal: AssetsRepositoryProtocol,
         assetsRepositoryRemote: AssetsRepositoryProtocol) {

        self.repositoryLocal = assetsRepositoryLocal
        self.repositoryRemote = assetsRepositoryRemote
    }

    func assetsSync(by ids: [String], accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Asset]> {

        return remoteAssets(by: ids, accountAddress: accountAddress)
            .map({ assets in
                return .remote(assets)
            })
            .catchError { [weak self] remoteError -> SyncObservable<[DomainLayer.DTO.Asset]> in

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
                    .catchError({ (localError) -> SyncObservable<[DomainLayer.DTO.Asset]> in
                        return SyncObservable<[DomainLayer.DTO.Asset]>.just(.error(remoteError))
                    })
            }
            .take(1)
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }

    private func remoteAssets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {
        return repositoryRemote
        .assets(by: ids, accountAddress: accountAddress)
        .flatMapLatest({ [weak self] assets -> Observable<[DomainLayer.DTO.Asset]> in
            guard let self = self else { return Observable.never() }
            return self
                .repositoryLocal
                .saveAssets(assets, by: accountAddress)
                .map({ _ -> [DomainLayer.DTO.Asset] in
                    return assets
                })
        })
    }

    private func localeAssets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {
        return repositoryLocal
            .assets(by: ids, accountAddress: accountAddress)
    }

    func assets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {

        return assetsSync(by: ids, accountAddress: accountAddress)
            .flatMap({ (sync) -> Observable<[DomainLayer.DTO.Asset]> in

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
