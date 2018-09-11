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

extension DexCoordinator: DexOrderBookModuleOutput, DexLastTradesModuleOutput {
    
    func didTapEmptyBuy() {
        let input = DexCreateOrder.DTO.Input(type: .buy, price: Money(0, 0))
        showSellBuyController(input)
    }
    
    func didTapEmptySell() {
        let input = DexCreateOrder.DTO.Input(type: .sell, price: Money(0, 0))
        showSellBuyController(input)
    }
    
    func didTapBuy(_ bid: DexOrderBook.DTO.BidAsk) {
        let type: DexCreateOrder.DTO.OrderType = bid.orderType == .sell ? .sell : .buy
        let input = DexCreateOrder.DTO.Input(type: type, price: bid.price)
        showSellBuyController(input)
    }

    func didTapSell(_ ask: DexOrderBook.DTO.BidAsk) {
        let type: DexCreateOrder.DTO.OrderType = ask.orderType == .sell ? .sell : .buy
        let input = DexCreateOrder.DTO.Input(type: type, price: ask.price)
        showSellBuyController(input)
    }

    func didTapSellBuy(_ trade: DexLastTrades.DTO.SellBuyTrade) {
     
        let type: DexCreateOrder.DTO.OrderType = trade.type == .sell ? .sell : .buy
        let input = DexCreateOrder.DTO.Input(type: type, price: trade.price)
        showSellBuyController(input)
    }
    
    private func showSellBuyController(_ input: DexCreateOrder.DTO.Input) {
        let controller = DexCreateOrderModuleBuilder().build(input: input)
        let popup = PopupViewController()
        popup.present(contentViewController: controller)
    }
}
