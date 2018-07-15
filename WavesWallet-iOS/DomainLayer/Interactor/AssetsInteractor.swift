//
//  AssetsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import RxRealm
import RxSwift

protocol AssetsInteractorProtocol {
    func assetsBy(ids: [String]) -> Observable<[Asset]>
}

final class AssetsInteractor: AssetsInteractorProtocol {
    private let apiProvider: MoyaProvider<API.Service.Assets> = MoyaProvider<API.Service.Assets>()
    private let realm = try? Realm()

    func assetsBy(ids: [String]) -> Observable<[Asset]> {
        let assets = realm?
            .objects(Asset.self)

        // TODO: Нужно решить в какой момент обновлять ассеты в базе
        guard assets?.count != ids.count else { return Observable.just(assets?.toArray() ?? []) }

        return apiProvider
            .rx
            .request(.getAssets(ids: ids))
            .map(API.Response<[API.Response<API.Model.Asset>]>.self)
            .map { $0.data.map { $0.data } }
            .map({ assets -> [Asset] in
                assets.map { Asset(model: $0) }
            })
            .do(onSuccess: { [weak self] assets in

                try? self?.realm?.write {
                    self?.realm?.add(assets, update: true)
                }
            })
            .asObservable()
    }
}

// MARK: Private method

extension AssetsInteractor {
}
