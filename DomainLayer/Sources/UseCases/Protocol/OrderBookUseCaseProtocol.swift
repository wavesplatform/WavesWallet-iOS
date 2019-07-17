//
//  OrderBookUseCaseProtocol.swift
//  InternalDomainLayer
//
//  Created by Pavel Gubin on 08.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol OrderBookUseCaseProtocol {
    func orderSettingsFee() -> Observable<DomainLayer.DTO.Dex.SmartSettingsOrderFee>
}
