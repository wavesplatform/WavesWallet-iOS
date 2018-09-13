//
//  Language.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct Language: Decodable {
    let title: String
    let icon: String
    let code: String
}

extension Language {
    static var list: [Language] = {
        let list: [Language] = JSONDecoder.decode(json: "Languages") ?? []
        return list
    }()
}
