//
//  File.swift
//  WavesWallet-iOS
//
//  Created by Mac on 07/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer

protocol HistoryModuleOutput: class {
    func showTransaction(transaction: DomainLayer.DTO.SmartTransaction)
}
