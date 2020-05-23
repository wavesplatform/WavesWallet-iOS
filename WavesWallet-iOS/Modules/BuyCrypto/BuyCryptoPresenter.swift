//
//  BuyCryptoPresenter.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import DomainLayer
import Extensions
import RxCocoa
import RxSwift

final class BuyCryptoPresenter: BuyCryptoPresentable {}

// MARK: - IOTransformer

extension BuyCryptoPresenter: IOTransformer {
    struct AssetViewModel {
        let id: String
        let name: String
        let icon: AssetLogo.Icon
        let iconStyle: AssetLogo.Style
    }

    func transform(_ input: BuyCryptoInteractorOutput) -> BuyCryptoPresenterOutput {
        let contentVisible = input.readOnlyState
            .map { state -> Bool in
                switch state {
                case .isLoading: return false
                default: return true
                }
            }
            .asDriver(onErrorJustReturn: true)

        let isLoadingIndicator = input.readOnlyState
            .map { state -> Bool in
                switch state {
                case .isLoading: return true
                default: return false
                }
            }
            .asDriver(onErrorJustReturn: false)

        let showError = input.readOnlyState
            .compactMap { state -> String? in
                switch state {
                case let .loadingError(errorMessage): return errorMessage
                default: return nil
                }
            }
            .asSignalIgnoringError()

        let validationError = Signal<String?>.never()

        let fiatAssets = input.readOnlyState
            .compactMap { state -> [AssetViewModel]? in
                switch state {
                case let .aCashAssetsLoaded(assets):
                    return assets.filter { !$0.isCrypto }
                        .map { Helper.makeAssetViewModel(from: $0) }
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: [])

        let cryptoAssets = input.readOnlyState
            .compactMap { state -> [AssetViewModel]? in
                switch state {
                case let .aCashAssetsLoaded(assets):
                    return assets.filter { $0.isCrypto }
                        .map { Helper.makeAssetViewModel(from: $0) }
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: [])
        
        let buyButtonModel = Driver<TitledBool>.just(TitledBool(title: "Buy", isOn: false))

        return BuyCryptoPresenterOutput(contentVisible: contentVisible,
                                        isLoadingIndicator: isLoadingIndicator,
                                        error: showError,
                                        validationError: validationError,
                                        fiatTitle: Driver<String>.never(),
                                        fiatItems: fiatAssets,
                                        cryptoTitle: Driver<String>.never(),
                                        cryptoItems: cryptoAssets,
                                        buyButtonModel: buyButtonModel,
                                        detailsInfo: Driver<String>.never())
    }
}

extension BuyCryptoPresenter {
    private enum Helper {
        static func makeAssetViewModel(from model: BuyCryptoInteractor.Asset) -> AssetViewModel {
            let icon = AssetLogo.Icon(assetId: model.id,
                                      name: model.name,
                                      url: model.assetInfo.iconUrls?.default,
                                      isSponsored: false, // уточнить эти моменты
                                      hasScript: true) //

            return AssetViewModel(id: model.id, name: model.name, icon: icon, iconStyle: .large)
        }
    }
}
