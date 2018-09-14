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
                                           price: nil, ask: nil, bid: nil, last: nil)
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

//MARK: - DexLastTradesModuleOutput, DexOrderBookModuleOutput
extension DexCoordinator: DexLastTradesModuleOutput, DexOrderBookModuleOutput {
    
    func didCreateOrder(_ trade: DexLastTrades.DTO.SellBuyTrade, amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset) {
        
        let type: DexCreateOrder.DTO.OrderType = trade.type == .sell ? .sell : .buy
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                  price: trade.price, ask: nil, bid: nil, last: nil)
    }
    
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk, amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, ask: Money?, bid: Money?, last: Money?) {
        let type: DexCreateOrder.DTO.OrderType = bidAsk.orderType == .sell ? .sell : .buy
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                  price: bidAsk.price, ask: ask, bid: bid, last: last)
    }
    
    func didCreateOrderBuyEmpty(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, ask: Money?, bid: Money?, last: Money?) {
        
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: .sell,
                                  price: nil, ask: ask, bid: bid, last: last)
    }
    
    func didCreateOrderSellEmpty(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, ask: Money?, bid: Money?, last: Money?) {
       
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: .sell,
                                  price: nil, ask: ask, bid: bid, last: last)
    }
    
    func didCreateOrderSellEmpty(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset) {
        
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: .sell,
                                  price: nil, ask: nil, bid: nil, last: nil)
    }
    
    func didCreateOrderBuyEmpty(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset) {
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: .buy,
                                  price: nil, ask: nil, bid: nil, last: nil)
    }
}

//MARK: - CreateOrderController
private extension DexCoordinator {
    
    func showCreateOrderController(amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, type: DexCreateOrder.DTO.OrderType,
                                   price: Money?, ask: Money?, bid: Money?, last: Money?) {
        
        let input = DexCreateOrder.DTO.Input(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                             price: price, ask: ask, bid: bid, last: last)
       
        let controller = DexCreateOrderModuleBuilder().build(input: input)
        let popup = PopupViewController()
        popup.present(contentViewController: controller)
    }
}
