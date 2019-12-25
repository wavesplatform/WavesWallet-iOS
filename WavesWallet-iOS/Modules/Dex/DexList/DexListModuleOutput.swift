//
//  DexModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

protocol DexListModuleOutput: AnyObject {
 
    func showDexSort(delegate: DexListRefreshOutput)
    func showAddList(delegate: DexListRefreshOutput)
    func showTradePairInfo(pair: DexTraderContainer.DTO.Pair)
    func showOrders()
}

protocol DexListRefreshOutput: AnyObject {
    func refreshPairs()
    func sortPairs()
}
