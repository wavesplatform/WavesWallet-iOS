//
//  Language+List.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 14.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import Extensions

extension Language {
    
    static var list: [Language] {
        let list: [Language] = JSONDecoder.decode(json: "Languages") ?? []
        return list
    }
}
