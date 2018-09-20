//
//  DexCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexCoordinator {
    
    private lazy var dexListViewContoller: UIViewController = {
        return DexListModuleBuilder(output: self).build()
    }()

    private var navigationController: UINavigationController!

    func start(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.pushViewController(dexListViewContoller, animated: false)
    }
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let amountAsset = Dex.DTO.Asset(id: "WAVES", name: "WAVES", decimals: 8)
            let priceAsset = Dex.DTO.Asset(id: "BTC", name: "BTC", decimals: 8)

            self.showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: .sell,
                                           price: nil, ask: nil, bid: nil, last: nil,
                availableAmountAssetBalance: Money(0, 0),
                availablePriceAssetBalance: Money(0, 0))
        }
    }
}


//MARK: - DexListModuleOutput, DexMarketModuleOutput, DexTraderContainerModuleOutput
extension DexCoordinator: DexListModuleOutput, DexMarketModuleOutput, DexTraderContainerModuleOutput {
    
    func showDexSort() {
        let vc = DexSortModuleBuilder().build()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAddList() {
        let vc = DexMarketModuleBuilder(output: self).build()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showTradePairInfo(pair: DexTraderContainer.DTO.Pair) {

        let vc = DexTraderContainerModuleBuilder(output: self, orderBookOutput: self, lastTradesOutput: self).build(input: pair)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showInfo(pair: DexInfoPair.DTO.Pair) {
        
        let controller = DexInfoModuleBuilder().build(input: pair)
        let popup = PopupViewController()
        popup.contentHeight = 300
        popup.present(contentViewController: controller)
    }
}

//MARK: - DexLastTradesModuleOutput
extension DexCoordinator: DexLastTradesModuleOutput {
    
    func didCreateOrder(_ trade: DexLastTrades.DTO.SellBuyTrade, amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, availableAmountAssetBalance: Money, availablePriceAssetBalance: Money) {
        
        let type: DexCreateOrder.DTO.OrderType = trade.type == .sell ? .sell : .buy
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                  price: trade.price, ask: nil, bid: nil, last: nil,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance)
    }
    
    func didCreateEmptyOrder(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, orderType: DexLastTrades.DTO.TradeType, availableAmountAssetBalance: Money, availablePriceAssetBalance: Money) {
        
        let type: DexCreateOrder.DTO.OrderType = orderType == .sell ? .sell : .buy

        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                  price: nil, ask: nil, bid: nil, last: nil,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance)
        
    }
}

//MARK: - DexOrderBookModuleOutput
extension DexCoordinator:  DexOrderBookModuleOutput {
    
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk, amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, ask: Money?, bid: Money?, last: Money?, availableAmountAssetBalance: Money, availablePriceAssetBalance: Money) {
        
        let type: DexCreateOrder.DTO.OrderType = bidAsk.orderType == .sell ? .sell : .buy
        
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                  price: bidAsk.price, ask: ask, bid: bid, last: last,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance)

    }
    
    
    func didCreateEmptyOrder(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, orderType: DexOrderBook.DTO.OrderType, ask: Money?, bid: Money?, last: Money?, availableAmountAssetBalance: Money, availablePriceAssetBalance: Money) {
        
        let type: DexCreateOrder.DTO.OrderType = orderType == .sell ? .sell : .buy

        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                  price: nil, ask: ask, bid: bid, last: last,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance)
        
    }
}

//MARK: - CreateOrderController
private extension DexCoordinator {
    
    func showCreateOrderController(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, type: DexCreateOrder.DTO.OrderType,
                                   price: Money?, ask: Money?, bid: Money?, last: Money?,
                                   availableAmountAssetBalance: Money, availablePriceAssetBalance: Money) {
        
        let input = DexCreateOrder.DTO.Input(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                             price: price, ask: ask, bid: bid, last: last,
                                             availableAmountAssetBalance: availableAmountAssetBalance,
                                             availablePriceAssetBalance: availablePriceAssetBalance)
       
        let controller = DexCreateOrderModuleBuilder().build(input: input)
        let popup = PopupViewController()
        popup.present(contentViewController: controller)
    }
}
