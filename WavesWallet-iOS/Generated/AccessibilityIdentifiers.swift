// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation
import Extensions

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum AccessibilityIdentifiers {

  internal enum Hellolanguagesviewcontroller {
    /// helloLanguagesViewController.continueBtn
    internal static var continueBtn: String { AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "helloLanguagesViewController.continueBtn") }
    internal static var continueBtnKey: String { "helloLanguagesViewController.continueBtn" }
    /// helloLanguagesViewController.rootView
    internal static var rootView: String { AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "helloLanguagesViewController.rootView") }
    internal static var rootViewKey: String { "helloLanguagesViewController.rootView" }
  }

  internal enum Infopagesviewcontroller {
    /// infoPagesViewController.nextControl
    internal static var nextControl: String { AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "infoPagesViewController.nextControl") }
    internal static var nextControlKey: String { "infoPagesViewController.nextControl" }
  }

  internal enum Languagetablecell {
    /// languageTableCell.iconLanguage
    internal static var iconLanguage: String { AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "languageTableCell.iconLanguage") }
    internal static var iconLanguageKey: String { "languageTableCell.iconLanguage" }
    /// languageTableCell.labelTitle
    internal static var labelTitle: String { AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "languageTableCell.labelTitle") }
    internal static var labelTitleKey: String { "languageTableCell.labelTitle" }

    internal enum Iconcheckmark {
      /// languageTableCell.iconCheckmark.select
      internal static var select: String { AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "languageTableCell.iconCheckmark.select") }
      internal static var selectKey: String { "languageTableCell.iconCheckmark.select" }
      /// languageTableCell.iconCheckmark.unselect
      internal static var unselect: String { AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "languageTableCell.iconCheckmark.unselect") }
      internal static var unselectKey: String { "languageTableCell.iconCheckmark.unselect" }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension AccessibilityIdentifiers: LocalizableProtocol {

    struct Current {
        var locale: Locale
        var bundle: Bundle
    }

    private static let english = Localizable.Current(locale: Locale(identifier: "en"), bundle: Bundle(for: BundleToken.self))

    static var locale = Locale.current
    static var bundle = Bundle(for: BundleToken.self)

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
