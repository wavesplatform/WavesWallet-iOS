//
//  DexMarketOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexMarketModuleOutput: AnyObject {
    func showInfo(pair: DexInfoPair.DTO.Pair)
}
