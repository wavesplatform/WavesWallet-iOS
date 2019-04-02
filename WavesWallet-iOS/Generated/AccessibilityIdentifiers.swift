// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum AccessibilityIdentifiers {

  internal enum Hellolanguagesviewcontroller {
    /// helloLanguagesViewController.continueBtn
    internal static var continueBtn: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "helloLanguagesViewController.continueBtn") }
    /// helloLanguagesViewController.rootView
    internal static var rootView: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "helloLanguagesViewController.rootView") }
  }

  internal enum Infopagesviewcontroller {
    /// infoPagesViewController.nextControl
    internal static var nextControl: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "infoPagesViewController.nextControl") }
  }

  internal enum Languagetablecell {
    /// languageTableCell.iconLanguage
    internal static var iconLanguage: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "languageTableCell.iconLanguage") }
    /// languageTableCell.labelTitle
    internal static var labelTitle: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "languageTableCell.labelTitle") }

    internal enum Iconcheckmark {
      /// languageTableCell.iconCheckmark.select
      internal static var select: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "languageTableCell.iconCheckmark.select") }
      /// languageTableCell.iconCheckmark.unselect
      internal static var unselect: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "languageTableCell.iconCheckmark.unselect") }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension AccessibilityIdentifiers {

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
