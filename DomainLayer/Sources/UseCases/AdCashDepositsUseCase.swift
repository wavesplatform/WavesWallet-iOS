//
//  ACashDepositsUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 25.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import WavesSDK
import RxSwift


public protocol AdCashDepositsUseCaseProtocol {
    
    func requirementsOrder(assetId: String) -> Observable<DomainLayer.DTO.AdCashDeposits.RequirementsOrder>
    
    func createOrder(assetId: String, amount: Money) -> Observable<DomainLayer.DTO.AdCashDeposits.Order>
}

extension DomainLayer.DTO {
    public enum AdCashDeposits {}
}

extension DomainLayer.DTO.AdCashDeposits {
    
    public struct RequirementsOrder {
        
        public var amountMin: Money
        public var amountMax: Money
        
        public init(amountMin: Money,
                    amountMax: Money) {
            self.amountMin = amountMin
            self.amountMax = amountMax
        }
    }
    
    public struct Order {
        
        public var url: URL
        
        public init(url: URL) {
            self.url = url
        }
    }
}

private enum Constants {
    static let ACUSD = "AC_USD"
    static let ACUSDDECIMALS = 2
}

final class ACashDepositsUseCase: AdCashDepositsUseCaseProtocol {
    
    private let gatewayRepository: WEGatewayRepositoryProtocol
    private let oAuthRepository: WEOAuthRepositoryProtocol
    private let authorizationUseCase: AuthorizationUseCaseProtocol
    private let assetsUseCase: AssetsUseCaseProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentRepository
    
    init(gatewayRepository: WEGatewayRepositoryProtocol,
         oAuthRepository: WEOAuthRepositoryProtocol,
         authorizationUseCase: AuthorizationUseCaseProtocol,
         assetsUseCase: AssetsUseCaseProtocol,
         serverEnvironmentUseCase: ServerEnvironmentRepository) {
        self.gatewayRepository = gatewayRepository
        self.oAuthRepository = oAuthRepository
        self.authorizationUseCase = authorizationUseCase
        self.assetsUseCase = assetsUseCase
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }
    
    func requirementsOrder(assetId: String) -> Observable<DomainLayer.DTO.AdCashDeposits.RequirementsOrder> {
        
        let serverEnvironment = self.serverEnvironmentUseCase.serverEnvironment()
        let wallet = authorizationUseCase.authorizedWallet()
        
        return Observable.zip(wallet, serverEnvironment)
            .flatMap { [weak self] signedWallet, serverEnvironment -> Observable<DomainLayer.DTO.AdCashDeposits.RequirementsOrder> in
                
                guard let self = self else { return Observable.never() }
                
                let oauthToken = self.oAuthRepository.oauthToken(signedWallet: signedWallet)
                
                return oauthToken
                    .flatMap { [weak self] token -> Observable<DomainLayer.DTO.AdCashDeposits.RequirementsOrder> in
                        
                        guard let self = self else { return Observable.never() }
                        
                        let assets = self.assetsUseCase
                            .assets(by: [assetId],
                                    accountAddress: signedWallet.address)
                            .flatMap { assets -> Observable<Asset> in
                                guard let asset = assets.first(where: { $0.id == assetId }) else {
                                    return Observable.error(NetworkError.notFound)
                                }
                                return Observable.just(asset)
                        }
                        
                        let transferBinding = self
                            .gatewayRepository
                            .transferBinding(serverEnvironment: serverEnvironment,
                                             request: .init(senderAsset: DomainLayerConstants.acUSDId,
                                                            recipientAsset: assetId,
                                                            recipientAddress: signedWallet.address,
                                                            token: token))
                        
                        
                        
                        return Observable
                            .zip(transferBinding, assets)
                            .map { (transferBinding, asset) -> DomainLayer.DTO.AdCashDeposits.RequirementsOrder in
                                
                                // Precision converting to USD -> USDN
                                let converPrecision = asset.precision - Constants.ACUSDDECIMALS
                                
                                let min = transferBinding.amountMin * pow(10, converPrecision).int64Value
                                let max = transferBinding.amountMax * pow(10, converPrecision).int64Value
                                
                                let amounMin =  Money(min, asset.precision)
                                let amounMax =  Money(max, asset.precision)
                                
                                let binding: DomainLayer.DTO.AdCashDeposits.RequirementsOrder = .init(amountMin: amounMin,
                                                                                                      amountMax: amounMax)
                                
                                return binding
                        }
                }
                .catchError { (error) -> Observable<DomainLayer.DTO.AdCashDeposits.RequirementsOrder> in
                    return Observable.error(NetworkError.error(by: error))
                }
        }
    }
    
    func createOrder(assetId: String, amount: Money) -> Observable<DomainLayer.DTO.AdCashDeposits.Order> {
        
        let serverEnvironment = self
                          .serverEnvironmentUseCase
                          .serverEnvironment()
        let wallet = authorizationUseCase.authorizedWallet()
        
        return Observable.zip(wallet, serverEnvironment)
            .flatMap { [weak self] signedWallet, serverEnvironment -> Observable<DomainLayer.DTO.AdCashDeposits.Order> in
                
                guard let self = self else { return Observable.never() }
                                                
                let oauthToken = self
                    .oAuthRepository
                    .oauthToken(signedWallet: signedWallet)
                
                return oauthToken
                    .flatMap { [weak self] token -> Observable<(DomainLayer.DTO.WEGateway.TransferBinding,
                        WEOAuthTokenDTO, ServerEnvironment)> in
                        
                        guard let self = self else { return Observable.never() }
                        
                        let transferBinding = self.gatewayRepository
                            .transferBinding(serverEnvironment: serverEnvironment,
                                             request: .init(senderAsset: Constants.ACUSD,
                                                            recipientAsset: assetId,
                                                            recipientAddress: signedWallet.address,
                                                            token: token))
                        
                        return Observable.zip(transferBinding,
                                              Observable.just(token),
                                              Observable.just(serverEnvironment))
                }
                .flatMap { transferBinding, token, serverEnviroment -> Observable<DomainLayer.DTO.AdCashDeposits.Order> in
                    
                    guard let address = transferBinding
                        .addresses
                        .first else { return Observable.error(NetworkError.notFound) }
                    
                    let request: DomainLayer.Query.WEGateway.RegisterOrder = .init(amount: amount.decimalValue,
                                                                                   assetId: assetId,
                                                                                   address: address,
                                                                                   token: token)
                    
                    return self.gatewayRepository
                        .adCashDepositsRegisterOrder(serverEnvironment: serverEnviroment,
                                                     request: request)
                        .map { (order) -> DomainLayer.DTO.AdCashDeposits.Order in
                            return .init(url: order.url)
                    }
                }
        }
    }
}
