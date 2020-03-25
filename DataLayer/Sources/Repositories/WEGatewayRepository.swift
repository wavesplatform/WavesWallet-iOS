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
                let assetId = "AC_USD"
                let currency = "USD"
                let amount = "\(request.amount)"
                let address = request.address
                
                let adCashDepositsRegisterOrder: WEGateway.Query.AdCashDepositsRegisterOrder = .init(currency: assetId,
                                                                                                     amount:    amount,
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
                                                                 assetId: currency)
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
 
        func createAdCashUrl(amount: String,
                             assetId: String) -> URL? {
                
            let accountEmail: String = authentication_data.account_email
            let acSciName: String = authentication_data.sci_name
            let acSign: String = authentication_data.signature
            let acAmount: String = amount
            let acOrderId: String = order_id
            let acCurrency: String = assetId
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
           
//            URL    https://wallet.advcash.com/sci/?ac_account_email=gw%40waves.exchange&ac_sci_name=wavesexchange&ac_amount=100000.00&ac_currency=USD&ac_order_id=ccc75ec6-abb3-40b6-bae7-4a97b314500b&ac_sign=DE7244FCE69163C98D9CAFB0BD0BD59650892533B9BEED0D8983E9D8A974ECA2&ac_success_url=https%3A%2F%2Fwaves.exchange%2Ffiatdeposit%2Fsuccess&ac_fail_url=https%3A%2F%2Fwaves.exchange%2Ffiatdeposit%2Ffail
            
//            https://wallet.advcash.com/sci?ac_order_id=0ae3b9f8-3d5d-49b3-90d4-8e7c855ea9de&ac_amount=100000&ac_account_email=gw@waves.exchange&ac_sci_name=wavesexchange&ac_success_url=https://waves.exchange/fiatdeposit/success&ac_fail_url=https://waves.exchange/fiatdeposit/fail&ac_sign=61FB18F45BC38AFAC5E3F83FE6A9F534886B2D6E1E9B86A0A51FBFAB65D3F451&ac_currency=USD
            var components = URLComponents(string: DomainLayerConstants.URL.advcash)
            components?.queryItems = params.map {
                 URLQueryItem(name: $0, value: $1)
            }
            
            let url = components?.url
            
            return url
        }
}
