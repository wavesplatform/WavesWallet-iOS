//
//  StakingBalanceService.swift
//  DomainLayer
//
//  Created by vvisotskiy on 25.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import RxSwift
import WavesSDK

public struct AvailableStakingBalance {
    
    public let balance: Int64
    
    public let assetTicker: String?
    
    public let precision: Int
    
    public let logoUrl: String?
    
    public let assetLogo: AssetLogo.Icon?
    
    public init(balance: Int64, assetTicker: String?, precision: Int, logoUrl: String?, assetLogo: AssetLogo.Icon?) {
        self.balance = balance
        self.assetTicker = assetTicker
        self.precision = precision
        self.logoUrl = logoUrl
        self.assetLogo = assetLogo
    }
}

public struct TotalStakingBalance {
    
    public let availbleBalance: Int64
    
    public let depositeBalance: Int64
    
    public var totalBalance: Int64 {
        availbleBalance + depositeBalance
    }
    
    public let assetTicker: String?
    
    public let precision: Int
    
    public let logoUrl: String?
    
    public let assetLogo: AssetLogo.Icon?
    
    public init(availbleBalance: Int64,
                depositeBalance: Int64,
                assetTicker: String?,
                precision: Int,
                logoUrl: String?,
                assetLogo: AssetLogo.Icon?) {
        self.availbleBalance = availbleBalance
        self.depositeBalance = depositeBalance
        self.assetTicker = assetTicker
        self.precision = precision
        self.logoUrl = logoUrl
        self.assetLogo = assetLogo
    }
}

public protocol StakingBalanceService: AnyObject {
    /// Доступный баланс получаем с текущего адреса пользователя
    func getAvailableStakingBalance() -> Observable<AvailableStakingBalance>
    
    /// Общий баланс = доступный баланс на адресе + баланс в депозите (метод выполняет 2 запроса)
    func totalStakingBalance() -> Observable<TotalStakingBalance>
    
    /// Баланс на депозите
    func getDepositeStakingBalance() -> Observable<NodeService.DTO.AddressesData>
}
