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
    
    func didCreateOrder(_ trade: DexLastTrades.DTO.SellBuyTrade, priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset) {
        
        let type: DexCreateOrder.DTO.OrderType = trade.type == .sell ? .sell : .buy
        showCreateOrderController(priceAsset: priceAsset, amountAsset: amountAsset, type: type, price: trade.price)

    }
    
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk, priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset) {
        
        let type: DexCreateOrder.DTO.OrderType = bidAsk.orderType == .sell ? .sell : .buy
        showCreateOrderController(priceAsset: priceAsset, amountAsset: amountAsset, type: type, price: bidAsk.price)
    }
    
    func didCreateOrderSellEmpty(priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset) {
        
        let price = Money(0, 0)
        showCreateOrderController(priceAsset: priceAsset, amountAsset: amountAsset, type: .sell, price: price)
    }
    
    func didCreateOrderBuyEmpty(priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset) {
        let price = Money(0, 0)
        showCreateOrderController(priceAsset: priceAsset, amountAsset: amountAsset, type: .buy, price: price)
    }
}

//MARK: - CreateOrderController
private extension DexCoordinator {
    
    func showCreateOrderController(priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset, type: DexCreateOrder.DTO.OrderType, price: Money) {
        
        let input = DexCreateOrder.DTO.Input(priceAsset: priceAsset, amountAsset: amountAsset, type: type, price: price)
       
        let controller = DexCreateOrderModuleBuilder().build(input: input)
        let popup = PopupViewController()
        popup.present(contentViewController: controller)
    }
}
