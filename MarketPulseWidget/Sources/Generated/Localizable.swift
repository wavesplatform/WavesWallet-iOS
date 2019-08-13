// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {

  internal enum Kek {

    internal enum Lol {
      /// Dont fuck me
      internal static var test: String { return Localizable.tr("WavesMarketPulce", "kek.lol.test") }
      internal static var testKey: String { return "kek.lol.test" }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension Localizable {

    struct Current {
        var locale: Locale
        var bundle: Bundle
    }

    private static let english: Localizable.Current = Localizable.Current(locale: Locale(identifier: "en"), bundle: Bundle(for: BundleToken.self))

    static var current: Localizable.Current = Localizable.Current(locale: Locale.current, bundle: Bundle(for: BundleToken.self))

    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: table, bundle: current.bundle, comment: "")

        let value = String(format: format, locale: current.locale, arguments: args)

        if value.localizedLowercase == key.localizedLowercase {
            let format = NSLocalizedString(key, tableName: table, bundle: english.bundle, comment: "")
            return String(format: format, locale: english.locale, arguments: args)
        } else {
            return value
        }
    }
}

private final class BundleToken {}
