//
//  StartLeasingInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions
import DomainLayer

protocol StartLeasingInteractorProtocol {
    func createOrder(order: StartLeasingTypes.DTO.Order) -> Observable<DomainLayer.DTO.SmartTransaction>
    func getFee() -> Observable<Money>
}
