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
    
    init(gatewayRepository: WEGatewayRepositoryProtocol,
         oAuthRepository: WEOAuthRepositoryProtocol,
         authorizationUseCase: AuthorizationUseCaseProtocol,
         assetsUseCase: AssetsUseCaseProtocol) {
        self.gatewayRepository = gatewayRepository
        self.oAuthRepository = oAuthRepository
        self.authorizationUseCase = authorizationUseCase
        self.assetsUseCase = assetsUseCase
    }
    
    func requirementsOrder(assetId: String) -> Observable<DomainLayer.DTO.AdCashDeposits.RequirementsOrder> {
        
        return authorizationUseCase
            .authorizedWallet()
            .flatMap { [weak self] signedWallet -> Observable<DomainLayer.DTO.AdCashDeposits.RequirementsOrder> in
                
                guard let self = self else { return Observable.never() }
                
                return self.oAuthRepository
                    .oauthToken(signedWallet: signedWallet)
                    .flatMap { [weak self] token -> Observable<DomainLayer.DTO.AdCashDeposits.RequirementsOrder> in
                        
                        guard let self = self else { return Observable.never() }
                        
                        let assets = self.assetsUseCase
                            .assets(by: [assetId],
                                    accountAddress: signedWallet.address)
                            .flatMap { assets -> Observable<DomainLayer.DTO.Asset> in
                                guard let asset = assets.first(where: { $0.id == assetId }) else {
                                    return Observable.error(NetworkError.notFound)
                                }
                                return Observable.just(asset)
                        }
                        
                        let transferBinding = self.gatewayRepository
                            .transferBinding(request: .init(senderAsset: Constants.ACUSD,
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
        
        return authorizationUseCase
            .authorizedWallet()
            .flatMap { [weak self] signedWallet -> Observable<DomainLayer.DTO.AdCashDeposits.Order> in
                
                guard let self = self else { return Observable.never() }
                                        
                return self.oAuthRepository
                    .oauthToken(signedWallet: signedWallet)
                    .flatMap { [weak self] token -> Observable<(DomainLayer.DTO.WEGateway.TransferBinding,
                        DomainLayer.DTO.WEOAuth.Token)> in
                        
                        
                        guard let self = self else { return Observable.never() }
                        
                        let transferBinding = self.gatewayRepository
                            .transferBinding(request: .init(senderAsset: Constants.ACUSD,
                                                            recipientAsset: assetId,
                                                            recipientAddress: signedWallet.address,
                                                            token: token))
                        
                        return Observable.zip(transferBinding, Observable.just(token))
                }
                .flatMap { transferBinding, token -> Observable<DomainLayer.DTO.AdCashDeposits.Order> in
                    
                    guard let address = transferBinding
                        .addresses
                        .first else { return Observable.error(NetworkError.notFound) }
                    
                    let request: DomainLayer.Query.WEGateway.RegisterOrder = .init(amount: amount.decimalValue,
                                                                                   assetId: assetId,
                                                                                   address: address,
                                                                                   token: token)
                    
                    return self.gatewayRepository
                        .adCashDepositsRegisterOrder(request: request)
                        .map { (order) -> DomainLayer.DTO.AdCashDeposits.Order in
                            return .init(url: order.url)
                        }
                }
        }
    }
}


/**
 
 Как только попадаем на страницу загрузки получаем лимиты.
 AssetInfo по stakingAssetId из Дата Сервисов
 @POST("v0/assets")
 fun assets(@Body request: AssetsRequest): Observable<AssetsInfoResponse>
 И получаем авторизацию из
 const val URL_WAVES_EXCHANGE = "https://waves.exchange/"
 для этого дергаем метод, но НЕ JSONом:
 @FormUrlEncoded
 @POST("oauth/token")
 fun oauthToken(@Header("Authorization") token: String = CLIENT_SECRET, // постоянный параметр см. ниже
 @Field("username") username: String = WavesWallet.getPublicKeyStr(),
 @Field("password") password: String,
 @Field("grant_type") grantType: String = "password", // постоянный параметр
 @Field("scope") scope: String = "client") // постоянный параметр
 : Observable<AuthDataResponse>
 c параметрами:
 val time = currentTimeMillis + SESSION_LIFE_TIME // время жизни запрашиваемого токена, у меня 20 минут
 val password = "$time:" +
 WavesCrypto.base58encode(
 WavesCrypto.signBytesWithPrivateKey(
 Bytes.concat(
 WavesCrypto.base58decode(getPublicKeyStr()),
 Longs.toByteArray(time)),
 WavesCrypto.base58encode(
 App.accessManager.getWallet()?.privateKey
 ?: byteArrayOf())))
 companion object {
 const val CLIENT_SECRET = "Basic dGVzdC1jbGllbnQ6c2VjcmV0" - это постоянный секрет клиетнта он засовывается в @Header("Authorization") запроса
 const val AC_USD = "AC_USD"
 const val AC_USD_DECIMALS = 2
 const val SESSION_LIFE_TIME = 1_200_000 // в миллисекундах
 }
 в ответ приходит объект:
 data class AuthDataResponse(
 @SerializedName("access_token")
 var accessToken: String = "", // Токен, token = "Bearer " + it.accessToken, нужен будет далее в @Header("Authorization") запроса, где был CLIENT_SECRET, он больше не нужен
 @SerializedName("token_type")
 var tokenType: String  = "bearer",
 @SerializedName("expires_in")
 var expiresIn: Long = 0L,
 @SerializedName("scope")
 var scope: String  = "client",
 @SerializedName("cred_message")
 var credMessage: String  = "",
 @SerializedName("pub_key")
 var pubKey: String  = "",
 @SerializedName("requested_expiration")
 var requestedExpiration: Long = 0L,
 @SerializedName("signature")
 var signature: String  = "",
 @SerializedName("jti")
 var jti: String  = ""
 )
 Далее снова идем в "https://waves.exchange/"
 @POST("gateways/api.DispatcherManagingPublic/GetOrCreateTransferBinding")
 fun transferBinding(@Header("Authorization") token: String, // Нужно положить токен в заголовок "Bearer LALALA_SAM_TOKEN" @Header("Authorization")
 @Body request: TransferBindingRequest): Observable<TransferBindingResponse>
 с объектом в виде JSON
 data class TransferBindingRequest(
 @SerializedName("sender_asset") var senderAsset: String = ExchangeService.AC_USD, // const val AC_USD = "AC_USD"
 @SerializedName("recipient_asset") var recipientAsset: String, // stakingAssetId = const val USD_ID = "DG2xFkPdDwKUoBkzGAhQtLpSGzfXLiCYPEzeKH2Ad24p"
 @SerializedName("recipient_address") var recipientAddress: String = WavesWallet.getAddress()) // мой адрес
 В ответ приходит:
 data class TransferBindingResponse(
 @SerializedName("addresses")
 var addresses: List<String?> = listOf(), // один в списке, далее нужен будет
 @SerializedName("amount_min")
 var amountMin: String = "", // private const val ENCODED_10 = "A+g=" тут и ниже приходит специальная борода для weba, ниже как ее разобрать в копейки
 @SerializedName("amount_max")
 var amountMax: String = "", // private const val ENCODED_3000 = "BJPg"
 @SerializedName("tax_rate")
 var taxRate: String = "")
 Общий способ как бороду перевести в копейки.
 Перевести в base64, развернуть, редюс - текущий байт умножить на 256 в степени индекса байта и сложить с аккумулятором
 "BJPg" -> 300000 -> 3000.00
 "A+g=" -> 1000 -> 10.00
 export const intFromBytes = (byteArr) => byteArr ? byteArr.reverse().reduce((acc, cur, i) => acc + cur * 256 ** (i), 0) : 0;
 fun convert(array: String): Long {
 val byteArr = Base64.decode(array)
 return byteArr.toUByteArray()
 .map { it.toInt() }
 .reversed()
 .foldIndexed(0) { index, acc, cur ->
 acc + cur * 256.0.pow(index).toInt()
 }
 .toLong()
 }
 После этого отображаем форму, приводим копейки к нормальному виду с decimals=2
 
 
 Вбиваем сумму, проверяем на лимиты и идем создавать ордер для Advanced Cash
 Для этого идем тоже пока на "https://waves.exchange/"
 @POST("gateways/acash.ACashDeposits/RegisterOrder")
 fun registerOrder(@Header("Authorization") token: String, // Нужно положить токен в заголовок "Bearer LALALA_SAM_TOKEN" @Header("Authorization")
 @Body request: RegisterOrderRequest)
 : Observable<RegisterOrderResponse>
 Укладываем объект
 data class RegisterOrderRequest(
 @SerializedName("currency") var currency: String = ExchangeService.AC_USD, // const val AC_USD = "AC_USD"
 @SerializedName("amount") var amount: String, // амаунт в формате "123.00" "123.90" с копейками иначе потом подпись не пройдет
 @SerializedName("address") var address: String) // адрес из списка выше в TransferBindingResponse.addresses[0]
 В ответ приходит, это понадобится позже чтобы пойти в WebView:
 data class RegisterOrderResponse(
 @SerializedName("order_id")
 var orderId: String = "",
 @SerializedName("authentication_data")
 var authenticationData: AuthenticationData = AuthenticationData()) {
 data class AuthenticationData(
 @SerializedName("sci_name")
 var sciName: String = "",
 @SerializedName("account_email")
 var accountEmail: String = "",
 @SerializedName("signature")
 var signature: String = "")
 }
 Далее идем на WebView c параметрами в виде GET строки на
 const val LINK_ADV_CASH = "https://wallet.advcash.com/sci"
 val params = "ac_account_email=" +
 URLEncoder.encode(orderResponse.authenticationData.accountEmail, "UTF-8") +
 "&ac_sci_name=" +
 URLEncoder.encode(orderResponse.authenticationData.sciName, "UTF-8") +
 "&ac_sign=" +
 URLEncoder.encode(orderResponse.authenticationData.signature, "UTF-8") +
 "&ac_amount=" +
 URLEncoder.encode(amount, "UTF-8") +
 "&ac_order_id=" +
 URLEncoder.encode(orderResponse.orderId, "UTF-8") +
 "&ac_currency=" +
 URLEncoder.encode("USD", "UTF-8") +
 "&ac_success_url=${LINK_SUCCESS}" +
 "&ac_fail_url=${LINK_FAIL}"
 putExtra(WebActivity.KEY_INTENT_LINK,
 "${LINK_ADV_CASH}?${params}") // Вот так
 const val LINK_SUCCESS = "https://waves.exchange/fiatdeposit/success"
 const val LINK_FAIL = "https://waves.exchange/fiatdeposit/fail"
 И вылавливаем переход на Success или Fail
 
 Обе ссылки возвращаются с некоторыми первоначальными параметрами типа:
 https://waves.exchange/fiatdeposit/fail?ac_account_email=lalal@gmail.com&ac_order_id=289ur-flaknjw7-ofn.......
 поэтому их нужно проверять по хосту и пути
 */

