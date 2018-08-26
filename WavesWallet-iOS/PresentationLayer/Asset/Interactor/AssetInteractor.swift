//
//  AssetViewInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class AssetInteractorMock: AssetInteractorProtocol {

    func assets(by ids: [String]) -> Observable<[AssetTypes.DTO.Asset]> {
        return JSONDecoder.decode(type: [AssetTypes.DTO.Asset].self, json: "Assets").delay(8, scheduler: MainScheduler.asyncInstance)
    }

    func transactions(by assetId: String) -> Observable<[AssetTypes.DTO.Transaction]> {
        return Observable.just([])
    }

    func refreshAssets(by ids: [String]) {

    }
}

final class AssetInteractor: AssetInteractorProtocol {

    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    private let leasingInteractor: LeasingInteractorProtocol = FactoryInteractors.instance.leasingInteractor

    private let refreshAssetsSubject: PublishSubject<[WalletTypes.DTO.Asset]> = PublishSubject<[WalletTypes.DTO.Asset]>()

    func assets(by ids: [String]) -> Observable<[AssetTypes.DTO.Asset]> {

        return assets(by: ids,
                      isNeedUpdate: false)
    }

    private func assets(by ids: [String], isNeedUpdate: Bool) -> Observable<[AssetTypes.DTO.Asset]> {

        guard let accountAddress = WalletManager.currentWallet?.address else { return Observable.empty() }

        return WalletManager
            .getPrivateKey()
            .flatMap(weak: self) { owner, privateKey -> AsyncObservable<[AssetTypes.DTO.Asset]> in

                return owner.accountBalanceInteractor
                    .balances(by: accountAddress,
                              privateKey: privateKey,
                              isNeedUpdate: false)
                    .filter {
                        $0.filter({ asset -> Bool in
                            return ids.contains(asset.assetId)
                        }).count != 0
                    }
                    .map { $0.map { $0.mapToAsset() } }
        }
    }

    func transactions(by assetId: String) -> Observable<[AssetTypes.DTO.Transaction]> {
        return Observable.just([])
    }

    func refreshAssets(by ids: [String]) { 

    }
}

private extension DomainLayer.DTO.AssetBalance {

    func mapToAsset() -> AssetTypes.DTO.Asset {
        return AssetTypes.DTO.Asset(info: mapToInfo(),
                                    balance: mapToBalance())
    }

    func mapToBalance() -> AssetTypes.DTO.Asset.Balance {

        let decimal = asset?.precision ?? 0

        let totalMoney = Money(balance, decimal)
        let avaliableMoney = Money(avaliableBalance, decimal)
        let leasedMoney = Money(leasedBalance, decimal)
        let inOrderMoney = Money(inOrderBalance, decimal)

        return AssetTypes.DTO.Asset.Balance(totalMoney: totalMoney,
                                            avaliableMoney: avaliableMoney,
                                            leasedMoney: leasedMoney,
                                            inOrderMoney: inOrderMoney)
    }

    func mapToInfo() -> AssetTypes.DTO.Asset.Info {

        let id = asset?.id ?? ""
        let issuer = asset?.sender ?? ""
        let name = asset?.name ?? ""
        let description = asset?.description ?? ""
        let issueDate = asset?.timestamp ?? Date()
        let isReusable = asset?.isReusable ?? false
        let isMyWavesToken = asset?.isMyWavesToken ?? false
        let isWavesToken = asset?.isWavesToken ?? false
        let isWaves = asset?.isWaves ?? false
        let isFavorite = settings?.isFavorite ?? false
        let isFiat = asset?.isFiat ?? false
        let isSpam = asset?.isSpam ?? false
        let isGateway = asset?.isGateway ?? false
        let sortLevel = settings?.sortLevel ?? 0

        return .init(id: id,
                     issuer: issuer,
                     name: name,
                     description: description,
                     issueDate: issueDate,
                     isReusable: isReusable,
                     isMyWavesToken: isMyWavesToken,
                     isWavesToken: isWavesToken,
                     isWaves: isWaves,
                     isFavorite: isFavorite,
                     isFiat: isFiat,
                     isSpam: isSpam,
                     isGateway: isGateway,
                     sortLevel: sortLevel)
    }
}
