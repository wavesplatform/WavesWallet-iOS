//
//  AssetsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import CSV
import Foundation
import Moya
import RealmSwift
import RxRealm
import RxSwift

protocol AssetsInteractorProtocol {
    func assets(by ids: [String], accountAddress: String, isNeedUpdated: Bool) -> Observable<[DomainLayer.DTO.Asset]>
    func assetsSync(by ids: [String], accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Asset]>
}

fileprivate enum Constants {
    static let durationInseconds: Double =  0
}

final class AssetsInteractor: AssetsInteractorProtocol {

    private let repositoryLocal: AssetsRepositoryProtocol
    private let repositoryRemote: AssetsRepositoryProtocol
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol

    init(assetsRepositoryLocal: AssetsRepositoryProtocol,
         assetsRepositoryRemote: AssetsRepositoryProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol) {

        self.repositoryLocal = assetsRepositoryLocal
        self.repositoryRemote = assetsRepositoryRemote
        self.accountSettingsRepository = accountSettingsRepository
    }

    func assetsSync(by ids: [String], accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Asset]> {

        return remoteAssets(by: ids, accountAddress: accountAddress)
            .map({ assets in
                return .remote(assets)
            })
            .catchError { [weak self] remoteError -> SyncObservable<[DomainLayer.DTO.Asset]> in

                guard let owner = self else { return Observable.never() }

                return owner
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
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
    }

    private func remoteAssets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {
        return repositoryRemote
        .assets(by: ids, accountAddress: accountAddress)
        .flatMapLatest({ [weak self] assets -> Observable<[DomainLayer.DTO.Asset]> in
            guard let owner = self else { return Observable.never() }
            return owner
                .repositoryLocal
                .saveAssets(assets, by: accountAddress)
                .map({ _ -> [DomainLayer.DTO.Asset] in
                    return assets
                })
        })
        .flatMapLatest({ [weak self] assets -> Observable<[DomainLayer.DTO.Asset]> in
            guard let owner = self else { return Observable.never() }
            return owner.mutableResponce(assets: assets, accountAddress: accountAddress)
        })
    }

    private func localeAssets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {
        return repositoryLocal
            .assets(by: ids, accountAddress: accountAddress)
            .flatMapLatest({ [weak self] assets -> Observable<[DomainLayer.DTO.Asset]> in
                guard let owner = self else { return Observable.never() }
                return owner.mutableResponce(assets: assets, accountAddress: accountAddress)
            })
    }

    private func mutableResponce(assets: [DomainLayer.DTO.Asset], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {
        return self
            .accountSettingsRepository
            .accountSettings(accountAddress: accountAddress)
            .map({ settings -> [DomainLayer.DTO.Asset] in
                if let settings = settings, settings.isEnabledSpam == false {
                    return assets.mutate(transform: { asset in
                        asset.isSpam = false
                    })
                } else {
                    return assets
                }
            })
    }

    func assets(by ids: [String], accountAddress: String, isNeedUpdated: Bool) -> Observable<[DomainLayer.DTO.Asset]> {

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
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
    }
}
