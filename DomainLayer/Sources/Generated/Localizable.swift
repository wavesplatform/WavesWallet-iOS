// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {

  internal enum Biometric {
    /// Cancelbla
    internal static var localizedCancelTitle: String { return Localizable.tr("WavesDomainLayer", "biometric.localizedCancelTitle") }
    internal static var localizedCancelTitleKey: String { return "biometric.localizedCancelTitle" }
    /// Enter Passcode
    internal static var localizedFallbackTitle: String { return Localizable.tr("WavesDomainLayer", "biometric.localizedFallbackTitle") }
    internal static var localizedFallbackTitleKey: String { return "biometric.localizedFallbackTitle" }
    /// Access to your wallet
    internal static var readfromkeychain: String { return Localizable.tr("WavesDomainLayer", "biometric.readfromkeychain") }
    internal static var readfromkeychainKey: String { return "biometric.readfromkeychain" }
    /// Access to your wallet
    internal static var saveinkeychain: String { return Localizable.tr("WavesDomainLayer", "biometric.saveinkeychain") }
    internal static var saveinkeychainKey: String { return "biometric.saveinkeychain" }

    internal enum Manyattempts {
      /// To unlock biometric, sign in with your account password
      internal static var subtitle: String { return Localizable.tr("WavesDomainLayer", "biometric.manyattempts.subtitle") }
      internal static var subtitleKey: String { return "biometric.manyattempts.subtitle" }
      /// Too many attempts
      internal static var title: String { return Localizable.tr("WavesDomainLayer", "biometric.manyattempts.title") }
      internal static var titleKey: String { return "biometric.manyattempts.title" }
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
