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
        let validationError = input.validationError.map { $0?.localizedDescription }

        let fiatTitle = StateHelper.makeFiatTitle(readOnlyState: input.readOnlyState, didSelectFiatItem: input.didSelectFiatItem)
        let fiatAssets = StateHelper.makeFiatAssets(readOnlyState: input.readOnlyState)
        
        let cryptoTitleWithAmount = Observable.combineLatest(input.didChangeFiatAmount.asObservable(),
                                                             input.didSelectCryptoItem.asObservable())
            .map { ($0, $1) }
            .filteredByState(input.readOnlyState) { state -> BuyCryptoInteractor.ExchangeInfo? in
                switch state {
                case .readyForExchange(let exchangeInfo): return exchangeInfo
                default: return nil
                }
        }
        .compactMap { args, exchangeInfo -> String? in
            let (fiatAmountOptionalString, selectedCrypto) = args
            guard let fiatAmountString = fiatAmountOptionalString, let fiatAmount = Decimal(string: fiatAmountString) else {
                return nil
            }
            
            let iBuyCrypto = fiatAmount * Decimal(exchangeInfo.rate)
            
            let iBuyCryptoMoney = Money(value: iBuyCrypto, Int(selectedCrypto.decimals))
            
            return Localizable.Waves.Buycrypto.iBuy("≈ \(iBuyCryptoMoney.displayText) \(selectedCrypto.name)")
        }

        let initialCryptoTitle = StateHelper.makeCryptoTitle(readOnlyState: input.readOnlyState,
                                                             didSelectCryptoItem: input.didSelectCryptoItem)
        
        let cryptoTitle = Observable.merge(cryptoTitleWithAmount, initialCryptoTitle.asObservable())
            .asDriver(onErrorJustReturn: Localizable.Waves.Buycrypto.iBuy(""))

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
            readOnlyState.map { state -> Bool in
                switch state {
                case .isLoading: return false
                default: return true
                }
            }
            .asDriver(onErrorJustReturn: true)
        }

        static func makeLoadingIndicator(readOnlyState: Observable<BuyCryptoState>) -> Driver<Bool> {
            readOnlyState.map { state -> Bool in
                switch state {
                case .isLoading: return true
                default: return false
                }
            }
            .asDriver(onErrorJustReturn: false)
        }

        static func makeShowInitialError(readOnlyState: Observable<BuyCryptoState>) -> Signal<String> {
            readOnlyState.compactMap { state -> String? in
                switch state {
                case let .loadingError(errorMessage): return errorMessage
                default: return nil
                }
            }
            .asSignalIgnoringError()
        }
        
        static func makeShowSnackBarError(readOnlyState: Observable<BuyCryptoState>) -> Signal<String> {
            readOnlyState.compactMap { state -> String? in
                switch state {
                case .checkingExchangePairError(let error, _, _): return error.localizedDescription
                default: return nil
                }
            }
            .asSignalIgnoringError()
        }

        static func makeFiatTitle(readOnlyState: Observable<BuyCryptoState>,
                                  didSelectFiatItem: ControlEvent<AssetViewModel>) -> Driver<String> {
            didSelectFiatItem.filteredByState(readOnlyState) { state -> Bool in
                switch state {
                case .aCashAssetsLoaded: return true
                case .checkingExchangePair: return true
                default: return false
                }
            }
            .map { Localizable.Waves.Buycrypto.iSpent($0.name) }
            .asDriver(onErrorJustReturn: Localizable.Waves.Buycrypto.iSpent(""))
        }

        static func makeFiatAssets(readOnlyState: Observable<BuyCryptoState>) -> Driver<[AssetViewModel]> {
            readOnlyState.compactMap { state -> [AssetViewModel]? in
                switch state {
                case let .aCashAssetsLoaded(assets): return assets.fiatAssets.map { Helper.makeAssetViewModel(from: $0) }
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: [])
        }

        static func makeCryptoTitle(readOnlyState: Observable<BuyCryptoState>,
                                    didSelectCryptoItem: ControlEvent<AssetViewModel>) -> Driver<String> {
            didSelectCryptoItem.filteredByState(readOnlyState) { state -> Bool in
                switch state {
                case .aCashAssetsLoaded: return true
                case .checkingExchangePair: return true
                default: return false
                }
            }
            .map { Localizable.Waves.Buycrypto.iBuy($0.name) }
            .asDriver(onErrorJustReturn: Localizable.Waves.Buycrypto.iBuy(""))
        }

        static func makeCryptoAssets(readOnlyState: Observable<BuyCryptoState>) -> Driver<[AssetViewModel]> {
            readOnlyState.compactMap { state -> [AssetViewModel]? in
                switch state {
                case let .aCashAssetsLoaded(assets):
                    return assets.cryptoAssets.map { Helper.makeAssetViewModel(from: $0) }
                default: return nil
                }
            }
            .asDriver(onErrorJustReturn: [])
        }

        static func makeBuyButton(readOnlyState: Observable<BuyCryptoState>,
                                  didSelectCryptoItem: ControlEvent<AssetViewModel>) -> Driver<TitledBool> {
            didSelectCryptoItem.filteredByState(readOnlyState) { state -> Bool in
                switch state {
                case .aCashAssetsLoaded: return true
                default: return false
                }
            }
            .map { TitledBool(title: Localizable.Waves.Buycrypto.buy($0.name), isOn: false) }
            .asDriver(onErrorJustReturn: TitledBool(title: Localizable.Waves.Buycrypto.buy(""), isOn: false))
        }

        static func makeDetailsInfo(readOnlyState: Observable<BuyCryptoState>,
                                    didSelectFiatItem: ControlEvent<AssetViewModel>) -> Driver<ExchangeMessage> {
            didSelectFiatItem.filteredByState(readOnlyState) { state -> Bool in
                switch state {
                case .isLoading: return false
                case .loadingError: return false
                case .checkingExchangePairError: return false
                default: return true
                }
            }
            .compactMap { fiatAsset -> ExchangeMessage? in
                guard let link = URL(string: "https://support.waves.exchange/") else { return nil }
                let message: String
                if fiatAsset.id == "AC_USD" {
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
    }
}
