// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {
  internal enum Asset {

    internal enum Cell {
      /// View history
      internal static let viewHistory = Localizable.tr("Asset", "cell.viewHistory")

      internal enum Assetinfo {
        /// Description
        internal static let description = Localizable.tr("Asset", "cell.assetInfo.description")
        /// ID
        internal static let id = Localizable.tr("Asset", "cell.assetInfo.id")
        /// Issue date
        internal static let issueDate = Localizable.tr("Asset", "cell.assetInfo.issueDate")
        /// Issuer
        internal static let issuer = Localizable.tr("Asset", "cell.assetInfo.issuer")
        /// Name
        internal static let name = Localizable.tr("Asset", "cell.assetInfo.name")
        /// Asset Info
        internal static let title = Localizable.tr("Asset", "cell.assetInfo.title")
        /// Type
        internal static let type = Localizable.tr("Asset", "cell.assetInfo.type")
      }

      internal enum Balance {
        /// Available balance
        internal static let avaliableBalance = Localizable.tr("Asset", "cell.balance.avaliableBalance")
        /// In order
        internal static let inOrderBalance = Localizable.tr("Asset", "cell.balance.inOrderBalance")
        /// Leased
        internal static let leased = Localizable.tr("Asset", "cell.balance.leased")
        /// Total
        internal static let totalBalance = Localizable.tr("Asset", "cell.balance.totalBalance")

        internal enum Button {
          /// Exchange
          internal static let exchange = Localizable.tr("Asset", "cell.balance.button.exchange")
          /// Receive
          internal static let receive = Localizable.tr("Asset", "cell.balance.button.receive")
          /// Send
          internal static let send = Localizable.tr("Asset", "cell.balance.button.send")
        }
      }
    }

    internal enum Header {
      /// Last transactions
      internal static let lastTransactions = Localizable.tr("Asset", "header.lastTransactions")
      /// You do not have any transactions
      internal static let notHaveTransactions = Localizable.tr("Asset", "header.notHaveTransactions")
    }
  }
  internal enum InfoPlist {
    /// The camera is needed to scan QR codes
    internal static let nsCameraUsageDescription = Localizable.tr("InfoPlist", "NSCameraUsageDescription")
    /// Authenticate with Face ID
    internal static let nsFaceIDUsageDescription = Localizable.tr("InfoPlist", "NSFaceIDUsageDescription")
  }
  internal enum General {

    internal enum Label {

      internal enum Title {
        /// / My Asset
        internal static let myasset = Localizable.tr("General", "label.title.myasset")
      }
    }

    internal enum Ticker {

      internal enum Title {
        /// Cryptocurrency
        internal static let cryptocurrency = Localizable.tr("General", "ticker.title.cryptocurrency")
        /// Fiat Money
        internal static let fiatmoney = Localizable.tr("General", "ticker.title.fiatmoney")
        /// SPAM
        internal static let spam = Localizable.tr("General", "ticker.title.spam")
        /// Waves Token
        internal static let wavestoken = Localizable.tr("General", "ticker.title.wavestoken")
      }
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
