//
//  Language.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//
import Foundation
import WavesSDKExtension

struct Language: Codable {
    let title: String
    let icon: String
    let code: String
    let titleCode: String?
}

protocol Localization {
    func setupLocalization()
}

private struct LanguageCode: TSUD {

    private static let key: String = "com.waves.language.code"
    private static let deffaultLanguageCode: String = "en"

    static var defaultValue: Language {
        return Language.list.first(where: { $0.code == LanguageCode.deffaultLanguageCode })!
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
        if isValidLanguage(langauge) {
            change(langauge, withoutNotification: true)
        }
        else {
            change(Language.defaultLanguage, withoutNotification: true)
        }
    }

    static var currentLanguage: Language {

        return LanguageCode.get()
    }

    static var defaultLanguage: Language {
        return LanguageCode.defaultValue
    }

    static var currentLocale: Locale {
        return Locale(identifier: currentLanguage.code)
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

    private static func isValidLanguage(_ language: Language) -> Bool {
        if let path = Bundle.main.path(forResource: language.code, ofType: "lproj"), let _ = Bundle(path: path) {
            return true
        }
        return false
    }
}
