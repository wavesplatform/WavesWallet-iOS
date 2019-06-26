//
//  SpamService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RxSwift

enum Spam {}

extension Spam {
    enum Service {}
}

final class SpamAssetsService {
    
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = .anyMoyaProvider()
    
    func spamAssets(by url: URL) -> Observable<[String]> {
        
        return self
            .spamProvider
            .rx
            .request(.getSpamListByUrl(url: url),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .map({ (response) -> [String] in
                return (try? SpamCVC.addresses(from: response.data)) ?? []
            })
            .asObservable()
    }
}
