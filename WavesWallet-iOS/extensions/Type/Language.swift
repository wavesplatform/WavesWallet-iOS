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


extension Notification.Name {
    /**
        The notification object contained current Language
    */
    static let changedLanguage: Notification.Name = Notification.Name.init("com.waves.language.notification.changedLanguage")
}

private struct LanguageCode: TSUD {

    private static let key: String = "com.waves.language.code"

    static var defaultValue: Language {
        return Language.list.first(where: { $0.code == "en" })!
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
        let langauge = LanguageCode.get()
        change(langauge, withoutNotification: true)
    }

    static var currentLanguage: Language {
        return LanguageCode.get()
    }

    static func change(_ language: Language, withoutNotification: Bool = false) {
        guard let path = Bundle.main.path(forResource: language.code, ofType: "lproj"), let bundle = Bundle(path: path) else {
            return
        }

        LanguageCode.set(language)
        Localizable.current.locale = Locale(identifier: language.code)
        Localizable.current.bundle = bundle

        if withoutNotification == false {
            NotificationCenter.default.post(name: .changedLanguage, object: language)
        }
    }
}
