//
//  AliasDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    //TODO: need update to correct model from API
    
    struct Alias: Hashable {
        let name: String
        let originalName: String
    }
}
