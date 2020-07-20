//
//  AssetListInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/4/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import RxSwift

final class AssetListInteractor: AssetListInteractorProtocol {
    private let accountBalanceInteractor: AccountBalanceUseCaseProtocol = UseCasesFactory.instance.accountBalance
    private let auth: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization

    private let searchString: BehaviorSubject<String> = BehaviorSubject<String>(value: "")
    private var filteredAssets: [DomainLayer.DTO.SmartAssetBalance] = []
    private var cachedAssets: [DomainLayer.DTO.SmartAssetBalance] = []
    private var isMyList = false

    func assets(filters: [AssetList.DTO.Filter], isMyList: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return auth.authorizedWallet().flatMap { [weak self] (_) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
            guard let self = self else { return Observable.empty() }

            self.isMyList = isMyList

            let assets = self.getCachedAssets()
                .map { [weak self] (assets) -> [DomainLayer.DTO.SmartAssetBalance] in

                    guard let self = self else { return [] }

                    let filteredSpamAssets = assets.filter { $0.asset.isSpam == false }

                    if filters.contains(.all) {
                        self.filteredAssets = filteredSpamAssets
                    } else {
                        self.filterAssets(filters: filters, assets: filteredSpamAssets)
                    }

                    return self.filterIsMyAsset(self.filteredAssets)
                }

            let search = self.searchString
                .asObserver().skip(1)
                .map { [weak self] _ -> [DomainLayer.DTO.SmartAssetBalance] in

                    guard let self = self else { return [] }
                    return self.filterIsMyAsset(self.filteredAssets)
                }

            return Observable
                .merge([assets, search])
                .map { [weak self] assets -> [DomainLayer.DTO.SmartAssetBalance] in

                    guard let self = self else { return [] }

                    let searchText = (try? self.searchString.value()) ?? ""

                    let newAssets = assets.filter {
                        let asset = $0.asset
                        return self.isValidSearch(name: asset.displayName, searchText: searchText)
                    }

                    return self.filterIsMyAsset(newAssets)
                }
        }
        .catchError { (_) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
            Observable.just([])
        }
    }

    func searchAssets(searchText: String) {
        searchString.onNext(searchText)
    }
}

private extension AssetListInteractor {
    func getCachedAssets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        if !cachedAssets.isEmpty {
            return Observable.just(cachedAssets)
        }
        return accountBalanceInteractor
            .balances()
            .flatMap { [weak self] assets -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.empty() }
                self.cachedAssets = assets
                return Observable.just(assets)
            }
    }

    func filterIsMyAsset(_ assets: [DomainLayer.DTO.SmartAssetBalance]) -> [DomainLayer.DTO.SmartAssetBalance] {
        return isMyList ? assets.filter { $0.availableBalance > 0 } : assets
    }

    func filterAssets(filters: [AssetList.DTO.Filter], assets: [DomainLayer.DTO.SmartAssetBalance]) {

        let filterAssets = assets.filter { balance -> Bool in

            let asset = balance.asset

            let results = filters.map { filter -> Bool in

                if filter == .waves {
                    return asset.isFiat == false &&
                        asset.isWavesToken == false &&
                        asset.isGateway == false &&
                        asset.isWaves == true
                }

                if filter == .cryptoCurrency {
                    return asset.isFiat == false &&
                        asset.isWavesToken == false &&
                        asset.isGateway == true &&
                        asset.isWaves == false
                }

                if filter == .existInExternalSource {
                    return asset.isExistInExternalSource
                }

                if filter == .fiat {
                    return asset.isFiat == true &&
                        asset.isWavesToken == false &&
                        asset.isGateway == true &&
                        asset.isWaves == false
                }

                if filter == .wavesToken {
                    return asset.isFiat == true &&
                        asset.isWavesToken == false &&
                        asset.isGateway == true &&
                        asset.isWaves == false
                }
                
                return false
            }

            return results.contains(true)
        }

        filteredAssets.removeAll()
        filteredAssets.append(contentsOf: filterAssets)
    }

    func isValidSearch(name: String, searchText: String) -> Bool {
        let searchWords = searchText.components(separatedBy: " ").filter { !$0.isEmpty }

        var validations: [Bool] = []
        for word in searchWords {
            validations.append((name.lowercased() as NSString).range(of: word.lowercased()).location != NSNotFound)
        }
        return validations.filter { $0 == true }.count == searchWords.count
    }
}
