//
//  DexCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import RxSwift
import UIKit
import WavesSDKExtensions

private enum Constants {
    static let dexInfoPopupHeight: CGFloat = 300
}

private struct SettingsScriptPair: TSUD, Codable, Mutating {
    private static let key: String = "com.waves.scriptedPairMessage.settings"

    private var showIdPairSet: Set<String> = Set<String>()

    init(showIdPairSet: Set<String>) {
        self.showIdPairSet = showIdPairSet
    }

    init() {
        showIdPairSet = .init()
    }

    static var defaultValue: SettingsScriptPair {
        return SettingsScriptPair(showIdPairSet: .init())
    }

    static var stringKey: String {
        return key
    }

    static func contain(amountAsset: String, priceAsset: String, address: String) -> Bool {
        let key = SettingsScriptPair.pairKey(amountAsset: amountAsset,
                                             priceAsset: priceAsset,
                                             address: address)
        return SettingsScriptPair.get().showIdPairSet.contains(key)
    }

    static func save(amountAsset: String, priceAsset: String, address: String, dotNotShow: Bool) {
        var settingPair = SettingsScriptPair.get()
        let key = SettingsScriptPair.pairKey(amountAsset: amountAsset,
                                             priceAsset: priceAsset,
                                             address: address)

        if dotNotShow {
            settingPair.showIdPairSet.insert(key)
        } else {
            settingPair.showIdPairSet.remove(key)
        }

        SettingsScriptPair.set(settingPair)
    }

    private static func pairKey(amountAsset: String, priceAsset: String, address: String) -> String {
        amountAsset + priceAsset + address
    }
}

class TradeCoordinator: Coordinator {
    private let auth = UseCasesFactory.instance.authorization
    private let dispose = DisposeBag()

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private let disposeBag = DisposeBag()

    private lazy var dexCreateOrderPopup = PopupViewController()
    private lazy var dexCreateOrderInfoPopup = PopupViewController()

    private var navigationRouter: NavigationRouter

    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning(dismiss: nil)

    private var selectedAsset: DomainLayer.DTO.Asset?

    init(navigationRouter: NavigationRouter, selectedAsset: DomainLayer.DTO.Asset? = nil) {
        self.navigationRouter = navigationRouter
        self.selectedAsset = selectedAsset
    }

    func start() {
        let tradeVc = TradeModuleBuilder(output: self).build(input: selectedAsset?.dexAsset)
        navigationRouter.pushViewController(tradeVc)

        // if selectedAsset != nil, we show Trade from AssetDetail screen and we not need setup toast
        if selectedAsset == nil {
            setupBackupTost(target: tradeVc, navigationRouter: navigationRouter, disposeBag: disposeBag)
        }
    }

    private var containerControllers: [UIViewController] {
        for controller in navigationRouter.navigationController.viewControllers {
            if let vc = controller as? DexTraderContainerViewController {
                return vc.controllers
            }
        }
        return []
    }
}

// MARK: - TradeModuleOutput

extension TradeCoordinator: TradeModuleOutput { 
    
    func showPairLocked(pair: DexTraderContainer.DTO.Pair) {
        
        let titleValue = Localizable.Waves.Trade.Message.Pairlocked.title(pair.amountAsset.shortName,
                                                                          pair.priceAsset.shortName)
        let subTitleValue = Localizable.Waves.Trade.Message.Pairlocked.subtitle
        let buttonTitle = Localizable.Waves.Trade.Message.Pairlocked.Button.ok
        let image = Images.bigwarning48.image
                
        let news = AppNewsView.show(model: AppNewsView.Model(title: titleValue,
                                                             subtitle: subTitleValue,
                                                             image: image,
                                                             buttonTitle: buttonTitle))
        news.tapDismiss = { [weak news] in
            news?.dismiss()
        }
    }
    
    func showTradePairInfo(pair: DexTraderContainer.DTO.Pair) {
        let vc = DexTraderContainerModuleBuilder(output: self,
                                                 orderBookOutput: self,
                                                 lastTradesOutput: self,
                                                 myOrdersOutpout: self).build(input: pair)
        navigationRouter.pushViewController(vc)
    }

    func searchTapped(selectedAsset: DomainLayer.DTO.Dex.Asset?, delegate: TradeRefreshOutput) {
        let vc = DexMarketModuleBuilder(output: delegate).build(input: selectedAsset)
        navigationRouter.pushViewController(vc)
    }

    func myOrdersTapped() {
        let vc = MyOrdersModuleBuilder().build()
        navigationRouter.pushViewController(vc)
    }

    func tradeDidDissapear() {
        removeFromParentCoordinator()
    }
}

// MARK: - DexTraderContainerModuleOutput

extension TradeCoordinator: DexTraderContainerModuleOutput {
    
