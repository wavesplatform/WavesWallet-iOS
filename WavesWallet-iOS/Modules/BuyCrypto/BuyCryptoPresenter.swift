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
                                                       didSelectCryptoItem: input.didSelectCryptoItem,
                                                       validationError: input.validationError.asObservable(),
                                                       didChangeFiatAmount: input.didChangeFiatAmount.asObservable())

        let detailsInfo = StateHelper.makeDetailsInfo(readOnlyState: input.readOnlyState,
                                                      didSelectFiatItem: input.didSelectFiatItem,
                                                      didSelectCryptoItem: input.didSelectCryptoItem)

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
                                  didSelectCryptoItem: ControlEvent<AssetViewModel>,
                                  validationError: Observable<Error?>,
                                  didChangeFiatAmount: Observable<String?>) -> Driver<BlueButton.Model> {
            //  -> BlueButton.Model вот так работать не должно. делаю потому что срок горит
            Observable.combineLatest(didSelectCryptoItem, readOnlyState, validationError, didChangeFiatAmount)
                .compactMap { cryptoItem, buyCryptoState, error, amount -> BlueButton.Model? in
                    guard let amount = amount, !amount.isEmpty else {
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .disabled)
                    }

                    switch buyCryptoState.state {
                    case .aCashAssetsLoaded:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .loading)

                    case .checkingExchangePair:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .loading)

                    case .checkingExchangePairError:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .disabled)

                    case .readyForExchange:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name),
                                     status: error == nil ? .active : .disabled)

                    default:
                        return .init(title: Localizable.Waves.Buycrypto.buy(cryptoItem.name), status: .disabled)
                    }
                }
                .startWith(.init(title: Localizable.Waves.Buycrypto.buy(""), status: .disabled))
                .asDriverIgnoringError()
        }

        static func makeDetailsInfo(readOnlyState: Observable<BuyCryptoState>,
                                    didSelectFiatItem: ControlEvent<AssetViewModel>,
                                    didSelectCryptoItem: ControlEvent<AssetViewModel>) -> Driver<NSAttributedString> {
            Observable.combineLatest(didSelectFiatItem, didSelectCryptoItem, readOnlyState)
                .compactMap { fiatAsset, cryptoAsset, buyCryptoState -> NSAttributedString? in
                    switch buyCryptoState.state {
                    case let .readyForExchange(exchangeInfo):
                        return makeAttributeString(exchangeInfo: exchangeInfo, fiatAsset: fiatAsset, cryptoAsset: cryptoAsset)
                        
                    default: return nil
                    }
                }
                .asDriverIgnoringError()
        }
        
        private static func makeAttributeString(exchangeInfo: BuyCryptoInteractor.ExchangeInfo,
                                                fiatAsset: AssetViewModel,
                                                cryptoAsset: AssetViewModel) -> NSAttributedString? {
            let link: URL
            if Language.currentLanguage.code == "ru" {
                guard let linkFromUrl = URL(string: UIGlobalConstants.URL.supportRu) else { return nil }
                link = linkFromUrl
            } else {
                guard let linkFromUrl = URL(string: UIGlobalConstants.URL.supportEn) else { return nil }
                link = linkFromUrl
            }
            
            let minLimitMoney = Money(value: exchangeInfo.minLimit, Int(exchangeInfo.senderAsset.decimals))

            let conversionFee: NSAttributedString
            if cryptoAsset.id == DomainLayerConstants.acUSDId, fiatAsset.id == "USD" {
                conversionFee = NSAttributedString(string: Localizable.Waves.Buycrypto.Messageinfo.withoutConversionFee + "\n",
                                                   attributes: [.foregroundColor: UIColor.basic500,
                                                                .font: UIFont.boldSystemFont(ofSize: 12)])
            } else {
                conversionFee = NSAttributedString(string: Localizable.Waves.Buycrypto.Messageinfo.youMayBeChargedAnAdditionalConversionFee + "\n",
                                                   attributes: [.foregroundColor: UIColor.basic500,
                                                                .font: UIFont.boldSystemFont(ofSize: 12)])
            }

            let youCanBuyWithYourBankCard = NSAttributedString(string: Localizable.Waves.Buycrypto.Messageinfo.youCanBuyWithYourBankCard(fiatAsset.name) + "\n",
                                                               attributes: [.foregroundColor: UIColor.basic500])
            let afterPaymentWillBeCreditedToYourAccount = NSAttributedString(string: Localizable.Waves.Buycrypto.Messageinfo.afterPaymentWillBeCreditedToYourAccount(fiatAsset.name) + "\n",
                                                                             attributes: [.foregroundColor: UIColor.basic500])
            let minAmount = NSAttributedString(string: Localizable.Waves.Buycrypto.Messageinfo.minAmount("\(minLimitMoney.displayText) \(fiatAsset.name)") + "\n",
                                               attributes: [.foregroundColor: UIColor.basic500])

            let linkWord = Localizable.Waves.Buycrypto.Messageinfo.Ifyouhaveproblems.linkWord
            let ifYouHaveProblems = NSMutableAttributedString(string: Localizable.Waves.Buycrypto.Messageinfo.ifYouHaveProblems,
                                                              attributes: [.foregroundColor: UIColor.basic500])
            ifYouHaveProblems.addAttribute(NSAttributedString.Key.link,
                                           value: link,
                                           range: ifYouHaveProblems.mutableString.range(of: linkWord))

            let paragrapshStyle = NSMutableParagraphStyle()
            paragrapshStyle.maximumLineHeight = 14
            paragrapshStyle.minimumLineHeight = 14
            paragrapshStyle.lineSpacing = 0.1
            
            let allTextAttributedString = NSMutableAttributedString()
            allTextAttributedString.append(conversionFee)
            allTextAttributedString.append(minAmount)
            allTextAttributedString.append(youCanBuyWithYourBankCard)
            allTextAttributedString.append(afterPaymentWillBeCreditedToYourAccount)
            allTextAttributedString.append(ifYouHaveProblems)
            
            allTextAttributedString.addAttribute(.paragraphStyle,
            value: paragrapshStyle,
            range: NSRange(location: 0, length: allTextAttributedString.length))

            return allTextAttributedString
        }

        static func makeValidationError(validationError: Signal<Error?>) -> Signal<String?> {
            validationError.map { error -> String? in
                if let error = error as? BuyCryptoInteractor.FiatAmountValidationError {
                    switch error {
                    case .isNaN:
                        return "Is not a number"
                    case let .lessMin(min, decimals, name):
                        let money = Money(value: min, decimals)
                        return Localizable.Waves.Buycrypto.minAmount("\(money.displayText) \(name)")
                    case let .moreMax(max, decimals, name):
                        let money = Money(value: max, decimals)
                        return Localizable.Waves.Buycrypto.maxAmount("\(money.displayText) \(name)")
                    }
                } else {
                    return nil
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
            let wavesId = asset.wavesId?.replacingOccurrences(of: "USDN", with: "AC_USD")
                .replacingOccurrences(of: "WBTC", with: "BTC") // РУСЛАН ОЧЕНЬ ВНИМАТЕЛЬНО ПОСМОТРИ
                .replacingOccurrences(of: "WAVES", with: "AC_WAVES")
                .replacingOccurrences(of: "WEST", with: "AC_WEST") ?? ""

            let iconLogo = AssetLogo.Icon(assetId: asset.iconLogo.assetId,
                                          name: asset.iconLogo.name,
                                          url: asset.iconLogo.url,
                                          isSponsored: false,
                                          hasScript: asset.iconLogo.hasScript)
            return AssetViewModel(id: wavesId,
                                  name: asset.name,
                                  decimals: Int32(asset.precision),
                                  icon: iconLogo,
                                  iconStyle: .large)
        }
    }
}
