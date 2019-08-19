// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation
import Extensions

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {

  internal enum Marketpulsewidget {

    internal enum Button {

      internal enum Update {
        /// Update
        internal static var title: String { return Localizable.tr("WavesMarketPulse", "marketpulsewidget.button.update.title") }
        internal static var titleKey: String { return "marketpulsewidget.button.update.title" }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension Localizable: LocalizableProtocol {

    struct Current {
        var locale: Locale
        var bundle: Bundle
    }

    private static let english: Localizable.Current = Localizable.Current(locale: Locale(identifier: "en"), bundle: Bundle(for: BundleToken.self))

    static var locale: Locale = Locale.current
    static var bundle: Bundle = Bundle(for: BundleToken.self)

    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: table, bundle: bundle, comment: "")

        let value = String(format: format, locale: locale, arguments: args)

        if value.localizedLowercase == key.localizedLowercase {
            let format = NSLocalizedString(key, tableName: table, bundle: english.bundle, comment: "")
            return String(format: format, locale: english.locale, arguments: args)
        } else {
            return value
        }
    }
}

private final class BundleToken {}
