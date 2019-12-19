//
//  SendInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Extensions
import DomainLayer

protocol SendInteractorProtocol {
    
    func assetBalance(by assetID: String) -> Observable<DomainLayer.DTO.SmartAssetBalance?>
    func getWavesBalance() -> Observable<DomainLayer.DTO.SmartAssetBalance>
    func gateWayInfo(asset: DomainLayer.DTO.SmartAssetBalance, address: String) -> Observable<ResponseType<Send.DTO.GatewayInfo>>
    func validateAlis(alias: String) -> Observable<Bool>
    func send(fee: Money, recipient: String, asset: DomainLayer.DTO.Asset, amount: Money, attachment: String, feeAssetID: String, isGatewayTransaction: Bool) -> Observable<Send.TransactionStatus>
    func calculateFee(assetID: String) -> Observable<Money>
    func getDecimalsForAsset(assetID: String) -> Observable<Int>
}
