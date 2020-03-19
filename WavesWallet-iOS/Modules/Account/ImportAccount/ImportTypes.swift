//
//  ImportTypes.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer

enum ImportTypes {
    enum DTO { }
    
}

extension ImportTypes.DTO {
    struct Account {
        let privateKey: DomainLayer.DTO.PrivateKey
        let password: String
        let name: String
    }
}