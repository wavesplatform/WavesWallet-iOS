//
//  TradeCategoriesConfigRepositoryProtocol.swift
//  DomainLayer
//
//  Created by Pavel Gubin on 16.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import Foundation
import RxSwift

public protocol TradeCategoriesConfigRepositoryProtocol {
    
    func tradeCagegories(serverEnvironment: ServerEnvironment,
                         accountAddress: String) -> Observable<[DomainLayer.DTO.TradeCategory]>
}
