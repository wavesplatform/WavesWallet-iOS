// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {
  internal enum DexMyOrders {

    internal enum Label {
      /// Amount
      internal static let amount = Localizable.tr("DexMyOrders", "label.amount")
      /// Price
      internal static let price = Localizable.tr("DexMyOrders", "label.price")
      /// Status
      internal static let status = Localizable.tr("DexMyOrders", "label.status")
      /// Time
      internal static let time = Localizable.tr("DexMyOrders", "label.time")
    }
  }
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
  internal enum DexLastTrades {

    internal enum Button {
      /// BUY
      internal static let buy = Localizable.tr("DexLastTrades", "button.buy")
      /// SELL
      internal static let sell = Localizable.tr("DexLastTrades", "button.sell")
    }

    internal enum Label {
      /// Amount
      internal static let amount = Localizable.tr("DexLastTrades", "label.amount")
      /// Nothing Here…\nThe trading history is empty
      internal static let emptyData = Localizable.tr("DexLastTrades", "label.emptyData")
      /// Loading last trades…
      internal static let loadingLastTrades = Localizable.tr("DexLastTrades", "label.loadingLastTrades")
      /// Price
      internal static let price = Localizable.tr("DexLastTrades", "label.price")
      /// Sum
      internal static let sum = Localizable.tr("DexLastTrades", "label.sum")
      /// Time
      internal static let time = Localizable.tr("DexLastTrades", "label.time")
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
  internal enum History {

    internal enum Navigationbar {
      /// History
      internal static let title = Localizable.tr("History", "navigationBar.title")
    }

    internal enum Segmentedcontrol {
      /// Active Now
      internal static let activeNow = Localizable.tr("History", "segmentedControl.activeNow")
      /// All
      internal static let all = Localizable.tr("History", "segmentedControl.all")
      /// Canceled
      internal static let canceled = Localizable.tr("History", "segmentedControl.canceled")
      /// Exchanged
      internal static let exchanged = Localizable.tr("History", "segmentedControl.exchanged")
      /// Issued
      internal static let issued = Localizable.tr("History", "segmentedControl.issued")
      /// Leased
      internal static let leased = Localizable.tr("History", "segmentedControl.leased")
      /// Received
      internal static let received = Localizable.tr("History", "segmentedControl.received")
      /// Sent
      internal static let sent = Localizable.tr("History", "segmentedControl.sent")
    }

    internal enum Transactioncell {
      /// Create Alias
      internal static let alias = Localizable.tr("History", "transactionCell.alias")
      /// Canceled Leasing
      internal static let canceledLeasing = Localizable.tr("History", "transactionCell.canceledLeasing")
      /// Exchange
      internal static let exchange = Localizable.tr("History", "transactionCell.exchange")
      /// Incoming Leasing
      internal static let incomingLeasing = Localizable.tr("History", "transactionCell.incomingLeasing")
      /// Received
      internal static let received = Localizable.tr("History", "transactionCell.received")
      /// Self-transfer
      internal static let selfTransfer = Localizable.tr("History", "transactionCell.selfTransfer")
      /// Sent
      internal static let sent = Localizable.tr("History", "transactionCell.sent")
      /// Started Leasing
      internal static let startedLeasing = Localizable.tr("History", "transactionCell.startedLeasing")
      /// Token Burn
      internal static let tokenBurn = Localizable.tr("History", "transactionCell.tokenBurn")
      /// Token Generation
      internal static let tokenGeneration = Localizable.tr("History", "transactionCell.tokenGeneration")
      /// Token Reissue
      internal static let tokenReissue = Localizable.tr("History", "transactionCell.tokenReissue")
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
  internal enum DexInfo {

    internal enum Label {
      /// Amount Asset
      internal static let amountAsset = Localizable.tr("DexInfo", "label.amountAsset")
      /// Popular
      internal static let popular = Localizable.tr("DexInfo", "label.popular")
      /// Price Asset
      internal static let priceAsset = Localizable.tr("DexInfo", "label.priceAsset")
    }
  }
  internal enum DexTraderContainer {

    internal enum Button {
      /// Chart
      internal static let chart = Localizable.tr("DexTraderContainer", "button.chart")
      /// Last trades
      internal static let lastTrades = Localizable.tr("DexTraderContainer", "button.lastTrades")
      /// My orders
      internal static let myOrders = Localizable.tr("DexTraderContainer", "button.myOrders")
      /// Orderbook
      internal static let orderbook = Localizable.tr("DexTraderContainer", "button.orderbook")
    }
  }
  internal enum DexOrderBook {

    internal enum Button {
      /// BUY
      internal static let buy = Localizable.tr("DexOrderBook", "button.buy")
      /// SELL
      internal static let sell = Localizable.tr("DexOrderBook", "button.sell")
    }

    internal enum Label {
      /// Amount
      internal static let amount = Localizable.tr("DexOrderBook", "label.amount")
      /// Nothing Here…\nThe order book is empty
      internal static let emptyData = Localizable.tr("DexOrderBook", "label.emptyData")
      /// LAST PRICE
      internal static let lastPrice = Localizable.tr("DexOrderBook", "label.lastPrice")
      /// Loading orderbook…
      internal static let loadingOrderbook = Localizable.tr("DexOrderBook", "label.loadingOrderbook")
      /// Price
      internal static let price = Localizable.tr("DexOrderBook", "label.price")
      /// SPREAD
      internal static let spread = Localizable.tr("DexOrderBook", "label.spread")
      /// Sum
      internal static let sum = Localizable.tr("DexOrderBook", "label.sum")
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
