//
//  Encodable+Dictionary.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Encodable {

    subscript(key: String) -> Any? {
        return dictionary[key]
    }

    var data: Data? {
        return try? JSONEncoder().encode(self)
    }

    var dictionary: [String: Any] {
        guard let data = data else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }
}
