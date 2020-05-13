//
//  AssetsBalanceSettingsRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/02/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public enum RepositoryError: Error {
    case fail
    case notFound
}

public extension Float {
    var notFound: Float {
        return -1
    }
}

public protocol AssetsBalanceSettingsRepositoryProtocol {
    func settings(by accountAddress: String, ids: [String]) -> Observable<[String: AssetBalanceSettings]>
    func settings(by accountAddress: String) -> Observable<[AssetBalanceSettings]>
    func listenerSettings(by accountAddress: String, ids: [String]) -> Observable<[AssetBalanceSettings]>
    func saveSettings(by accountAddress: String, settings: [AssetBalanceSettings]) -> Observable<Bool>
    func removeBalancesSettting(actualIds: [String], accountAddress: String) -> Observable<Bool>
}
