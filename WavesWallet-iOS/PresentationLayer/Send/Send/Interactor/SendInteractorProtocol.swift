//
//  SendInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol SendInteractorProtocol {
    
    func gateWayInfo(asset: DomainLayer.DTO.AssetBalance) -> Observable<Response<Send.DTO.GatewayInfo>>
}
