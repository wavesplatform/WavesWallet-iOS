//
//  NotificationNewsRepository.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class NotificationNewsRepository: NotificationNewsRepositoryProtocol {

    private let applicationNews: MoyaProvider<GitHub.Service.ApplicationNews> = .nodeMoyaProvider()

    func notificationNews() -> Observable<[DomainLayer.DTO.NotificationNews]> {

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            guard let double = NumberFormatter()
                .number(from: dateStr)?
                .doubleValue else {
                    throw RepositoryError.fail
                }

            return Date(timeIntervalSince1970: double)
            
        })

        return applicationNews
            .rx
            .request(.get, callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .asObservable()
            .filterSuccessfulStatusAndRedirectCodes()
            .map(GitHub.DTO.News.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)            
            .map { news -> [DomainLayer.DTO.NotificationNews] in
                return news.notifications.map {
                    return DomainLayer.DTO.NotificationNews(startDate: $0.startDate,
                                                            endDate: $0.endDate,
                                                            logoUrl: $0.logoUrl,
                                                            id: $0.id,
                                                            title: $0.title,
                                                            subTitle: $0.subTitle)


                }
            }
            .asObservable()
    }
}

fileprivate extension GitHub.DTO {

    struct News: Codable {

        struct Notification: Codable {
            let startDate: Date
            let endDate: Date
            let logoUrl: String
            let id: String
            let title: [String: String]
            let subTitle: [String: String]
        }

        let notifications: [Notification]
    }
}

