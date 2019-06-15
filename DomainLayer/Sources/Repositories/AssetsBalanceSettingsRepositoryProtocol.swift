//
//  AssetsBalanceSettingsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

enum RepositoryError: Error {
    case fail
    case notFound
}

extension Float {
    var notFound: Float {
        return -1
    }
}

protocol AssetsBalanceSettingsRepositoryProtocol {
    func settings(by accountAddress: String, ids: [String]) -> Observable<[String: DomainLayer.DTO.AssetBalanceSettings]>
    func settings(by accountAddress: String) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]>
    func listenerSettings(by accountAddress: String, ids: [String]) -> Observable<[DomainLayer.DTO.AssetBalanceSettings]>
    func saveSettings(by accountAddress: String, settings: [DomainLayer.DTO.AssetBalanceSettings]) -> Observable<Bool>
    func removeBalancesSettting(actualIds: [String], accountAddress: String) -> Observable<Bool>
}
