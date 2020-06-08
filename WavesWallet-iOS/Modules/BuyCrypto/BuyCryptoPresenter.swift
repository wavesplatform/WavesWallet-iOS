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

final class BuyCryptoPresenter: BuyCryptoPresentable {
    struct AssetViewModel {
        let id: String
        let name: String
        let decimals: Int32
        let icon: AssetLogo.Icon
        let iconStyle: AssetLogo.Style
    }

    struct ExchangeMessage {
        let message: String
        let linkWord: String
        let link: URL
    }
}

// MARK: - IOTransformer

extension BuyCryptoPresenter: IOTransformer {
    func transform(_ input: BuyCryptoInteractorOutput) -> BuyCryptoPresenterOutput {
        let contentVisible = StateHelper.makeContentVisible(readOnlyState: input.readOnlyState)
        let isLoadingIndicator = StateHelper.makeLoadingIndicator(readOnlyState: input.readOnlyState)

        let showInitialError = StateHelper.makeShowInitialError(readOnlyState: input.readOnlyState)
        let showSnackBarError = StateHelper.makeShowSnackBarError(readOnlyState: input.readOnlyState)
        let validationError = StateHelper.makeValidationError(validationError: input.validationError)

        let fiatTitle = StateHelper.makeFiatTitle(readOnlyState: input.readOnlyState, didSelectFiatItem: input.didSelectFiatItem)
        let fiatAssets = StateHelper.makeFiatAssets(readOnlyState: input.readOnlyState)

        let cryptoTitle = StateHelper.makeCryptoTitle(readOnlyState: input.readOnlyState,
                                                      didChangeFiatAmount: input.didChangeFiatAmount,
                                                      didSelectCryptoItem: input.didSelectCryptoItem)

        let cryptoAssets = StateHelper.makeCryptoAssets(readOnlyState: input.readOnlyState)

        let buyButtonModel = StateHelper.makeBuyButton(readOnlyState: input.readOnlyState,
                                                       didSelectCryptoItem: input.didSelectCryptoItem)

        let detailsInfo = StateHelper.makeDetailsInfo(readOnlyState: input.readOnlyState,
                                                      didSelectFiatItem: input.didSelectFiatItem)

        return BuyCryptoPresenterOutput(contentVisible: contentVisible,
                                        isLoadingIndicator: isLoadingIndicator,
                                        initialError: showInitialError,
                                        showSnackBarError: showSnackBarError,
                                        validationError: validationError,
                                        fiatTitle: fiatTitle,
                                        fiatItems: fiatAssets,
                                        cryptoTitle: cryptoTitle,
                                        cryptoItems: cryptoAssets,
                                        buyButtonModel: buyButtonModel,
                                        detailsInfo: detailsInfo)
    }
}

// MARK: - StateHelper

extension BuyCryptoPresenter {
    private enum StateHelper {
        static func makeContentVisible(readOnlyState: Observable<BuyCryptoState>) -> Driver<Bool> {
            readOnlyState.map { buyCryptoState -> Bool in
                switch buyCryptoState.state {
                case .isLoading: return false
                default: return true
                }
            }
            .asDriver(onErrorJustReturn: true)
        }

        static func makeLoadingIndicator(readOnlyState: Observable<BuyCryptoState>) -> Driver<Bool> {
            readOnlyState.map { buyCryptoState -> Bool in
                switch buyCryptoState.state {
                case .isLoading: return true
                default: return false
                }
            }
            .asDriver(onErrorJustReturn: false)
        }

        static func makeShowInitialError(readOnlyState: Observable<BuyCryptoState>) -> Signal<String> {
            readOnlyState.compactMap { buyCryptoState -> String? in
                switch buyCryptoState.state {
                case let .loadingError(errorMessage): return errorMessage.localizedDescription
                default: return nil
                }
            }
            .asSignalIgnoringError()
        }

        static func makeShowSnackBarError(readOnlyState: Observable<BuyCryptoState>) -> Signal<String> {
            readOnlyState.compactMap { buyCryptoState -> String? in
                switch buyCryptoState.state {
                case let .checkingExchangePairError(error, _, _, _): return error.localizedDescription
                default: return nil
                }
            }
            .asSignalIgnoringError()
        }

