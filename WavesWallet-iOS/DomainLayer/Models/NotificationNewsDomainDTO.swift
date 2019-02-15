//
//  NotificationNewsDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct NotificationNews {
        let startDate: Date
        let endDate: Date
        let logoUrl: String
        let id: String
        let title: [String: String]
        let subTitle: [String: String]
    }
}

