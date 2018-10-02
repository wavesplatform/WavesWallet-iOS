//
//  File.swift
//  WavesWallet-iOS
//
//  Created by Mac on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol HistoryModuleOutput: class {
    func showTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int)
}
