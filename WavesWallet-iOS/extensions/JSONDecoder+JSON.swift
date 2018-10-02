//
//  JSONDecoder+JSON.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension JSONDecoder {

    static func decode<Model: Decodable>(json fileName: String) -> Model? {
        let decoder = JSONDecoder()
        guard let path = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        guard let data = try? Data(contentsOf: path) else {
            return nil
        }

        return try? decoder.decode(Model.self, from: data)
    }
}