        static func makeFiatTitle(readOnlyState: Observable<BuyCryptoState>,
                                  didSelectFiatItem: ControlEvent<AssetViewModel>) -> Driver<String> {
            Observable.combineLatest(readOnlyState, didSelectFiatItem.asObservable())
                .compactMap { buyCryptoState, fiatItem -> String? in
                    switch buyCryptoState.state {
                    case .aCashAssetsLoaded, .checkingExchangePair, .readyForExchange:
                        return Localizable.Waves.Buycrypto.iSpent(fiatItem.name)
                    default: return nil
                    }
                }
                .asDriver(onErrorJustReturn: Localizable.Waves.Buycrypto.iSpent(""))
        }

        static func makeFiatAssets(readOnlyState: Observable<BuyCryptoState>) -> Driver<[AssetViewModel]> {
            readOnlyState.compactMap { buyCryptoState -> [AssetViewModel]? in
                switch buyCryptoState.state {
                case let .aCashAssetsLoaded(assets): return assets.fiatAssets.map { Helper.makeAssetViewModel(from: $0) }
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: [])
        }

        static func makeCryptoTitle(readOnlyState: Observable<BuyCryptoState>,
                                    didChangeFiatAmount: ControlEvent<String?>,
                                    didSelectCryptoItem: ControlEvent<AssetViewModel>) -> Driver<String> {
            Observable.combineLatest(didChangeFiatAmount.asObservable().startWith(""),
                                     didSelectCryptoItem.asObservable(),
                                     readOnlyState)
                .compactMap { fiatAmountOptionalString, selectedCrypto, buyCryptoState -> String? in
                    switch buyCryptoState.state {
                    case .aCashAssetsLoaded, .checkingExchangePair:
                        return Localizable.Waves.Buycrypto.iBuy(selectedCrypto.name)
                    case let .readyForExchange(exchangeInfo):
                        guard let fiatAmountString = fiatAmountOptionalString,
                            let fiatAmount = Decimal(string: fiatAmountString) else {
                            return Localizable.Waves.Buycrypto.iBuy(selectedCrypto.name)
                        }

                        let iBuyCrypto = fiatAmount * Decimal(exchangeInfo.rate)

                        let iBuyCryptoMoney = Money(value: iBuyCrypto, Int(selectedCrypto.decimals))

                        return Localizable.Waves.Buycrypto.iBuy("≈ \(iBuyCryptoMoney.displayText) \(selectedCrypto.name)")
                    default: return nil
                    }
                }
                .asDriverIgnoringError()
        }

        static func makeCryptoAssets(readOnlyState: Observable<BuyCryptoState>) -> Driver<[AssetViewModel]> {
            readOnlyState.compactMap { buyCryptoState -> [AssetViewModel]? in
                switch buyCryptoState.state {
                case let .aCashAssetsLoaded(assets):
                    if let selectedAsset = buyCryptoState.selectedAsset {
                        return [Helper.makeAssetViewModel(from: selectedAsset)]
                    } else {
                        return assets.cryptoAssets.map { Helper.makeAssetViewModel(from: $0) }
                    }
                    
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: [])
        }

        static func makeBuyButton(readOnlyState: Observable<BuyCryptoState>,
                                  didSelectCryptoItem: ControlEvent<AssetViewModel>) -> Driver<BlueButton.Model> {
            //  -> BlueButton.Model вот так работать не должно. делаю потому что срок горит
            Observable.combineLatest(didSelectCryptoItem, readOnlyState)
                .compactMap { cryptoItem, buyCryptoState -> BlueButton.Model? in
                    switch buyCryptoState.state {
                    case .aCashAssetsLoaded:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .loading)

                    case .checkingExchangePair:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .loading)

                    case .checkingExchangePairError:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .disabled)

                    case .readyForExchange:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .active)

                    default: return nil
                    }
                }
                .asDriverIgnoringError()
        }

        static func makeDetailsInfo(readOnlyState: Observable<BuyCryptoState>,
                                    didSelectFiatItem: ControlEvent<AssetViewModel>) -> Driver<ExchangeMessage> {
            didSelectFiatItem.filteredByState(readOnlyState) { buyCryptoState -> Bool in
                switch buyCryptoState.state {
                case .isLoading: return false
                case .loadingError: return false
                case .checkingExchangePairError: return false
                default: return true
                }
            }
            .compactMap { fiatAsset -> ExchangeMessage? in
                guard let link = URL(string: UIGlobalConstants.URL.support) else { return nil }
                let message: String
                if fiatAsset.id == DomainLayerConstants.acUSDId {
                    message = Localizable.Waves.Buycrypto.Messageinfo.withoutConversionFee + "\n" +
                        Localizable.Waves.Buycrypto.Messageinfo.youCanBuyWithYourBankCard(fiatAsset.name) + "\n" +
                        Localizable.Waves.Buycrypto.Messageinfo.afterPaymentWillBeCreditedToYourAccount(fiatAsset.name) + "\n" +
                        Localizable.Waves.Buycrypto.Messageinfo.minAmount("10") + "\n" +
                        Localizable.Waves.Buycrypto.Messageinfo.ifYouHaveProblems

                } else {
                    message = Localizable.Waves.Buycrypto.Messageinfo.youMayBeChargedAnAdditionalConversionFee + "\n" +
                        Localizable.Waves.Buycrypto.Messageinfo.youCanBuyWithYourBankCard(fiatAsset.name) + "\n" +
                        Localizable.Waves.Buycrypto.Messageinfo.afterPaymentWillBeCreditedToYourAccount(fiatAsset.name) + "\n" +
                        Localizable.Waves.Buycrypto.Messageinfo.minAmount("10") + "\n" +
                        Localizable.Waves.Buycrypto.Messageinfo.ifYouHaveProblems
                }

                let linkWord = Localizable.Waves.Buycrypto.Messageinfo.Ifyouhaveproblems.linkWord

                return ExchangeMessage(message: message,
                                       linkWord: linkWord,
                                       link: link)
            }
            .asDriverIgnoringError()
        }

        static func makeValidationError(validationError: Signal<Error?>) -> Signal<String?> {
            validationError.map { error -> String? in
                if let error = error as? BuyCryptoInteractor.FiatAmountValidationError {
                    switch error {
                    case .isNaN:
                        return "Is not a number"
                    case let .lessMin(min):
                        return Localizable.Waves.Buycrypto.minAmount("\(min)")
                    case let .moreMax(max):
                        return Localizable.Waves.Buycrypto.maxAmount("\(max)")
                    }
                } else {
                    return error?.localizedDescription
                }
            }
        }
    }
}

