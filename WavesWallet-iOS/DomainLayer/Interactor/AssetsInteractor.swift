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

enum Sync<Result> {
    case remote(Result)
    case local(Result, error: Error)
    case error(Error)

    var remote: Result?  {
        switch self {
        case .remote(let model):
            return model

        default:
            return nil
        }
    }

    var local: (result: Result, error: Error)? {
        switch self {
        case .local(let model, let error):
            return (result: model, error: error)

        default:
            return nil
        }
    }

    var resultIngoreError: Result?  {
        switch self {
        case .remote(let model):
            return model

        case .local(let model, _):
            return model
        default:
            return nil
        }
    }

    var error: Error? {
        switch self {
        case .error(let error):
            return error

        default:
            return nil
        }
    }
}
typealias SyncObservable<R> = Observable<Sync<R>>

protocol AssetsInteractorProtocol {
    func assets(by ids: [String], accountAddress: String, isNeedUpdated: Bool) -> Observable<[DomainLayer.DTO.Asset]>

    func assetsSync(by ids: [String], accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Asset]>
}

fileprivate enum Constants {
    static let durationInseconds: Double =  320
}

final class AssetsInteractor: AssetsInteractorProtocol {

    private let repositoryLocal: AssetsRepositoryProtocol = FactoryRepositories.instance.assetsRepositoryLocal
    private let repositoryRemote: AssetsRepositoryProtocol = FactoryRepositories.instance.assetsRepositoryRemote
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol = FactoryRepositories.instance.accountSettingsRepository

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

        let local = repositoryLocal.assets(by: ids, accountAddress: accountAddress)
        return local
            .flatMap(weak: self) { owner, assets -> Observable<[DomainLayer.DTO.Asset]> in

            let now = Date()
            let isNeedForceUpdate = assets.count == 0 || assets.first { (now.timeIntervalSinceNow - $0.modified.timeIntervalSinceNow) > Constants.durationInseconds }  != nil || isNeedUpdated

            if isNeedForceUpdate {
                info("From Remote", type: AssetsInteractor.self)
            } else {
                info("From BD", type: AssetsInteractor.self)
            }

            guard isNeedForceUpdate == true else { return Observable.just(assets) }

                return owner
                    .repositoryRemote
                    .assets(by: ids, accountAddress: accountAddress)
                    .flatMap(weak: owner, selector: { owner, assets -> Observable<[DomainLayer.DTO.Asset]> in
                        return owner
                            .repositoryLocal
                            .saveAssets(assets, by: accountAddress)
                            .map({ _ -> [DomainLayer.DTO.Asset] in
                                return assets
                            })
                    })
            }
            .flatMap(weak: self, selector: { owner, assets -> Observable<[DomainLayer.DTO.Asset]> in

                return owner
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
            })
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
    }
}
