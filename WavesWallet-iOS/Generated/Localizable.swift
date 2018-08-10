// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {
  internal enum DexSort {

    internal enum Navigationbar {
      /// Sorting
      internal static let title = Localizable.tr("DexSort", "navigationBar.title")
    }
  }
  internal enum InfoPlist {
    /// The camera is needed to scan QR codes
    internal static let nsCameraUsageDescription = Localizable.tr("InfoPlist", "NSCameraUsageDescription")
    /// Authenticate with Face ID
    internal static let nsFaceIDUsageDescription = Localizable.tr("InfoPlist", "NSFaceIDUsageDescription")
  }
  internal enum DexList {

    internal enum Button {
      /// Add Markets
      internal static let addMarkets = Localizable.tr("DexList", "button.addMarkets")
    }

    internal enum Label {
      /// Decentralised Exchange
      internal static let decentralisedExchange = Localizable.tr("DexList", "label.decentralisedExchange")
      /// Trade quickly and securely. You retain complete control over your funds when trading them on our decentralised exchange.
      internal static let description = Localizable.tr("DexList", "label.description")
      /// Last update
      internal static let lastUpdate = Localizable.tr("DexList", "label.lastUpdate")
      /// Price
      internal static let price = Localizable.tr("DexList", "label.price")
      /// today
      internal static let today = Localizable.tr("DexList", "label.today")
      /// yesterday
      internal static let yesterday = Localizable.tr("DexList", "label.yesterday")
    }

    internal enum Navigationbar {
      /// Dex
      internal static let title = Localizable.tr("DexList", "navigationBar.title")
    }
  }
  internal enum DexMarket {

    internal enum Label {
      /// Loading markets…
      internal static let loadingMarkets = Localizable.tr("DexMarket", "label.loadingMarkets")
    }

    internal enum Navigationbar {
      /// Markets
      internal static let title = Localizable.tr("DexMarket", "navigationBar.title")
    }

    internal enum Searchbar {
      /// Search
      internal static let placeholder = Localizable.tr("DexMarket", "searchBar.placeholder")
    }
  }
  internal enum Wallet {

    internal enum Button {
      /// Start Lease
      internal static let startLease = Localizable.tr("Wallet", "button.startLease")
    }

    internal enum Label {
      /// Available
      internal static let available = Localizable.tr("Wallet", "label.available")
      /// Leased
      internal static let leased = Localizable.tr("Wallet", "label.leased")
      /// Started Leasing
      internal static let startedLeasing = Localizable.tr("Wallet", "label.startedLeasing")
      /// Total balance
      internal static let totalBalance = Localizable.tr("Wallet", "label.totalBalance")
      /// View history
      internal static let viewHistory = Localizable.tr("Wallet", "label.viewHistory")

      internal enum Quicknote {

        internal enum Description {
          /// You can only transfer or trade WAVES that aren’t leased. The leased amount cannot be transferred or traded by you or anyone else.
          internal static let first = Localizable.tr("Wallet", "label.quickNote.description.first")
          /// You can cancel a leasing transaction as soon as it appears in the blockchain which usually occurs in a minute or less.
          internal static let second = Localizable.tr("Wallet", "label.quickNote.description.second")
          /// The generating balance will be updated after 1000 blocks.
          internal static let third = Localizable.tr("Wallet", "label.quickNote.description.third")
        }
      }
    }

    internal enum Navigationbar {
      /// Wallet
      internal static let title = Localizable.tr("Wallet", "navigationBar.title")
    }

    internal enum Section {
      /// Active now (%d)
      internal static func activeNow(_ p1: Int) -> String {
        return Localizable.tr("Wallet", "section.activeNow", p1)
      }
      /// Hidden assets (%d)
      internal static func hiddenAssets(_ p1: Int) -> String {
        return Localizable.tr("Wallet", "section.hiddenAssets", p1)
      }
      /// Quick note
      internal static let quickNote = Localizable.tr("Wallet", "section.quickNote")
      /// Spam assets (%d)
      internal static func spamAssets(_ p1: Int) -> String {
        return Localizable.tr("Wallet", "section.spamAssets", p1)
      }
    }

    internal enum Segmentedcontrol {
      /// Assets
      internal static let assets = Localizable.tr("Wallet", "segmentedControl.assets")
      /// Leasing
      internal static let leasing = Localizable.tr("Wallet", "segmentedControl.leasing")
    }
  }
  internal enum WalletSort {

    internal enum Button {
      /// Position
      internal static let position = Localizable.tr("WalletSort", "button.position")
      /// Visibility
      internal static let visibility = Localizable.tr("WalletSort", "button.visibility")
    }

    internal enum Navigationbar {
      /// Sorting
      internal static let title = Localizable.tr("WalletSort", "navigationBar.title")
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension Localizable {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