// MARK: - Helper

extension BuyCryptoPresenter {
    private enum Helper {
        static func makeAssetViewModel(from fiatAsset: BuyCryptoInteractor.FiatAsset) -> AssetViewModel {
            let icon = AssetLogo.Icon(assetId: fiatAsset.id,
                                      name: fiatAsset.name,
                                      url: fiatAsset.assetInfo?.iconUrls?.default,
                                      isSponsored: false,
                                      hasScript: false)

            return AssetViewModel(id: fiatAsset.id, name: fiatAsset.name, decimals: 0, icon: icon, iconStyle: .large)
        }

        static func makeAssetViewModel(from cryptoAsset: BuyCryptoInteractor.CryptoAsset) -> AssetViewModel {
            let icon = AssetLogo.Icon(assetId: cryptoAsset.name,
                                      name: cryptoAsset.id,
                                      url: cryptoAsset.assetInfo?.iconUrls?.default,
                                      isSponsored: false,
                                      hasScript: false)

            return AssetViewModel(id: cryptoAsset.id,
                                  name: cryptoAsset.name,
                                  decimals: cryptoAsset.decimals,
                                  icon: icon,
                                  iconStyle: .large)
        }
        
        static func makeAssetViewModel(from asset: Asset) -> AssetViewModel {
            return AssetViewModel(id: asset.id,
                                  name: asset.name,
                                  decimals: Int32(asset.precision),
                                  icon: asset.iconLogo,
                                  iconStyle: .large)
        }
    }
}
