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

final class WalletSortInteractor: WalletSortInteractorProtocol {

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let assetsBalanceSettings: AssetsBalanceSettingsInteractorProtocol = FactoryInteractors.instance.assetsBalanceSettings

    private let disposeBag: DisposeBag = DisposeBag()

    func move(asset: WalletSort.DTO.Asset, underAsset: WalletSort.DTO.Asset) {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                return self.assetsBalanceSettings.move(by: wallet.address, assetId: asset.id, underAssetId: underAsset.id)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func move(asset: WalletSort.DTO.Asset, overAsset: WalletSort.DTO.Asset) {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                return self.assetsBalanceSettings.move(by: wallet.address, assetId: asset.id, overAssetId: overAsset.id)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    func setFavorite(assetId: String, isFavorite: Bool) {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                return self.assetsBalanceSettings.setFavorite(by: wallet.address, assetId: assetId, isFavorite: isFavorite)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    func setHidden(assetId: String, isHidden: Bool) {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                return self.assetsBalanceSettings.setHidden(by: wallet.address, assetId: assetId, isHidden: isHidden)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
}
