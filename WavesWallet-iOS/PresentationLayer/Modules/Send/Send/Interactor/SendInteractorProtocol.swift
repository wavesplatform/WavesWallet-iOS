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
    
    func assetBalance(by assetID: String) -> Observable<DomainLayer.DTO.SmartAssetBalance?>
    func getWavesBalance() -> Observable<DomainLayer.DTO.SmartAssetBalance>
    func generateMoneroAddress(asset: DomainLayer.DTO.SmartAssetBalance, address: String, paymentID: String) -> Observable<ResponseType<String>>
    func gateWayInfo(asset: DomainLayer.DTO.SmartAssetBalance, address: String) -> Observable<ResponseType<Send.DTO.GatewayInfo>>
    func validateAlis(alias: String) -> Observable<Bool>
    func send(fee: Money, recipient: String, assetId: String, amount: Money, attachment: String, isAlias: Bool) -> Observable<Send.TransactionStatus>
}
