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
        return JSONDecoder.decode(type: [AssetTypes.DTO.Asset].self, json: "Assets").delay(20, scheduler: MainScheduler.asyncInstance)
    }
}

final class AssetInteractor: AssetInteractorProtocol {

    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    private let leasingInteractor: LeasingInteractorProtocol = FactoryInteractors.instance.leasingInteractor

    private let refreshAssetsSubject: PublishSubject<[WalletTypes.DTO.Asset]> = PublishSubject<[WalletTypes.DTO.Asset]>()

    func assets(by ids: [String]) -> Observable<[AssetTypes.DTO.Asset]> {

        guard let accountAddress = WalletManager.currentWallet?.address else { return Observable.empty() }

//        let balance = WalletManager
//            .getPrivateKey()
//            .flatMap(weak: self) { owner, privateKey -> AsyncObservable<[AssetTypes.DTO.Asset]> in
//
//                accountBalanceInteractor.balances(by: accountAddress,
//                                                  privateKey: privateKey,
//                                                  isNeedUpdate: false).asObservable()
//
//        }

        return Observable.just([])
    }
    

    
}

private extension DomainLayer.DTO.AssetBalance {

//    func map() -> AssetTypes.DTO.Asset {
//
//
//
//    }

    func map() -> AssetTypes.DTO.Asset.Balance {


        return AssetTypes.DTO.Asset.Balance(totalMoney: <#T##Money#>, avaliableMoney: <#T##Money#>, leasedMoney: <#T##Money#>, inOrderMoney: <#T##Money#>)
    }

    func map() -> AssetTypes.DTO.Asset.Info {

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
