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

extension DexCoordinator: DexListModuleOutput, DexMarketModuleOutput {
    
    func showDexSort() {
        let vc = DexSortModuleBuilder().build()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAddList() {
        let vc = DexMarketModuleBuilder(output: self).build()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showTradePairInfo(pair: DexTraderContainer.DTO.Pair) {
        let vc = DexTraderContainerModuleBuilder().build(input: pair)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showInfo(pair: DexInfoPair.DTO.Pair) {
        
        let controller = DexInfoModuleBuilder().build(input: pair)
        let popup = PopupViewController()
        popup.contentHeight = 300
        popup.present(contentViewController: controller)

    }
}
