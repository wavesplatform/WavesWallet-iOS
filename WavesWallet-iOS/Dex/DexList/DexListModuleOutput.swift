//
//  DexModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexListModuleOutput: AnyObject {
 
    func showDexSort()
    func showAddList()
    func showTradePairInfo(pair: DexTraderContainer.DTO.Pair)
}