    func showInfo(pair: DexInfoPair.DTO.Pair) {
        let controller = DexInfoModuleBuilder().build(input: pair)
        let popup = PopupViewController()
        popup.contentHeight = Constants.dexInfoPopupHeight
        popup.present(contentViewController: controller)
    }
}

// MARK: - DexLastTradesModuleOutput

extension TradeCoordinator: DexLastTradesModuleOutput {
    func didCreateOrder(_ trade: DexLastTrades.DTO.SellBuyTrade,
                        amountAsset: DomainLayer.DTO.Dex.Asset,
                        priceAsset: DomainLayer.DTO.Dex.Asset,
                        availableAmountAssetBalance: Money,
                        availablePriceAssetBalance: Money,
                        availableBalances: [DomainLayer.DTO.SmartAssetBalance],
                        scriptedAssets: [DomainLayer.DTO.Asset]) {
        
        showCreateOrderController(amountAsset: amountAsset,
                                  priceAsset: priceAsset,
                                  type: trade.type,
                                  price: trade.price,
                                  ask: nil,
                                  bid: nil,
                                  last: nil,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance,
                                  availableBalances: availableBalances,
                                  scriptedAssets: scriptedAssets,
                                  sum: nil)
    }

    func didCreateEmptyOrder(amountAsset: DomainLayer.DTO.Dex.Asset,
                             priceAsset: DomainLayer.DTO.Dex.Asset,
                             orderType: DomainLayer.DTO.Dex.OrderType,
                             availableAmountAssetBalance: Money,
                             availablePriceAssetBalance: Money,
                             availableBalances: [DomainLayer.DTO.SmartAssetBalance],
                             scriptedAssets: [DomainLayer.DTO.Asset]) {
        
        showCreateOrderController(amountAsset: amountAsset,
                                  priceAsset: priceAsset,
                                  type: orderType,
                                  price: nil,
                                  ask: nil,
                                  bid: nil,
                                  last: nil,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance,
                                  availableBalances: availableBalances,
                                  scriptedAssets: scriptedAssets,
                                  sum: nil)
    }
}

// MARK: - DexOrderBookModuleOutput

extension TradeCoordinator: DexOrderBookModuleOutput {
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk,
                        amountAsset: DomainLayer.DTO.Dex.Asset,
                        priceAsset: DomainLayer.DTO.Dex.Asset,
                        ask: Money?,
                        bid: Money?,
                        last: Money?,
                        availableAmountAssetBalance: Money,
                        availablePriceAssetBalance: Money,
                        availableBalances: [DomainLayer.DTO.SmartAssetBalance],
                        inputMaxSum: Bool,
                        scriptedAssets: [DomainLayer.DTO.Asset]) {
        let sum = inputMaxSum ? bidAsk.sum : nil
        
        showCreateOrderController(amountAsset: amountAsset,
                                  priceAsset: priceAsset,
                                  type: bidAsk.orderType,
                                  price: bidAsk.price,
                                  ask: ask,
                                  bid: bid,
                                  last: last,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance,
                                  availableBalances: availableBalances,
                                  scriptedAssets: scriptedAssets,
                                  sum: sum)
    }

    func didCreateEmptyOrder(amountAsset: DomainLayer.DTO.Dex.Asset,
                             priceAsset: DomainLayer.DTO.Dex.Asset,
                             orderType: DomainLayer.DTO.Dex.OrderType,
                             ask: Money?,
                             bid: Money?,
                             last: Money?,
                             availableAmountAssetBalance: Money,
                             availablePriceAssetBalance: Money,
                             availableBalances: [DomainLayer.DTO.SmartAssetBalance],
                             scriptedAssets: [DomainLayer.DTO.Asset]) {
        
        showCreateOrderController(amountAsset: amountAsset,
                                  priceAsset: priceAsset,
                                  type: orderType,
                                  price: nil,
                                  ask: ask,
                                  bid: bid,
                                  last: last,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance,
                                  availableBalances: availableBalances,
                                  scriptedAssets: scriptedAssets,
                                  sum: nil)
    }
}

// MARK: - CreateOrderController

private extension TradeCoordinator {
    func showCreateOrderController(amountAsset: DomainLayer.DTO.Dex.Asset,
                                   priceAsset: DomainLayer.DTO.Dex.Asset,
                                   type: DomainLayer.DTO.Dex.OrderType,
                                   price: Money?, ask: Money?, bid: Money?, last: Money?,
                                   availableAmountAssetBalance: Money,
                                   availablePriceAssetBalance: Money,
                                   availableBalances: [DomainLayer.DTO.SmartAssetBalance],
                                   scriptedAssets: [DomainLayer.DTO.Asset],
                                   sum: Money?) {
        var lastPrice: Money?
        if let last = last, last.amount > 0 {
            lastPrice = last
        }

        let input = DexCreateOrder.DTO.Input(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                             price: price, sum: sum, ask: ask, bid: bid, last: lastPrice,
                                             availableAmountAssetBalance: availableAmountAssetBalance,
                                             availablePriceAssetBalance: availablePriceAssetBalance,
                                             availableBalances: availableBalances)
        auth.authorizedWallet()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] wallet in
                guard let self = self else { return }

