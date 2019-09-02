//
//  PublicKeyMatcherService.swift
//  Alamofire
//
//  Created by rprokofev on 06/05/2019.
//

import Foundation
import RxSwift
import Moya
import WavesSDK

final class WidgetPublicKeyMatcherService: PublicKeyMatcherServiceProtocol {
    
    private let publicKeyProvider: MoyaProvider<WidgetMatcherService.Target.MatcherPublicKey> = InternalWidgetService.moyaProvider()
    
    func publicKey() -> Observable<String> {
        
        return self
            .publicKeyProvider
            .rx
            .request(.init(matcherUrl: InternalWidgetService.shared.matcherUrl),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Single<Response> in
                return Single<Response>.error(NetworkError.error(by: error))
            })
            .flatMap({ (response) -> Single<String> in
                
                do {
                    guard let key = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? String else {
                        return Single.error(NetworkError.none)
                    }
                    return Single.just(key)
                } catch let error {
                    return Single.error(error)
                }
            })
            .asObservable()
    }
}
