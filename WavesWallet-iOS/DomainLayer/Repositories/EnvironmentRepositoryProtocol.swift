//
//  EnvironmentsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtension


enum EnvironmentRepositoryError: Error {
    case invalidURL
    case invalidResponse
}

protocol ApplicationEnvironmentProtocol {
    var walletEnvironment: WalletEnvironment { get }
    var timestampServerDiff: Int64 { get }
}

protocol EnvironmentRepositoryProtocol {
    
    func applicationEnvironment() -> Observable<ApplicationEnvironmentProtocol>
    
    func accountEnvironment(accountAddress: String) -> Observable<WalletEnvironment>
    func deffaultEnvironment(accountAddress: String) -> Observable<WalletEnvironment>
    func setSpamURL(_ url: String, by accountAddress: String) -> Observable<Bool>
}
