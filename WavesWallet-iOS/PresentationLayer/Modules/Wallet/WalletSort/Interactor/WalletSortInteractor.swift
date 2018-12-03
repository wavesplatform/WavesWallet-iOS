//
//  WalletSortInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 25/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

private enum Constants {
    static let stepSize: Float = 0.000001
}

private extension WalletSort.DTO.Asset {

    static func map(from balance: DomainLayer.DTO.SmartAssetBalance) -> WalletSort.DTO.Asset {

        let isLock = balance.asset.isWaves == true
        let isMyWavesToken = balance.asset.isMyWavesToken
        let isFavorite = balance.settings.isFavorite
        let isGateway = balance.asset.isGateway
        let isHidden = balance.settings.isHidden
        let sortLevel = balance.settings.sortLevel
        return WalletSort.DTO.Asset(id: balance.assetId,
                                    name: balance.asset.displayName,
                                    isLock: isLock,
                                    isMyWavesToken: isMyWavesToken,
                                    isFavorite: isFavorite,
                                    isGateway: isGateway,
                                    isHidden: isHidden,
                                    sortLevel: sortLevel,
                                    icon: balance.asset.icon)
    }
}

final class WalletSortInteractor: WalletSortInteractorProtocol {

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let accountBalanceRepository: AccountBalanceRepositoryProtocol = FactoryRepositories.instance.accountBalanceRepositoryLocal

    private let disposeBag: DisposeBag = DisposeBag()

    func assets() -> Observable<[WalletSort.DTO.Asset]> {

        return Observable.never()
//        return authorizationInteractor
//            .authorizedWallet()
//            .flatMap({ [weak self] wallet -> Observable<[WalletSort.DTO.Asset]> in
//                guard let owner = self else { return Observable.never() }
//
//                return owner
//                    .accountBalanceRepository
//                    .balances(by: wallet.address,
//                              specification: .init(isSpam: false,
//                                                   isFavorite: nil,
//                                                   sortParameters: .init(ascending: true,
//                                                                         kind: .sortLevel)))
//                    .map({ balances -> [WalletSort.DTO.Asset] in
//                        return balances.map { WalletSort.DTO.Asset.map(from: $0) }
//                    })
//            })
//            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }

    func move(asset: WalletSort.DTO.Asset, underAsset: WalletSort.DTO.Asset) {
        move(asset: asset, toAsset: underAsset, shiftSortLevel: Constants.stepSize)
    }
    
    func move(asset: WalletSort.DTO.Asset, overAsset: WalletSort.DTO.Asset) {
        move(asset: asset, toAsset: overAsset, shiftSortLevel: -Constants.stepSize)
    }

    func update(asset: WalletSort.DTO.Asset) {

//        authorizationInteractor
//            .authorizedWallet()
//            .flatMap({ [weak self] wallet -> Observable<(wallet: DomainLayer.DTO.Wallet,
//                                                         assetBalance: DomainLayer.DTO.SmartAssetBalance,
//                                                         otherBalances: [DomainLayer.DTO.SmartAssetBalance])> in
//                guard let owner = self else { return Observable.never() }
//
//                let accountAddress = wallet.address
//                let currentAsset = owner
//                    .accountBalanceRepository
//                    .balance(by: asset.id,
//                             accountAddress: accountAddress)
//
//                let assets = owner
//                    .accountBalanceRepository
//                    .balances(by: accountAddress, specification: .init(isSpam: false,
//                                                                       isFavorite: asset.isFavorite,
//                                                                       sortParameters: .init(ascending: true,
//                                                                                             kind: .sortLevel)))
//                return Observable
//                    .zip(currentAsset, assets)
//                    .map { (wallet: wallet.wallet, assetBalance: $0.0, otherBalances: $0.1) }
//            })
//            .flatMap({ [weak self] data -> Observable<Void> in
//
//                guard let owner = self else { return Observable.never() }
//
//                let assetBalance = data.assetBalance
//                let wallet = data.wallet
//                let otherBalances = data.otherBalances
//                let isFavorite = assetBalance.settings?.isFavorite ?? false
//
//                var sortLevel = assetBalance.settings?.sortLevel ?? 0
//
//                if isFavorite != asset.isFavorite {
//                    if asset.isFavorite, let object = otherBalances.last {
//                        sortLevel = (object.settings?.sortLevel ?? 0) + Constants.stepSize
//                    } else if asset.isFavorite == false, let object = otherBalances.first {
//                        sortLevel = (object.settings?.sortLevel ?? 0) - Constants.stepSize
//                    }
//                }
//
//                var newAssetBalance = assetBalance
//
//                if asset.isLock == false {
//                    newAssetBalance.settings?.sortLevel = sortLevel
//                    newAssetBalance.settings?.isFavorite = asset.isFavorite
//                }
//
//                newAssetBalance.settings?.isHidden = asset.isHidden && asset.isFavorite == false
//
//                return owner
//                    .accountBalanceRepository
//                    .saveBalance(newAssetBalance,
//                                 accountAddress: wallet.address)
//                    .map { _ in () }
//
//            })
//            .share()
//            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
//            .subscribe()
//            .disposed(by: disposeBag)
    }

    private func move(asset: WalletSort.DTO.Asset,
                      toAsset: WalletSort.DTO.Asset,
                      shiftSortLevel: Float) {

        if asset.id == toAsset.id {
            return
        }

//        authorizationInteractor
//            .authorizedWallet()
//            .flatMapLatest({ [weak self] wallet -> Observable<(wallet: DomainLayer.DTO.Wallet,
//                                                         assetBalance: DomainLayer.DTO.SmartAssetBalance,
//                                                         toAssetBalance: DomainLayer.DTO.SmartAssetBalance)> in
//
//                guard let owner = self else { return Observable.never() }
//
//                let accountAddress = wallet.address
//                let assetBalance = owner
//                    .accountBalanceRepository
//                    .balance(by: asset.id,
//                             accountAddress: accountAddress)
//
//                let toAssetBalance = owner
//                    .accountBalanceRepository
//                    .balance(by: toAsset.id,
//                             accountAddress: accountAddress)
//                return Observable
//                    .zip(assetBalance, toAssetBalance)
//                    .map { (wallet: wallet.wallet, assetBalance: $0.0, toAssetBalance: $0.1) }
//            })
//            .flatMapLatest { [weak self] data -> Observable<Void> in
//
//                guard let owner = self else { return Observable.never() }
//
//                var newAssetBalance = data.assetBalance
//                newAssetBalance.settings?.sortLevel = (data.toAssetBalance.settings?.sortLevel ?? 0) + shiftSortLevel
//
//                return owner
//                    .accountBalanceRepository
//                    .saveBalance(newAssetBalance,
//                                 accountAddress: data.wallet.address)
//                    .map { _ in () }
//
//            }
//            .sweetDebug("Move")
//            .share()
//            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
//            .subscribe()
//            .disposed(by: disposeBag)
    }
}
