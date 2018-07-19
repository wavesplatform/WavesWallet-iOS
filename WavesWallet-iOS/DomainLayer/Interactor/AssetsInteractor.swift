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
    func assetsBy(ids: [String], accountAddress: String) -> Observable<[Asset]>
}

final class AssetsInteractor: AssetsInteractorProtocol {
    private let apiProvider: MoyaProvider<API.Service.Assets> = MoyaProvider<API.Service.Assets>()
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = MoyaProvider<Spam.Service.Assets>()
    private let realm = try? Realm()

    func assetsBy(ids: [String], accountAddress: String) -> Observable<[Asset]> {
        let assets = realm?
            .objects(Asset.self)

        // TODO: Нужно решить в какой момент обновлять ассеты в базе
        guard assets?.count != ids.count else { return Observable.just(assets?.toArray() ?? []) }

        let spamAssets = spamProvider
            .rx
            .request(.getSpamList)
            .map { response -> [String] in

                guard let text = String(data: response.data, encoding: .utf8) else { return [] }
                guard let csv: CSV = try? CSV(string: text, hasHeaderRow: true) else { return [] }

                var addresses = [String]()
                while let row = csv.next() {
                    guard let address = scamAddressFrom(row: row) else { continue }
                    addresses.append(address)
                }
                return addresses
            }
            .asObservable()

        let assetsList = apiProvider
            .rx
            .request(.getAssets(ids: ids))
            .map(API.Response<[API.Response<API.DTO.Asset>]>.self)
            .map { $0.data.map { $0.data } }
            .map({ assets -> [Asset] in
                assets.map { Asset(model: $0) }
            })
            .map { assets -> [Asset] in

                let generalAssets = Environments.current.generalAssetIds

                for generalAsset in generalAssets {
                    if let asset = assets.first(where: { $0.id == generalAsset.assetId }) {
                        asset.isGeneral = true
                        asset.name = generalAsset.name
                        asset.isFiat = generalAsset.isFiat
                        asset.isMyAsset = asset.sender == accountAddress
                    }
                }
                return assets
            }
            .asObservable()

        return Observable
            .zip(assetsList, spamAssets)
            .do(onNext: { [weak self] assets, spamAssets in

                assets.forEach { asset in
                    asset.isSpam = spamAssets.contains(asset.id)
                }

                try? self?.realm?.write {
                    self?.realm?.add(assets, update: true)
                }
            })
            .map { $0.0 }
    }
}

// MARK: Private method

extension AssetsInteractor {
}

fileprivate func scamAddressFrom(row: [String]) -> String? {
    if row.count < 2 {
        return nil
    }
    let address = row[0]
    let type = row[1]

    if type.lowercased() != "scam", address.count == 0 {
        return nil
    }

    return address
}
