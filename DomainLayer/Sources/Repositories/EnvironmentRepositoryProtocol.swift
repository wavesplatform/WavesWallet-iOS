//
//  EnvironmentsInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions
import Extensions

public enum EnvironmentRepositoryError: Error {
    case invalidURL
    case invalidResponse
}

public protocol ApplicationEnvironmentProtocol {
    var walletEnvironment: WalletEnvironment { get }
    var timestampServerDiff: Int64 { get }
}

public protocol EnvironmentRepositoryProtocol {
    
    func applicationEnvironment() -> Observable<ApplicationEnvironmentProtocol>
    
    func walletEnvironment() -> Observable<WalletEnvironment>
    func deffaultEnvironment() -> Observable<WalletEnvironment>
}
