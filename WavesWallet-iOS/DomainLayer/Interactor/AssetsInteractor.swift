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
}

private struct Constants {
        static let durationInseconds: Double =  320
}

final class AssetsInteractor: AssetsInteractorProtocol {

    private let repositoryLocal: AssetsRepositoryProtocol = FactoryRepositories.instance.assetsRepositoryLocal
    private let repositoryRemote: AssetsRepositoryProtocol = FactoryRepositories.instance.assetsRepositoryRemote

    func assets(by ids: [String], accountAddress: String, isNeedUpdated: Bool) -> Observable<[DomainLayer.DTO.Asset]> {

        let local = repositoryLocal.assets(by: ids, accountAddress: accountAddress)
        return local.flatMap(weak: self) { owner, assets -> Observable<[DomainLayer.DTO.Asset]> in

            let now = Date()
            let isNeedForceUpdate = assets.count == 0 || assets.first { (now.timeIntervalSinceNow - $0.modified.timeIntervalSinceNow) > Constants.durationInseconds }  != nil || isNeedUpdated

            if isNeedForceUpdate {
                info("From Remote", type: AssetsInteractor.self)
            } else {
                info("From BD", type: AssetsInteractor.self)
            }

            guard isNeedForceUpdate == true else { return Observable.just(assets) }

            return owner
                .repositoryRemote.assets(by: ids, accountAddress: accountAddress)
                .flatMap(weak: owner, selector: { owner, assets -> Observable<[DomainLayer.DTO.Asset]> in
                    return owner.repositoryLocal.saveAssets(assets).map({ _ -> [DomainLayer.DTO.Asset] in
                            return assets
                    })
                })
            }
            .share()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }
}
