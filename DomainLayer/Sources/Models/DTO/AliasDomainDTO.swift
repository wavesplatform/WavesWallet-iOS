//
//  AliasDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {

    //TODO: need update to correct model from API
    
    struct Alias: Hashable {
        public let name: String
        public let originalName: String

        public init(name: String, originalName: String) {
            self.name = name
            self.originalName = originalName
        }
    }
}
