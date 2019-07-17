//
//  NotificationNewsDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct NotificationNews {
        public let startDate: Date
        public let endDate: Date
        public let logoUrl: String
        public let id: String
        public let title: [String: String]
        public let subTitle: [String: String]

        public init(startDate: Date, endDate: Date, logoUrl: String, id: String, title: [String: String], subTitle: [String: String]) {
            self.startDate = startDate
            self.endDate = endDate
            self.logoUrl = logoUrl
            self.id = id
            self.title = title
            self.subTitle = subTitle
        }
    }
}

