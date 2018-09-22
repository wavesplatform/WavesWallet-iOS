//
//  DexCreateOrderModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol DexCreateOrderModuleOutput: AnyObject {
    func dexCreateOrderDidCreate(output: DexCreateOrder.DTO.Output)
}
