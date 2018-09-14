//
//  Language.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct Language: Codable {
    let title: String
    let icon: String
    let code: String
}

private struct LanguageCode: TSUD {

    private static let key: String = "com.waves.language.code"

    static var defaultValue: String {
        return "en"
    }

    static var stringKey: String {
        return LanguageCode.key
    }
}

extension Language {

    static var list: [Language] = {
        let list: [Language] = JSONDecoder.decode(json: "Languages") ?? []
        return list
    }()

    static func load() {
        let code = LanguageCode.get()
        change(code: code)
    }

    static func change(code: String) {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"), let bundle = Bundle(path: path) else {
            return
        }

        LanguageCode.set(code)
        Localizable.current.locale = Locale(identifier: code)
        Localizable.current.bundle = bundle
    }
}
