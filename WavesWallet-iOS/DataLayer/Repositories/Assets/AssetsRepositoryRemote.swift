//
//  AssetsRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CSV

final class AssetsRepositoryRemote: AssetsRepositoryProtocol {
    
    private let apiProvider: MoyaProvider<API.Service.Assets> = MoyaProvider<API.Service.Assets>(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = MoyaProvider<Spam.Service.Assets>(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    func assets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {

        let spamAssets = spamProvider
            .rx
            .request(.getSpamList, callbackQueue: DispatchQueue.global(qos: .background))
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
            .request(.getAssets(ids: ids), callbackQueue: DispatchQueue.global(qos: .background))
            .map(API.Response<[API.Response<API.DTO.Asset>]>.self)
            .map { $0.data.map { $0.data } }
            .asObservable()

        return Observable.zip(assetsList, spamAssets)
            .map { assets, spamAssets in

                let map = Environments.current.hashMapGeneralAssets()
                return assets.map { DomainLayer.DTO.Asset(asset: $0,
                                                          info: map[$0.id],
                                                          isSpam: spamAssets.contains($0.id),
                                                          isMyAsset:  $0.sender == accountAddress) }
            }
    }

    func saveAssets(_ assets:[DomainLayer.DTO.Asset]) -> Observable<Bool> {
        assert(true, "Method don't supported")
        return Observable.never()
    }

    func saveAsset(_ asset: DomainLayer.DTO.Asset) -> Observable<Bool> {
        assert(true, "Method don't supported")
        return Observable.never()
    }
}

fileprivate extension Environment {

    func hashMapGeneralAssets() -> [String: Environment.AssetInfo] {
        return generalAssetIds.reduce([String: Environment.AssetInfo](), { map, info -> [String: Environment.AssetInfo] in
            var new = map
            new[info.assetId] = info
            return new
        })
    }
}

fileprivate extension DomainLayer.DTO.Asset {

    init(asset: API.DTO.Asset, info: Environment.AssetInfo?, isSpam: Bool, isMyAsset: Bool) {
        self.ticker = asset.ticker
        self.id = asset.id
        self.precision = asset.precision
        self.description = asset.description
        self.height = asset.height
        self.timestamp = asset.timestamp
        self.sender = asset.sender
        self.quantity = asset.quantity
        self.isReissuable = asset.reissuable
        self.isSpam = isSpam
        self.isMyAsset = isMyAsset
        self.modified = Date()
        var isGeneral = false
        var isWaves = false
        var isFiat = false
        var isGateway = false
        var name = asset.name

        if let info = info {
            isGeneral = true
            if info.assetId == Environments.Constants.wavesAssetId {
                isWaves = true
            } else {
                isGateway = true
            }
            name = info.name
            isFiat = info.isFiat
        }

        self.isGeneral = isGeneral
        self.isWaves = isWaves
        self.isFiat = isFiat
        self.isGateway = isGateway
        self.name = name
    }
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
