// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum AccessibilityIdentifiers {

  internal enum View {

    internal enum Cell {

      internal enum Languagetable {
        /// view.cell.languageTable.rootView
        internal static var rootView: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "view.cell.languageTable.rootView") }
        /// view.cell.languageTable.title
        internal static var title: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "view.cell.languageTable.title") }

        internal enum Icon {
          /// view.cell.languageTable.icon.language
          internal static var language: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "view.cell.languageTable.icon.language") }

          internal enum Checkmark {
            /// view.cell.languageTable.icon.checkmark.select
            internal static var select: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "view.cell.languageTable.icon.checkmark.select") }
            /// view.cell.languageTable.icon.checkmark.unselect
            internal static var unselect: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "view.cell.languageTable.icon.checkmark.unselect") }
          }
        }
      }
    }
  }

  internal enum Viewcontroller {

    internal enum Hellolanguages {
      /// viewController.helloLanguages.rootView
      internal static var rootView: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "viewController.helloLanguages.rootView") }

      internal enum Button {
        /// helloLanguagesViewController.button.continue
        internal static var `continue`: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "viewController.helloLanguages.button.continue") }
      }
    }

    internal enum Infopagesviewcontroller {
      /// viewController.infoPagesViewController.rootView
      internal static var rootView: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "viewController.infoPagesViewController.rootView") }

      internal enum Button {
        /// viewController.infoPagesViewController.button.next
        internal static var next: String { return AccessibilityIdentifiers.tr("AccessibilityIdentifiers", "viewController.infoPagesViewController.button.next") }
      }
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
