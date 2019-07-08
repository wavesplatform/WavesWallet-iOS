//
//  UtilsNode.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/12/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    enum Utils {}
}

extension Node.DTO.Utils {
    
    struct Time: Decodable {
        let system: Int64
        let NTP: Int64
    }
}
