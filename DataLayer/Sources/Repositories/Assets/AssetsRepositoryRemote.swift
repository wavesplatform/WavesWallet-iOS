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
import WavesSDKExtension
import WavesSDK
import DomainLayer
import Extensions

//TODO: move to SDK or change mapping assets
private enum Constants {
    static let vostokAssetId = "4LHHvYGNKJUg5hj65aGD5vgScvCBmLpdRFtjokvCjSL8"
}

final class AssetsRepositoryRemote: AssetsRepositoryProtocol {
    
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = .anyMoyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }

    func assets(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Asset]> {

        return environmentRepository
            .servicesEnvironment()
            .flatMap({ [weak self] (servicesEnvironment) -> Observable<[DomainLayer.DTO.Asset]> in
                
            guard let self = self else { return Observable.empty() }
            
            let walletEnviroment = servicesEnvironment.walletEnvironment

            let spamAssets = self.spamProvider.rx
                            .request(.getSpamList(hasProxy: true),
                                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
                            .catchError({ [weak self] (_) -> PrimitiveSequence<SingleTrait, Response> in
                                guard let self = self else { return Single.never() }
                                return self.spamProvider
                                    .rx
                                    .request(.getSpamList(hasProxy: false))
                            })
                            .filterSuccessfulStatusAndRedirectCodes()
                            .asObservable()
                            .catchError({ (error) -> Observable<Response> in
                                return Observable.error(NetworkError.error(by: error))
                            })
                            .map { response -> [String] in
                                return (try? SpamCVC.addresses(from: response.data)) ?? []
                            }

            let assetsList = servicesEnvironment
                .wavesServices
                .dataServices
                .assetsDataService
                .assets(ids: ids)
            
            return Observable.zip(assetsList, spamAssets)
                .map({ (assets, spamAssets) -> [DomainLayer.DTO.Asset] in
                    
                    let map = walletEnviroment.hashMapAssets()
                    
                    let spamIds = spamAssets.reduce(into: [String: Bool](), {$0[$1] = true })

                    return assets.map { DomainLayer.DTO.Asset(asset: $0,
                                                              info: map[$0.id],
                                                              isSpam: spamIds[$0.id] == true,
                                                              isMyWavesToken: $0.sender == accountAddress) }
                })
        })
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

        if assetId == WavesSDKCryptoConstants.wavesAssetId {
            return Observable.just(false)
        }

        return environmentRepository
            .servicesEnvironment()
            .map { $0.wavesServices }
            .flatMap({ (wavesServices) -> Observable<Bool> in                
                
                return wavesServices
                    .nodeServices
                    .assetsNodeService
                    .assetDetails(assetId: assetId)
                    .map { $0.scripted == true }
            })
    }
}

fileprivate extension WalletEnvironment {

    func hashMapAssets() -> [String: WalletEnvironment.AssetInfo] {
        
        var allAssets = generalAssets
        if let additionalAssets = assets {
            allAssets.append(contentsOf: additionalAssets)
        }
        
        return allAssets.reduce([String: WalletEnvironment.AssetInfo](), { map, info -> [String: WalletEnvironment.AssetInfo] in
            var new = map
            new[info.assetId] = info
            return new
        })
    }
}

fileprivate extension DomainLayer.DTO.Asset {

    init(asset: DataService.DTO.Asset, info: WalletEnvironment.AssetInfo?, isSpam: Bool, isMyWavesToken: Bool) {
        
        var isGeneral = false
        var isWaves = false
        var isVostok = false
        var isFiat = false
        let isGateway = info?.isGateway ?? false
        let isWavesToken = isFiat == false && isGateway == false && isWaves == false && isVostok == false
        var name = asset.name
        
        //TODO: Current code need move to AssetsInteractor!
        if let info = info {
            if info.assetId == WavesSDKCryptoConstants.wavesAssetId {
                isWaves = true
            }
            
            if info.assetId == Constants.vostokAssetId {
                isVostok = true
            }
            
            isGeneral = info.isGateway || isWaves || isVostok
            name = info.displayName
            isFiat = info.isFiat
        }
        
        self.init(id: asset.id,
                  gatewayId: info?.gatewayId,
                  wavesId: info?.wavesId,
                  displayName: name,
                  precision: asset.precision,
                  description: asset.description,
                  height: asset.height,
                  timestamp: asset.timestamp,
                  sender: asset.sender,
                  quantity: asset.quantity,
                  ticker: asset.ticker,
                  isReusable: asset.reissuable,
                  isSpam: isSpam,
                  isFiat: isFiat,
                  isGeneral: isGeneral,
                  isMyWavesToken: isMyWavesToken,
                  isWavesToken: isWavesToken,
                  isGateway: isGateway,
                  isWaves: isWaves,
                  modified: Date(),
                  addressRegEx: info?.addressRegEx ?? "",
                  iconLogoUrl: info?.iconUrls?.default,
                  hasScript: asset.hasScript,
                  minSponsoredFee: asset.minSponsoredFee ?? 0)
    }
}
