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
    
    func getWavesBalance() -> Observable<DomainLayer.DTO.AssetBalance>
    func gateWayInfo(asset: DomainLayer.DTO.AssetBalance, address: String) -> Observable<ResponseType<Send.DTO.GatewayInfo>>
    func validateAlis(alias: String) -> Observable<Bool>
    func send(fee: Money, recipient: String, assetId: String, amount: Money, attachment: String, isAlias: Bool) -> Observable<Send.TransactionStatus>
}
