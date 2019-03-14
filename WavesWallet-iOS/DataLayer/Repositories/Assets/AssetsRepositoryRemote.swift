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
    
    private let apiProvider: MoyaProvider<API.Service.Assets> = .nodeMoyaProvider()
    private let assetNodeProvider: MoyaProvider<Node.Service.Assets> = .nodeMoyaProvider()
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = .nodeMoyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func assets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {

        let environment = environmentRepository.accountEnvironment(accountAddress: accountAddress)

        let spamAssets = environment
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .spamProvider
                    .rx
                    .request(.getSpamList(url: environment.servers.spamUrl),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map { response -> [String] in
                return (try? SpamCVC.addresses(from: response.data)) ?? []
            }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            return Date(isoNormalize: decoder)
        }
        
        let assetsList = environment
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .apiProvider
                    .rx
                    .request(.init(kind: .getAssets(ids: ids), environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map(API.Response<[API.Response<API.DTO.Asset>]>.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
            .map { $0.data.map { $0.data } }

        return Observable.zip(assetsList, spamAssets, environment)
            .map { assets, spamAssets, environment in

                let map = environment.hashMapGeneralAssets()
                return assets.map { DomainLayer.DTO.Asset(asset: $0,
                                                          info: map[$0.id],
                                                          isSpam: spamAssets.contains($0.id),
                                                          isMyWavesToken: $0.sender == accountAddress) }
            }
    }

    func saveAssets(_ assets:[DomainLayer.DTO.Asset], by accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveAsset(_ asset: DomainLayer.DTO.Asset, by accountAddress: String) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func isSmartAsset(_ assetId: String, by accountAddress: String) -> Observable<Bool> {

        if assetId == GlobalConstants.wavesAssetId {
            return Observable.just(false)
        }

        let environment = environmentRepository.accountEnvironment(accountAddress: accountAddress)

        return environment
            .flatMap { [weak self] environment -> Single<Response> in

                guard let owner = self else { return Single.never() }
                return owner
                    .assetNodeProvider
                    .rx
                    .request(.init(kind: .details(assetId: assetId), environment: environment),
                            callbackQueue: DispatchQueue.global(qos: .userInteractive))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map(Node.DTO.AssetDetail.self)
            .map { $0.scripted == true }
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

    init(asset: API.DTO.Asset, info: Environment.AssetInfo?, isSpam: Bool, isMyWavesToken: Bool) {
        self.ticker = asset.ticker
        self.id = asset.id
        self.wavesId = info?.wavesId
        self.gatewayId = info?.gatewayId
        self.precision = asset.precision
        self.description = asset.description
        self.height = asset.height
        self.timestamp = asset.timestamp
        self.sender = asset.sender
        self.quantity = asset.quantity
        self.isReusable = asset.reissuable
        self.isSpam = isSpam
        self.isMyWavesToken = isMyWavesToken
        self.modified = Date()
        var isGeneral = false
        var isWaves = false
        var isFiat = false
        let isGateway = info?.isGateway ?? false
        var name = asset.name
        
        //TODO: Current code need move to AssetsInteractor!
        if let info = info {
            isGeneral = true
            if info.assetId == GlobalConstants.wavesAssetId {
                isWaves = true
            }
            name = info.displayName
            isFiat = info.isFiat
        }

        self.isWavesToken = isFiat == false && isGateway == false && isWaves == false
        self.isGeneral = isGeneral
        self.isWaves = isWaves
        self.isFiat = isFiat
        self.isGateway = isGateway
        self.displayName = name
        self.addressRegEx = info?.addressRegEx ?? ""
        self.iconLogoUrl = info?.iconUrls?.default
        self.hasScript = asset.hasScript
        self.minSponsoredFee = asset.minSponsoredFee ?? 0
    }
}
