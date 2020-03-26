//
//  WEGatewayRepositoryProtocol.swift
//  DataLayer
//
//  Created by rprokofev on 12.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKCrypto
import RxSwift
import Moya
import DomainLayer
import WavesSDK

private enum Constants {
    static let sessionLifeTime: Int64 = 1200000
    static let grantType: String = "password"
    static let scope: String = "client"
    
    static let currencyForLink: String = "USD"
    static let currencyForAd: String = "AC_USD"
}

private struct TransferBindingResponse: Codable {
    let addresses: [String]
    let amount_min: String
    let amount_max: String
    let tax_rate: Double
    let tax_flat: String
}

private struct RegisterOrderResponse: Codable {

    struct AuthenticationData: Codable {
        let sci_name: String
        let account_email: String
        var signature: String
    }
    
    let order_id: String
    let authentication_data: AuthenticationData
}

final class WEGatewayRepository: WEGatewayRepositoryProtocol {
    
    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol
    
    private let weGateway: MoyaProvider<WEGateway.Service> = .anyMoyaProvider()
    
    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols,
         developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol) {
        self.environmentRepository = environmentRepository
        self.developmentConfigsRepository = developmentConfigsRepository
    }
    
    func transferBinding(request: DomainLayer.Query.WEGateway.TransferBinding) -> Observable<DomainLayer.DTO.WEGateway.TransferBinding> {
        
        return Observable.zip(environmentRepository.servicesEnvironment(),
                              developmentConfigsRepository.developmentConfigs())
            .flatMap({ [weak self] (servicesEnvironment, developmentConfigs) ->  Observable<DomainLayer.DTO.WEGateway.TransferBinding> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.gateways.v2
                let exchangeClientSecret = developmentConfigs.exchangeClientSecret
                
                let transferBinding: WEGateway.Query.TransferBinding = .init(token: exchangeClientSecret,
                                                                             senderAsset: request.senderAsset,
                                                                             recipientAsset: request.recipientAsset,
                                                                             recipientAddress: request.recipientAddress)
                
                return self
                    .weGateway
                    .rx
                    .request(.transferBinding(baseURL: url,
                                              query: transferBinding),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(TransferBindingResponse.self)
                    .map { DomainLayer.DTO.WEGateway.TransferBinding(addresses: $0.addresses,
                                                                     amountMin: $0.amount_min.decodeInt64FromBase64(),
                                                                     amountMax: $0.amount_max.decodeInt64FromBase64(),
                                                                     taxRate: $0.tax_rate,
                                                                     taxFlat: $0.tax_flat.decodeInt64FromBase64()) }
                    .asObservable()
            })
    }
    
    func adCashDepositsRegisterOrder(request: DomainLayer.Query.WEGateway.RegisterOrder) -> Observable<DomainLayer.DTO.WEGateway.Order> {
        
        return environmentRepository
            .servicesEnvironment()
            .flatMap({ [weak self] (servicesEnvironment) ->  Observable<DomainLayer.DTO.WEGateway.Order> in
                guard let self = self else { return Observable.empty() }
                
                let url = servicesEnvironment.walletEnvironment.servers.gateways.v2
                
                let token = request.token.accessToken
                let currency = Constants.currencyForAd
                let amount = request.amount
                let address = request.address
                
                let adCashDepositsRegisterOrder: WEGateway.Query.AdCashDepositsRegisterOrder = .init(currency: currency,
                                                                                                     amount: "\(amount)",
                                                                                                     address: address)
                return self
                    .weGateway
                    .rx
                    .request(.adCashDepositsRegisterOrder(baseURL: url,
                                                          token: token,
                                                          query: adCashDepositsRegisterOrder),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(RegisterOrderResponse.self)
                    .catchError({ (ERROR) -> PrimitiveSequence<SingleTrait, RegisterOrderResponse> in
                        print(ERROR)
                        return Single.never()
                    })
                    .map({ (response) -> DomainLayer.DTO.WEGateway.Order? in
                        guard let url = response.createAdCashUrl(amount: amount,
                                                                 currency: Constants.currencyForLink)
                            else { return nil }
                        
                        
                        return DomainLayer.DTO.WEGateway.Order(url: url)
                    })
                    .flatMap({ (order) -> Single<DomainLayer.DTO.WEGateway.Order> in
                        guard let order = order else { return Single.error(NetworkError.notFound)}
                        return Single.just(order)
                    })
                    .asObservable()
            })
    }    
}

private extension RegisterOrderResponse {
 
        func createAdCashUrl(amount: Decimal,
                             currency: String) -> URL? {
                
            
            let accountEmail: String = authentication_data.account_email
            let acSciName: String = authentication_data.sci_name
            let acSign: String = authentication_data.signature
            let acAmount: String = String(format: "%.2f", amount.floatValue)
            let acOrderId: String = order_id
            let acCurrency: String = currency
            let acSuccessUrl: String = DomainLayerConstants.URL.fiatDepositSuccess
            let acFailUrl: String = DomainLayerConstants.URL.fiatDepositFail
         
            var params: [String: String] = .init()
            params["ac_account_email"] = accountEmail
            params["ac_sci_name"] = acSciName
            params["ac_sign"] = acSign
            params["ac_amount"] = acAmount
            params["ac_order_id"] = acOrderId
            params["ac_currency"] = acCurrency
            params["ac_success_url"] = acSuccessUrl
            params["ac_fail_url"] = acFailUrl
           
            var components = URLComponents(string: DomainLayerConstants.URL.advcash)
            components?.queryItems = params.map {
                 URLQueryItem(name: $0, value: $1)
            }
            
            let url = components?.url
            
            return url
        }
}