                let settingScriptPairContainsAmountPriceAssetAndAddress = SettingsScriptPair.contain(amountAsset: amountAsset.id,
                                                                                                     priceAsset: priceAsset.id,
                                                                                                     address: wallet.address)
                if !scriptedAssets.isEmpty, !settingScriptPairContainsAmountPriceAssetAndAddress {
                    let actionContinue = { [weak self] in
                        guard let self = self else { return }

                        let viewController = DexCreateOrderModuleBuilder(output: self).build(input: input)
                        if let controller = viewController as? DexCreateOrderViewController {
                            self.dexCreateOrderPopup.onDismiss = {
                                controller.removeTimer()
                            }
                            self.dexCreateOrderPopup.present(contentViewController: controller)
                        }
                    }

                    let vc = DexScriptAssetMessageModuleBuilder(output: self).build(input: .init(assets: scriptedAssets,
                                                                                                 amountAsset: amountAsset.id,
                                                                                                 priceAsset: priceAsset.id,
                                                                                                 continueAction: actionContinue))
                    let popup = PopupViewController()
                    popup.present(contentViewController: vc)
                } else {
                    let viewController = DexCreateOrderModuleBuilder(output: self).build(input: input)
                    if let controller = viewController as? DexCreateOrderViewController {
                        self.dexCreateOrderPopup.onDismiss = {
                            controller.removeTimer()
                        }
                        self.dexCreateOrderPopup.present(contentViewController: controller)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - DexCreateOrderModuleOutput

extension TradeCoordinator: DexCreateOrderModuleOutput {
    func dexCreateOrderDidDismisAlert() {
        dexCreateOrderPopup.dismiss(animated: true, completion: nil)
    }

    func dexCreateOrderDidPresentAlert(_ alert: UIViewController) {
        alert.modalPresentationStyle = .custom
        alert.transitioningDelegate = popoverViewControllerTransitioning
        dexCreateOrderPopup.present(alert, animated: true) {}
    }

    func dexCreatOrderDidTapMarketTypeInfo() {
        if let vc = DexCreateOrderInfoModuleBuilder(output: self).build() as? DexCreateOrderInfoViewController {
            dexCreateOrderInfoPopup.contentHeight = vc.calculateHeight()
            dexCreateOrderInfoPopup.present(contentViewController: vc)
        }
    }

    func dexCreateOrderWarningForPrice(isPriceHigherMarket: Bool, callback: @escaping ((_ isSuccess: Bool) -> Void)) {
        let priceView = DexCreateOrderInvalidPriceView
            .show(model: .init(pricePercent: UIGlobalConstants.limitPriceOrderPercent,
                               isPriceHigherMarket: isPriceHigherMarket))

        priceView.buttonDidTap = { isSuccess in
            callback(isSuccess)
        }
    }

    func dexCreateOrderDidCreate(output: DexCreateOrder.DTO.Output) {
        dexCreateOrderPopup.dismissPopup()

        let controller = DexCompleteOrderModuleBuilder().build(input: output)
        navigationRouter.pushViewController(controller)

        for controller in containerControllers {
            if let vc = controller as? DexCreateOrderProtocol {
                vc.updateCreatedOrders()
            }
        }
    }
}

// MARK: - DexMyOrdersModuleOutput

extension TradeCoordinator: DexMyOrdersModuleOutput {
    func myOrderDidCancel() {
        for controller in containerControllers {
            if let vc = controller as? DexCancelOrderProtocol {
                vc.updateCanceledOrders()
            }
        }
    }
}

// MARK: - DexScriptAssetMessageModuleOutput

extension TradeCoordinator: DexScriptAssetMessageModuleOutput {
    func dexScriptAssetMessageModuleOutputDidTapCheckmark(amountAsset: String, priceAsset: String, doNotShow: Bool) {
        auth.authorizedWallet()
            .subscribe(onNext: { wallet in
                SettingsScriptPair.save(amountAsset: amountAsset,
                                        priceAsset: priceAsset,
                                        address: wallet.address,
                                        dotNotShow: doNotShow)

            }).disposed(by: disposeBag)
    }
}

// MARK: - DexCreateOrderInfoModuleBuilderOutput

extension TradeCoordinator: DexCreateOrderInfoModuleBuilderOutput {
    func dexCreateOrderInfoDidTapClose() {
        dexCreateOrderInfoPopup.dismissPopup()
    }
}
