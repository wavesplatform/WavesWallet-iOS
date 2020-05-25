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

        let fiatTitle = input.didSelectFiatItem
            .filteredByState(input.readOnlyState) { state -> Bool in
                switch state {
                case .aCashAssetsLoaded: return true
                default: return false
                }
            }
            .map { Localizable.Waves.Buycrypto.iSpent($0.name) }
            .asDriver(onErrorJustReturn: Localizable.Waves.Buycrypto.iSpent(""))

        let fiatAssets = input.readOnlyState
            .compactMap { state -> [AssetViewModel]? in
                switch state {
                case let .aCashAssetsLoaded(assets):
                    return assets.fiatAssets.map { Helper.makeAssetViewModel(from: $0) }
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: [])

        let cryptoTitle = input.didSelectCryptoItem
            .filteredByState(input.readOnlyState) { state -> Bool in
                switch state {
                case .aCashAssetsLoaded: return true
                default: return false
                }
            }
            .map { Localizable.Waves.Buycrypto.iBuy($0.name) }
            .asDriver(onErrorJustReturn: Localizable.Waves.Buycrypto.iBuy(""))

        let cryptoAssets = input.readOnlyState
            .compactMap { state -> [AssetViewModel]? in
                switch state {
                case let .aCashAssetsLoaded(assets):
                    return assets.cryptoAssets.map { Helper.makeAssetViewModel(from: $0) }
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: [])

        let buyButtonModel = input.didSelectCryptoItem
            .filteredByState(input.readOnlyState) { state -> Bool in
                switch state {
                case .aCashAssetsLoaded: return true
                default: return false
                }
            }
            .map { TitledBool(title: Localizable.Waves.Buycrypto.buy($0.name), isOn: false) }
            .asDriver(onErrorJustReturn: TitledBool(title: Localizable.Waves.Buycrypto.buy(""), isOn: false))

        return BuyCryptoPresenterOutput(contentVisible: contentVisible,
                                        isLoadingIndicator: isLoadingIndicator,
                                        error: showError,
                                        validationError: validationError,
                                        fiatTitle: fiatTitle,
                                        fiatItems: fiatAssets,
                                        cryptoTitle: cryptoTitle,
                                        cryptoItems: cryptoAssets,
                                        buyButtonModel: buyButtonModel,
                                        detailsInfo: Driver<String>.never())
    }
}

extension BuyCryptoPresenter {
    private enum Helper {
        static func makeAssetViewModel(from fiatAsset: BuyCryptoInteractor.FiatAsset) -> AssetViewModel {
            let icon = AssetLogo.Icon(assetId: fiatAsset.id,
                                      name: fiatAsset.name,
                                      url: fiatAsset.assetInfo.iconUrls?.default,
                                      isSponsored: false,
                                      hasScript: false)

            return AssetViewModel(id: fiatAsset.id, name: fiatAsset.name, icon: icon, iconStyle: .large)
        }

        static func makeAssetViewModel(from cryptoAsset: BuyCryptoInteractor.CryptoAsset) -> AssetViewModel {
            let icon = AssetLogo.Icon(assetId: cryptoAsset.name,
                                      name: cryptoAsset.id,
                                      url: cryptoAsset.assetInfo.iconUrls?.default,
                                      isSponsored: false,
                                      hasScript: false)

            return AssetViewModel(id: cryptoAsset.id, name: cryptoAsset.name, icon: icon, iconStyle: .large)
        }
    }
}
