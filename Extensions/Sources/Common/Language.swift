//
//  Language.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//
import Foundation
import WavesSDKExtensions

public extension Notification.Name {
    static let changedLanguage: Notification.Name = Notification.Name.init("com.waves.language.notification.changedLanguage")
}

public struct Language: Codable {
    public let title: String
    public let icon: String
    public let code: String
    public let titleCode: String?

    public init(title: String, icon: String, code: String, titleCode: String?) {
        self.title = title
        self.icon = icon
        self.code = code
        self.titleCode = titleCode
    }
}

public protocol Localization {
    func setupLocalization()
}

public protocol LocalizableProtocol {
    static var locale: Locale { set get }
    static var bundle: Bundle { set get }
}

private struct LanguageCode: TSUD {

    private static let key: String = "com.waves.language.code"
    private static let deffaultLanguageCode: String = "en"
    
    static var defaultValue: Language {
        return Language.languages.first(where: { $0.code == LanguageCode.deffaultLanguageCode })!
    }

    static var stringKey: String {
        return LanguageCode.key
    }
    
    static var userDefaults: UserDefaults {
        return UserDefaults.init(suiteName: "group.com.wavesplatform") ?? .standard
    }
}

public extension Language {

    private static var localizable: LocalizableProtocol.Type!
    private static var jsonLanguages: String!
    fileprivate static var languages: [Language]!
    
    static func load<L>(localizable: L.Type, languages: [Language]) where L: LocalizableProtocol {
        
        self.languages = languages
        self.localizable = localizable
        //Migration to group
        if LanguageCode.get().code != LanguageCode.defaultValue.code && LanguageCode.get(.standard).code != LanguageCode.defaultValue.code {
            LanguageCode.set(LanguageCode.get(.standard))
        }
        
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
        Language.localizable.locale = Locale(identifier: language.code)
        Language.localizable.bundle = bundle

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
    
    func localizedString(key: String) -> String {
        
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: nil, table: "Waves")
        }
        return key
    }
}

