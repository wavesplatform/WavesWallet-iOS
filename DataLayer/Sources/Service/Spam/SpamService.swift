//
//  SpamService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Moya
import RxSwift

enum Spam {}

extension Spam {
    enum Service {}
}

private struct Constants {
    static let spamFile = "spam";
    static let spamFileExt = "scv";
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
            .catchError({ error -> Single<[String]> in
                let url = Bundle.main.url(forResource: Constants.spamFile, withExtension: Constants.spamFileExt)
                if let url = url, let data = try? Data.init(contentsOf: url) {
                    return Single.just((try? SpamCVC.addresses(from: data)) ?? [])
                } else {
                    return Single.just([])
                }
            })
            .asObservable()
    }
}
