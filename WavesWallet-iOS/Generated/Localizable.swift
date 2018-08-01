// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {

  internal enum Controller {

    internal enum Wallet {

      internal enum Navigation {

        internal enum Bar {
          /// Wallet
          internal static let title = L10n.tr("Localizable", "controller.wallet.navigation.bar.title")
        }
      }
    }
  }

  internal enum General {

    internal enum Name {
      /// / My Asset
      internal static let myasset = L10n.tr("Localizable", "general.name.myasset")
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
