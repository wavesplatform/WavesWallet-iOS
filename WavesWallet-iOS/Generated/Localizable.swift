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
  internal enum General {

    internal enum History {

      internal enum Transaction {

        internal enum Title {
          /// Create Alias
          internal static let alias = Localizable.tr("General", "history.transaction.title.alias")
          /// Canceled Leasing
          internal static let canceledLeasing = Localizable.tr("General", "history.transaction.title.canceledLeasing")
          /// Data transaction
          internal static let data = Localizable.tr("General", "history.transaction.title.data")
          /// Exchange
          internal static let exchange = Localizable.tr("General", "history.transaction.title.exchange")
          /// Incoming Leasing
          internal static let incomingLeasing = Localizable.tr("General", "history.transaction.title.incomingLeasing")
          /// Received
          internal static let received = Localizable.tr("General", "history.transaction.title.received")
          /// Self-transfer
          internal static let selfTransfer = Localizable.tr("General", "history.transaction.title.selfTransfer")
          /// Sent
          internal static let sent = Localizable.tr("General", "history.transaction.title.sent")
          /// Started Leasing
          internal static let startedLeasing = Localizable.tr("General", "history.transaction.title.startedLeasing")
          /// Token Burn
          internal static let tokenBurn = Localizable.tr("General", "history.transaction.title.tokenBurn")
          /// Token Generation
          internal static let tokenGeneration = Localizable.tr("General", "history.transaction.title.tokenGeneration")
          /// Token Reissue
          internal static let tokenReissue = Localizable.tr("General", "history.transaction.title.tokenReissue")
          /// Unrecognised Transaction
          internal static let unrecognisedTransaction = Localizable.tr("General", "history.transaction.title.unrecognisedTransaction")
        }

        internal enum Value {
          /// Entry in blockchain
          internal static let data = Localizable.tr("General", "history.transaction.value.data")
        }
      }
    }

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
  internal enum DexMyOrders {

    internal enum Label {
      /// Amount
      internal static let amount = Localizable.tr("DexMyOrders", "label.amount")
      /// Nothing Here…\nYou do not have any orders
      internal static let emptyData = Localizable.tr("DexMyOrders", "label.emptyData")
      /// Loading orders…
      internal static let loadingLastTrades = Localizable.tr("DexMyOrders", "label.loadingLastTrades")
      /// Price
      internal static let price = Localizable.tr("DexMyOrders", "label.price")
      /// Status
      internal static let status = Localizable.tr("DexMyOrders", "label.status")
      /// Time
      internal static let time = Localizable.tr("DexMyOrders", "label.time")

      internal enum Status {
        /// Open
        internal static let accepted = Localizable.tr("DexMyOrders", "label.status.accepted")
        /// Cancelled
        internal static let cancelled = Localizable.tr("DexMyOrders", "label.status.cancelled")
        /// Filled
        internal static let filled = Localizable.tr("DexMyOrders", "label.status.filled")
        /// Partial
        internal static let partiallyFilled = Localizable.tr("DexMyOrders", "label.status.partiallyFilled")
      }
    }
  }
  internal enum InfoPlist {
    /// The camera is needed to scan QR codes
    internal static let nsCameraUsageDescription = Localizable.tr("InfoPlist", "NSCameraUsageDescription")
    /// Authenticate with Face ID
    internal static let nsFaceIDUsageDescription = Localizable.tr("InfoPlist", "NSFaceIDUsageDescription")
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

        internal enum Kind {
          /// Not reissuable
          internal static let notReissuable = Localizable.tr("Asset", "cell.assetInfo.kind.notReissuable")
          /// Reissuable
          internal static let reissuable = Localizable.tr("Asset", "cell.assetInfo.kind.reissuable")
          /// Type
          internal static let title = Localizable.tr("Asset", "cell.assetInfo.kind.title")
        }
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
  internal enum Checkbox {

    internal enum Box {
      /// I understand that my funds are held securely on this device, not by a company
      internal static let first = Localizable.tr("Checkbox", "box.first")
      /// I understand that if this app is moved to another device or deleted, my Waves can only be recovered with the backup phrase
      internal static let second = Localizable.tr("Checkbox", "box.second")
      /// Terms of Use
      internal static let termsOfUse = Localizable.tr("Checkbox", "box.termsOfUse")
      /// I have read, understood, and agree to the
      internal static let third = Localizable.tr("Checkbox", "box.third")
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
