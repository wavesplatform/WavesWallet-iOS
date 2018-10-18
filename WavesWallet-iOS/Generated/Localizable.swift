// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {
          internal enum Passcode {

    internal enum Button {

      internal enum Forgotpasscode {
        /// Use account password
        internal static var title: String { return Localizable.tr("Passcode", "button.forgotPasscode.title") }
      }
    }

    internal enum Label {

      internal enum Forgotpasscode {
        /// Forgot passcode?
        internal static var title: String { return Localizable.tr("Passcode", "label.forgotPasscode.title") }
      }

      internal enum Passcode {
        /// Create a passcode
        internal static var create: String { return Localizable.tr("Passcode", "label.passcode.create") }
        /// Enter Passcode
        internal static var enter: String { return Localizable.tr("Passcode", "label.passcode.enter") }
        /// Enter old Passcode
        internal static var old: String { return Localizable.tr("Passcode", "label.passcode.old") }
        /// Verify your passcode
        internal static var verify: String { return Localizable.tr("Passcode", "label.passcode.verify") }
      }
    }
  }
          internal enum DexSort {

    internal enum Navigationbar {
      /// Sorting
      internal static var title: String { return Localizable.tr("DexSort", "navigationBar.title") }
    }
  }
          internal enum NewAccount {

    internal enum Avatar {
      /// This avatar is unique. You cannot change it later.
      internal static var detail: String { return Localizable.tr("NewAccount", "avatar.detail") }
      /// Choose your address avatar
      internal static var title: String { return Localizable.tr("NewAccount", "avatar.title") }
    }

    internal enum Backup {

      internal enum Navigation {
        /// New Account
        internal static var title: String { return Localizable.tr("NewAccount", "backup.navigation.title") }
      }
    }

    internal enum Main {

      internal enum Navigation {
        /// New Account
        internal static var title: String { return Localizable.tr("NewAccount", "main.navigation.title") }
      }
    }

    internal enum Secret {

      internal enum Navigation {
        /// New Account
        internal static var title: String { return Localizable.tr("NewAccount", "secret.navigation.title") }
      }
    }

    internal enum Textfield {

      internal enum Accountname {
        /// Account name
        internal static var title: String { return Localizable.tr("NewAccount", "textfield.accountName.title") }
      }

      internal enum Confirmpassword {
        /// Confirm password
        internal static var title: String { return Localizable.tr("NewAccount", "textfield.confirmpassword.title") }
      }

      internal enum Createpassword {
        /// Create a password
        internal static var title: String { return Localizable.tr("NewAccount", "textfield.createpassword.title") }
      }

      internal enum Error {
        /// at least %d characters
        internal static func atleastcharacters(_ p1: Int) -> String {
          return Localizable.tr("NewAccount", "textfield.error.atleastcharacters", p1)
        }
        /// password not match
        internal static var passwordnotmatch: String { return Localizable.tr("NewAccount", "textfield.error.passwordnotmatch") }
      }
    }
  }
          internal enum Receive {

    internal enum Button {
      /// Card
      internal static var card: String { return Localizable.tr("Receive", "button.card") }
      /// Continue
      internal static var `continue`: String { return Localizable.tr("Receive", "button.continue") }
      /// Сryptocurrency
      internal static var cryptocurrency: String { return Localizable.tr("Receive", "button.cryptocurrency") }
      /// Invoice
      internal static var invoice: String { return Localizable.tr("Receive", "button.invoice") }
      /// Use total balance
      internal static var useTotalBalance: String { return Localizable.tr("Receive", "button.useTotalBalance") }
    }

    internal enum Label {
      /// Amount
      internal static var amount: String { return Localizable.tr("Receive", "label.amount") }
      /// Amount in
      internal static var amountIn: String { return Localizable.tr("Receive", "label.amountIn") }
      /// Asset
      internal static var asset: String { return Localizable.tr("Receive", "label.asset") }
      /// Receive
      internal static var receive: String { return Localizable.tr("Receive", "label.receive") }
      /// Select your asset
      internal static var selectYourAsset: String { return Localizable.tr("Receive", "label.selectYourAsset") }
    }
  }
          internal enum DexCreateOrder {

    internal enum Button {
      /// Ask
      internal static var ask: String { return Localizable.tr("DexCreateOrder", "button.ask") }
      /// Bid
      internal static var bid: String { return Localizable.tr("DexCreateOrder", "button.bid") }
      /// Buy
      internal static var buy: String { return Localizable.tr("DexCreateOrder", "button.buy") }
      /// Cancel
      internal static var cancel: String { return Localizable.tr("DexCreateOrder", "button.cancel") }
      /// day
      internal static var day: String { return Localizable.tr("DexCreateOrder", "button.day") }
      /// days
      internal static var days: String { return Localizable.tr("DexCreateOrder", "button.days") }
      /// hour
      internal static var hour: String { return Localizable.tr("DexCreateOrder", "button.hour") }
      /// Last
      internal static var last: String { return Localizable.tr("DexCreateOrder", "button.last") }
      /// minutes
      internal static var minutes: String { return Localizable.tr("DexCreateOrder", "button.minutes") }
      /// Sell
      internal static var sell: String { return Localizable.tr("DexCreateOrder", "button.sell") }
      /// Use total balance
      internal static var useTotalBalanace: String { return Localizable.tr("DexCreateOrder", "button.useTotalBalanace") }
      /// week
      internal static var week: String { return Localizable.tr("DexCreateOrder", "button.week") }
    }

    internal enum Label {
      /// Amount in
      internal static var amountIn: String { return Localizable.tr("DexCreateOrder", "label.amountIn") }
      /// Value is too big
      internal static var bigValue: String { return Localizable.tr("DexCreateOrder", "label.bigValue") }
      /// days
      internal static var days: String { return Localizable.tr("DexCreateOrder", "label.days") }
      /// Expiration
      internal static var expiration: String { return Localizable.tr("DexCreateOrder", "label.Expiration") }
      /// Fee
      internal static var fee: String { return Localizable.tr("DexCreateOrder", "label.fee") }
      /// Limit Price in
      internal static var limitPriceIn: String { return Localizable.tr("DexCreateOrder", "label.limitPriceIn") }
      /// Not enough
      internal static var notEnough: String { return Localizable.tr("DexCreateOrder", "label.notEnough") }
      /// Total in
      internal static var totalIn: String { return Localizable.tr("DexCreateOrder", "label.totalIn") }
    }
  }
          internal enum AddressBook {

    internal enum Label {
      /// Address book
      internal static var addressBook: String { return Localizable.tr("AddressBook", "label.addressBook") }
      /// Address deleted
      internal static var addressDeleted: String { return Localizable.tr("AddressBook", "label.addressDeleted") }
      /// Nothing Here…\nYou can create new address
      internal static var noInfo: String { return Localizable.tr("AddressBook", "label.noInfo") }
    }
  }
          internal enum DexLastTrades {

    internal enum Button {
      /// BUY
      internal static var buy: String { return Localizable.tr("DexLastTrades", "button.buy") }
      /// SELL
      internal static var sell: String { return Localizable.tr("DexLastTrades", "button.sell") }
    }

    internal enum Label {
      /// Amount
      internal static var amount: String { return Localizable.tr("DexLastTrades", "label.amount") }
      /// Nothing Here…\nThe trading history is empty
      internal static var emptyData: String { return Localizable.tr("DexLastTrades", "label.emptyData") }
      /// Loading last trades…
      internal static var loadingLastTrades: String { return Localizable.tr("DexLastTrades", "label.loadingLastTrades") }
      /// Price
      internal static var price: String { return Localizable.tr("DexLastTrades", "label.price") }
      /// Sum
      internal static var sum: String { return Localizable.tr("DexLastTrades", "label.sum") }
      /// Time
      internal static var time: String { return Localizable.tr("DexLastTrades", "label.time") }
    }
  }
          internal enum ChooseAccount {

    internal enum Alert {

      internal enum Button {
        /// Cancel
        internal static var no: String { return Localizable.tr("ChooseAccount", "alert.button.no") }
        /// Yes
        internal static var ok: String { return Localizable.tr("ChooseAccount", "alert.button.ok") }
      }

      internal enum Delete {
        /// Are you sure you want to delete this account?
        internal static var message: String { return Localizable.tr("ChooseAccount", "alert.delete.message") }
        /// Delete account
        internal static var title: String { return Localizable.tr("ChooseAccount", "alert.delete.title") }
      }
    }

    internal enum Label {
      /// Nothing Here…\nYou do not have saved accounts
      internal static var nothingWallets: String { return Localizable.tr("ChooseAccount", "label.nothingWallets") }
    }

    internal enum Navigation {
      /// Choose account
      internal static var title: String { return Localizable.tr("ChooseAccount", "navigation.title") }
    }
  }
          internal enum StartLeasing {

    internal enum Button {
      /// Choose from Address book
      internal static var chooseFromAddressBook: String { return Localizable.tr("StartLeasing", "button.chooseFromAddressBook") }
      /// Start Lease
      internal static var startLease: String { return Localizable.tr("StartLeasing", "button.startLease") }
      /// Use total balance
      internal static var useTotalBalanace: String { return Localizable.tr("StartLeasing", "button.useTotalBalanace") }
      /// Use total balance
      internal static var useTotalBalance: String { return Localizable.tr("StartLeasing", "button.useTotalBalance") }
    }

    internal enum Label {
      /// The address is not valid
      internal static var addressIsNotValid: String { return Localizable.tr("StartLeasing", "label.addressIsNotValid") }
      /// Amount
      internal static var amount: String { return Localizable.tr("StartLeasing", "label.amount") }
      /// Balance
      internal static var balance: String { return Localizable.tr("StartLeasing", "label.balance") }
      /// Generator
      internal static var generator: String { return Localizable.tr("StartLeasing", "label.generator") }
      /// Node address...
      internal static var nodeAddress: String { return Localizable.tr("StartLeasing", "label.nodeAddress") }
      /// Not enough
      internal static var notEnough: String { return Localizable.tr("StartLeasing", "label.notEnough") }
      /// Start leasing
      internal static var startLeasing: String { return Localizable.tr("StartLeasing", "label.startLeasing") }
      /// Transaction Fee
      internal static var transactionFee: String { return Localizable.tr("StartLeasing", "label.transactionFee") }
    }
  }
          internal enum Enter {

    internal enum Block {

      internal enum Blockchain {
        /// Become part of a fast-growing area of the crypto world. You are the only person who can access your crypto assets.
        internal static var text: String { return Localizable.tr("Enter", "block.blockchain.text") }
        /// Get Started with Blockchain
        internal static var title: String { return Localizable.tr("Enter", "block.blockchain.title") }
      }

      internal enum Exchange {
        /// Trade quickly and securely. You retain complete control over your funds when trading them on our decentralised exchange.
        internal static var text: String { return Localizable.tr("Enter", "block.exchange.text") }
        /// Decentralised Exchange
        internal static var title: String { return Localizable.tr("Enter", "block.exchange.title") }
      }

      internal enum Token {
        /// Issue your own tokens. These can be integrated into your business not only as an internal currency but also as a token for decentralised voting, as a rating system, or loyalty program.
        internal static var text: String { return Localizable.tr("Enter", "block.token.text") }
        /// Token Launcher
        internal static var title: String { return Localizable.tr("Enter", "block.token.title") }
      }

      internal enum Wallet {
        /// Store, manage and receive interest on your digital assets balance, easily and securely.
        internal static var text: String { return Localizable.tr("Enter", "block.wallet.text") }
        /// Wallet
        internal static var title: String { return Localizable.tr("Enter", "block.wallet.title") }
      }
    }

    internal enum Button {

      internal enum Confirm {
        /// Confirm
        internal static var title: String { return Localizable.tr("Enter", "button.confirm.title") }
      }

      internal enum Createnewaccount {
        /// Create a new account
        internal static var title: String { return Localizable.tr("Enter", "button.createNewAccount.title") }
      }

      internal enum Importaccount {
        /// via paring code or manually
        internal static var detail: String { return Localizable.tr("Enter", "button.importAccount.detail") }
        /// Import account
        internal static var title: String { return Localizable.tr("Enter", "button.importAccount.title") }
      }

      internal enum Signin {
        /// to a saved account
        internal static var detail: String { return Localizable.tr("Enter", "button.signIn.detail") }
        /// Sign in
        internal static var title: String { return Localizable.tr("Enter", "button.signIn.title") }
      }
    }

    internal enum Language {

      internal enum Navigation {
        /// Change language
        internal static var title: String { return Localizable.tr("Enter", "language.navigation.title") }
      }
    }
  }
          internal enum Send {

    internal enum Button {
      /// Choose from Address book
      internal static var chooseFromAddressBook: String { return Localizable.tr("Send", "button.chooseFromAddressBook") }
      /// Continue
      internal static var `continue`: String { return Localizable.tr("Send", "button.continue") }
    }

    internal enum Label {
      /// The address is not valid
      internal static var addressNotValid: String { return Localizable.tr("Send", "label.addressNotValid") }
      /// Amount
      internal static var amount: String { return Localizable.tr("Send", "label.amount") }
      /// US Dollar
      internal static var dollar: String { return Localizable.tr("Send", "label.dollar") }
      /// Gateway fee is
      internal static var gatewayFee: String { return Localizable.tr("Send", "label.gatewayFee") }
      /// Recipient
      internal static var recipient: String { return Localizable.tr("Send", "label.recipient") }
      /// Recipient address…
      internal static var recipientAddress: String { return Localizable.tr("Send", "label.recipientAddress") }
      /// Send
      internal static var send: String { return Localizable.tr("Send", "label.send") }
      /// Transaction Fee
      internal static var transactionFee: String { return Localizable.tr("Send", "label.transactionFee") }

      internal enum Warning {
        /// Do not withdraw %@ to an ICO. We will not credit your account with tokens from that sale.
        internal static func description(_ p1: String) -> String {
          return Localizable.tr("Send", "label.warning.description", p1)
        }
        /// We detected %@ address and will send your money through Coinomat gateway to that address. Minimum amount is %@, maximum amount is %@.
        internal static func subtitle(_ p1: String, _ p2: String, _ p3: String) -> String {
          return Localizable.tr("Send", "label.warning.subtitle", p1, p2, p3)
        }
      }
    }
  }
          internal enum DexInfo {

    internal enum Label {
      /// Amount Asset
      internal static var amountAsset: String { return Localizable.tr("DexInfo", "label.amountAsset") }
      /// Popular
      internal static var popular: String { return Localizable.tr("DexInfo", "label.popular") }
      /// Price Asset
      internal static var priceAsset: String { return Localizable.tr("DexInfo", "label.priceAsset") }
    }
  }
          internal enum TransactionHistory {

    internal enum Button {
      /// Copied
      internal static var copied: String { return Localizable.tr("TransactionHistory", "button.copied") }
      /// Copy all data
      internal static var copyAllData: String { return Localizable.tr("TransactionHistory", "button.copyAllData") }
      /// Copy TX ID
      internal static var copyTXId: String { return Localizable.tr("TransactionHistory", "button.copyTXId") }
    }

    internal enum Cell {
      /// Block
      internal static var block: String { return Localizable.tr("TransactionHistory", "cell.block") }
      /// Confirmations
      internal static var confirmations: String { return Localizable.tr("TransactionHistory", "cell.confirmations") }
      /// Data Transaction
      internal static var dataTransaction: String { return Localizable.tr("TransactionHistory", "cell.dataTransaction") }
      /// Fee
      internal static var fee: String { return Localizable.tr("TransactionHistory", "cell.fee") }
      /// From
      internal static var from: String { return Localizable.tr("TransactionHistory", "cell.from") }
      /// ID
      internal static var id: String { return Localizable.tr("TransactionHistory", "cell.id") }
      /// Leasing to
      internal static var leasingTo: String { return Localizable.tr("TransactionHistory", "cell.leasingTo") }
      /// Not Reissuable
      internal static var notReissuable: String { return Localizable.tr("TransactionHistory", "cell.notReissuable") }
      /// Price
      internal static var price: String { return Localizable.tr("TransactionHistory", "cell.price") }
      /// Received from
      internal static var receivedFrom: String { return Localizable.tr("TransactionHistory", "cell.receivedFrom") }
      /// Recipient
      internal static var recipient: String { return Localizable.tr("TransactionHistory", "cell.recipient") }
      /// Reissuable
      internal static var reissuable: String { return Localizable.tr("TransactionHistory", "cell.reissuable") }
      /// Sent to
      internal static var sentTo: String { return Localizable.tr("TransactionHistory", "cell.sentTo") }

      internal enum Button {
        /// Cancel Leasing
        internal static var cancelLeasing: String { return Localizable.tr("TransactionHistory", "cell.button.cancelLeasing") }
        /// Send again
        internal static var sendAgain: String { return Localizable.tr("TransactionHistory", "cell.button.sendAgain") }
      }

      internal enum Status {
        /// at
        internal static var at: String { return Localizable.tr("TransactionHistory", "cell.status.at") }
        /// Timestamp
        internal static var timestamp: String { return Localizable.tr("TransactionHistory", "cell.status.timestamp") }

        internal enum Button {
          /// Active Now
          internal static var activeNow: String { return Localizable.tr("TransactionHistory", "cell.status.button.activeNow") }
          /// Completed
          internal static var completed: String { return Localizable.tr("TransactionHistory", "cell.status.button.completed") }
          /// Unconfirmed
          internal static var unconfirmed: String { return Localizable.tr("TransactionHistory", "cell.status.button.unconfirmed") }
        }
      }
    }

    internal enum Copy {
      /// Amount
      internal static var amount: String { return Localizable.tr("TransactionHistory", "copy.amount") }
      /// Date
      internal static var date: String { return Localizable.tr("TransactionHistory", "copy.date") }
      /// Fee
      internal static var fee: String { return Localizable.tr("TransactionHistory", "copy.fee") }
      /// Recipient
      internal static var recipient: String { return Localizable.tr("TransactionHistory", "copy.recipient") }
      /// Sender
      internal static var sender: String { return Localizable.tr("TransactionHistory", "copy.sender") }
      /// Transaction ID
      internal static var transactionId: String { return Localizable.tr("TransactionHistory", "copy.transactionId") }
      /// Type
      internal static var type: String { return Localizable.tr("TransactionHistory", "copy.type") }
    }
  }
          internal enum DexTraderContainer {

    internal enum Button {
      /// Chart
      internal static var chart: String { return Localizable.tr("DexTraderContainer", "button.chart") }
      /// Last trades
      internal static var lastTrades: String { return Localizable.tr("DexTraderContainer", "button.lastTrades") }
      /// My orders
      internal static var myOrders: String { return Localizable.tr("DexTraderContainer", "button.myOrders") }
      /// Orderbook
      internal static var orderbook: String { return Localizable.tr("DexTraderContainer", "button.orderbook") }
    }
  }
          internal enum DexChart {

    internal enum Button {
      /// Cancel
      internal static var cancel: String { return Localizable.tr("DexChart", "button.cancel") }
    }

    internal enum Label {
      /// No chart data available
      internal static var emptyData: String { return Localizable.tr("DexChart", "label.emptyData") }
      /// hour
      internal static var hour: String { return Localizable.tr("DexChart", "label.hour") }
      /// hours
      internal static var hours: String { return Localizable.tr("DexChart", "label.hours") }
      /// Loading chart…
      internal static var loadingChart: String { return Localizable.tr("DexChart", "label.loadingChart") }
      /// minutes
      internal static var minutes: String { return Localizable.tr("DexChart", "label.minutes") }
    }
  }
          internal enum ReceiveAddress {

    internal enum Button {
      /// Cancel
      internal static var cancel: String { return Localizable.tr("ReceiveAddress", "button.cancel") }
      /// Close
      internal static var close: String { return Localizable.tr("ReceiveAddress", "button.close") }
      /// Сopied!
      internal static var copied: String { return Localizable.tr("ReceiveAddress", "button.copied") }
      /// Copy
      internal static var copy: String { return Localizable.tr("ReceiveAddress", "button.copy") }
      /// Share
      internal static var share: String { return Localizable.tr("ReceiveAddress", "button.share") }
    }

    internal enum Label {
      /// Link to an Invoice
      internal static var linkToInvoice: String { return Localizable.tr("ReceiveAddress", "label.linkToInvoice") }
      /// Your %@ address
      internal static func yourAddress(_ p1: String) -> String {
        return Localizable.tr("ReceiveAddress", "label.yourAddress", p1)
      }
      /// Your QR Code
      internal static var yourQRCode: String { return Localizable.tr("ReceiveAddress", "label.yourQRCode") }
    }
  }
          internal enum DexMyOrders {

    internal enum Label {
      /// Amount
      internal static var amount: String { return Localizable.tr("DexMyOrders", "label.amount") }
      /// Nothing Here…\nYou do not have any orders
      internal static var emptyData: String { return Localizable.tr("DexMyOrders", "label.emptyData") }
      /// Loading orders…
      internal static var loadingLastTrades: String { return Localizable.tr("DexMyOrders", "label.loadingLastTrades") }
      /// Price
      internal static var price: String { return Localizable.tr("DexMyOrders", "label.price") }
      /// Status
      internal static var status: String { return Localizable.tr("DexMyOrders", "label.status") }
      /// Time
      internal static var time: String { return Localizable.tr("DexMyOrders", "label.time") }

      internal enum Status {
        /// Open
        internal static var accepted: String { return Localizable.tr("DexMyOrders", "label.status.accepted") }
        /// Cancelled
        internal static var cancelled: String { return Localizable.tr("DexMyOrders", "label.status.cancelled") }
        /// Filled
        internal static var filled: String { return Localizable.tr("DexMyOrders", "label.status.filled") }
        /// Partial
        internal static var partiallyFilled: String { return Localizable.tr("DexMyOrders", "label.status.partiallyFilled") }
      }
    }
  }
          internal enum InfoPlist {
    /// The camera is needed to scan QR codes
    internal static var nsCameraUsageDescription: String { return Localizable.tr("InfoPlist", "NSCameraUsageDescription") }
    /// Authenticate with Face ID
    internal static var nsFaceIDUsageDescription: String { return Localizable.tr("InfoPlist", "NSFaceIDUsageDescription") }
  }
          internal enum AssetList {

    internal enum Button {
      /// All list
      internal static var allList: String { return Localizable.tr("AssetList", "button.allList") }
      /// My list
      internal static var myList: String { return Localizable.tr("AssetList", "button.myList") }
    }

    internal enum Label {
      /// Assets
      internal static var assets: String { return Localizable.tr("AssetList", "label.assets") }
      /// Loading assets…
      internal static var loadingAssets: String { return Localizable.tr("AssetList", "label.loadingAssets") }
    }
  }
          internal enum Wallet {

    internal enum Button {
      /// Start Lease
      internal static var startLease: String { return Localizable.tr("Wallet", "button.startLease") }
    }

    internal enum Label {
      /// Available
      internal static var available: String { return Localizable.tr("Wallet", "label.available") }
      /// Leased
      internal static var leased: String { return Localizable.tr("Wallet", "label.leased") }
      /// Leased in
      internal static var leasedIn: String { return Localizable.tr("Wallet", "label.leasedIn") }
      /// Started Leasing
      internal static var startedLeasing: String { return Localizable.tr("Wallet", "label.startedLeasing") }
      /// Total balance
      internal static var totalBalance: String { return Localizable.tr("Wallet", "label.totalBalance") }
      /// View history
      internal static var viewHistory: String { return Localizable.tr("Wallet", "label.viewHistory") }

      internal enum Quicknote {

        internal enum Description {
          /// You can only transfer or trade WAVES that aren’t leased. The leased amount cannot be transferred or traded by you or anyone else.
          internal static var first: String { return Localizable.tr("Wallet", "label.quickNote.description.first") }
          /// You can cancel a leasing transaction as soon as it appears in the blockchain which usually occurs in a minute or less.
          internal static var second: String { return Localizable.tr("Wallet", "label.quickNote.description.second") }
          /// The generating balance will be updated after 1000 blocks.
          internal static var third: String { return Localizable.tr("Wallet", "label.quickNote.description.third") }
        }
      }
    }

    internal enum Navigationbar {
      /// Wallet
      internal static var title: String { return Localizable.tr("Wallet", "navigationBar.title") }
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
      internal static var quickNote: String { return Localizable.tr("Wallet", "section.quickNote") }
      /// Spam assets (%d)
      internal static func spamAssets(_ p1: Int) -> String {
        return Localizable.tr("Wallet", "section.spamAssets", p1)
      }
    }

    internal enum Segmentedcontrol {
      /// Assets
      internal static var assets: String { return Localizable.tr("Wallet", "segmentedControl.assets") }
      /// Leasing
      internal static var leasing: String { return Localizable.tr("Wallet", "segmentedControl.leasing") }
    }
  }
          internal enum AddAddressBook {

    internal enum Button {
      /// Cancel
      internal static var cancel: String { return Localizable.tr("AddAddressBook", "button.cancel") }
      /// Delete
      internal static var delete: String { return Localizable.tr("AddAddressBook", "button.delete") }
      /// Delete address
      internal static var deleteAddress: String { return Localizable.tr("AddAddressBook", "button.deleteAddress") }
      /// Save
      internal static var save: String { return Localizable.tr("AddAddressBook", "button.save") }
    }

    internal enum Label {
      /// Add
      internal static var add: String { return Localizable.tr("AddAddressBook", "label.add") }
      /// Address
      internal static var address: String { return Localizable.tr("AddAddressBook", "label.address") }
      /// Are you sure you want to delete address form address book?
      internal static var deleteAlertMessage: String { return Localizable.tr("AddAddressBook", "label.deleteAlertMessage") }
      /// Edit
      internal static var edit: String { return Localizable.tr("AddAddressBook", "label.edit") }
      /// Name
      internal static var name: String { return Localizable.tr("AddAddressBook", "label.name") }
    }
  }
          internal enum WalletSort {

    internal enum Button {
      /// Position
      internal static var position: String { return Localizable.tr("WalletSort", "button.position") }
      /// Visibility
      internal static var visibility: String { return Localizable.tr("WalletSort", "button.visibility") }
    }

    internal enum Navigationbar {
      /// Sorting
      internal static var title: String { return Localizable.tr("WalletSort", "navigationBar.title") }
    }
  }
          internal enum ReceiveCardComplete {

    internal enum Button {
      /// Okay
      internal static var okay: String { return Localizable.tr("ReceiveCardComplete", "button.okay") }
    }

    internal enum Label {
      /// After payment has been made your balance will be updated
      internal static var afterPaymentUpdateBalance: String { return Localizable.tr("ReceiveCardComplete", "label.afterPaymentUpdateBalance") }
      /// You have been redirected to «Indacoin»
      internal static var redirectToIndacoin: String { return Localizable.tr("ReceiveCardComplete", "label.redirectToIndacoin") }
    }
  }
          internal enum DexCompleteOrder {

    internal enum Button {
      /// Okay
      internal static var okey: String { return Localizable.tr("DexCompleteOrder", "button.okey") }
    }

    internal enum Label {
      /// Amount
      internal static var amount: String { return Localizable.tr("DexCompleteOrder", "label.amount") }
      /// Open
      internal static var `open`: String { return Localizable.tr("DexCompleteOrder", "label.open") }
      /// The order is created
      internal static var orderIsCreated: String { return Localizable.tr("DexCompleteOrder", "label.orderIsCreated") }
      /// Price
      internal static var price: String { return Localizable.tr("DexCompleteOrder", "label.price") }
      /// Status
      internal static var status: String { return Localizable.tr("DexCompleteOrder", "label.status") }
      /// Time
      internal static var time: String { return Localizable.tr("DexCompleteOrder", "label.time") }
    }
  }
          internal enum DexMarket {

    internal enum Label {
      /// Loading markets…
      internal static var loadingMarkets: String { return Localizable.tr("DexMarket", "label.loadingMarkets") }
    }

    internal enum Navigationbar {
      /// Markets
      internal static var title: String { return Localizable.tr("DexMarket", "navigationBar.title") }
    }

    internal enum Searchbar {
      /// Search
      internal static var placeholder: String { return Localizable.tr("DexMarket", "searchBar.placeholder") }
    }
  }
          internal enum Backup {

    internal enum Confirmbackup {

      internal enum Button {
        /// Confirm
        internal static var confirm: String { return Localizable.tr("Backup", "confirmbackup.button.confirm") }
      }

      internal enum Error {
        /// Wrong order, try again
        internal static var label: String { return Localizable.tr("Backup", "confirmbackup.error.label") }
      }

      internal enum Info {
        /// Please, tap each word in the correct order
        internal static var label: String { return Localizable.tr("Backup", "confirmbackup.info.label") }
      }

      internal enum Navigation {
        /// Confirm backup
        internal static var title: String { return Localizable.tr("Backup", "confirmbackup.navigation.title") }
      }
    }

    internal enum Infobackup {

      internal enum Button {
        /// I understand
        internal static var iunderstand: String { return Localizable.tr("Backup", "infobackup.button.iunderstand") }
      }

      internal enum Label {
        /// Waves Platform would like to warn you about the increased frequency of scam and phishing attacks over the last month. Fraudsters are hiding their malware in their own versions of the Waves client and promising bonuses and discounts to lure in users.\n \n Please be careful and never input your SEED into these 'clients', because your account will be compromised and you will lose all of your funds.\n \nYou should ONLY use the official Waves client.
        internal static var detail: String { return Localizable.tr("Backup", "infobackup.label.detail") }
        /// Treat your backup phrase with care!
        internal static var title: String { return Localizable.tr("Backup", "infobackup.label.title") }
      }
    }

    internal enum Needbackup {

      internal enum Button {
        /// Back Up Now
        internal static var backupnow: String { return Localizable.tr("Backup", "needbackup.button.backupnow") }
        /// Do it later
        internal static var doitlater: String { return Localizable.tr("Backup", "needbackup.button.doitlater") }
      }

      internal enum Label {
        /// You must save the secret phrase. It is crucial for accessing your account.
        internal static var detail: String { return Localizable.tr("Backup", "needbackup.label.detail") }
        /// No Backup, No Money
        internal static var title: String { return Localizable.tr("Backup", "needbackup.label.title") }
      }
    }

    internal enum Savebackup {

      internal enum Copy {

        internal enum Label {
          /// Please carefully write down these 15 words or copy them
          internal static var title: String { return Localizable.tr("Backup", "savebackup.copy.label.title") }
        }
      }

      internal enum Label {
        /// Since only you control your money, you’ll need to save your backup phrase in case this app is deleted or go back
        internal static var title: String { return Localizable.tr("Backup", "savebackup.label.title") }
      }

      internal enum Navigation {
        /// Save backup phrase
        internal static var title: String { return Localizable.tr("Backup", "savebackup.navigation.title") }
      }

      internal enum Next {

        internal enum Button {
          /// I've written it down
          internal static var title: String { return Localizable.tr("Backup", "savebackup.next.button.title") }
        }

        internal enum Label {
          /// You will confirm this phrase on the next screen
          internal static var title: String { return Localizable.tr("Backup", "savebackup.next.label.title") }
        }
      }
    }
  }
          internal enum ChangePassword {

    internal enum Button {

      internal enum Confirm {
        /// Confirm
        internal static var title: String { return Localizable.tr("ChangePassword", "button.confirm.title") }
      }
    }

    internal enum Navigation {
      /// Changed password
      internal static var title: String { return Localizable.tr("ChangePassword", "navigation.title") }
    }

    internal enum Textfield {

      internal enum Confirmpassword {
        /// Confirm password
        internal static var title: String { return Localizable.tr("ChangePassword", "textfield.confirmpassword.title") }
      }

      internal enum Createpassword {
        /// New password
        internal static var title: String { return Localizable.tr("ChangePassword", "textfield.createpassword.title") }
      }

      internal enum Error {
        /// at least %d characters
        internal static func atleastcharacters(_ p1: Int) -> String {
          return Localizable.tr("ChangePassword", "textfield.error.atleastcharacters", p1)
        }
        /// incorrect password
        internal static var incorrectpassword: String { return Localizable.tr("ChangePassword", "textfield.error.incorrectpassword") }
        /// password not match
        internal static var passwordnotmatch: String { return Localizable.tr("ChangePassword", "textfield.error.passwordnotmatch") }
      }

      internal enum Oldpassword {
        /// Old password
        internal static var title: String { return Localizable.tr("ChangePassword", "textfield.oldpassword.title") }
      }
    }
  }
          internal enum ReceiveCard {

    internal enum Button {
      /// Cancel
      internal static var cancel: String { return Localizable.tr("ReceiveCard", "button.cancel") }
    }

    internal enum Label {
      /// Change currency
      internal static var changeCurrency: String { return Localizable.tr("ReceiveCard", "label.changeCurrency") }
      /// The minimum is %@, the maximum is %@
      internal static func minimunAmountInfo(_ p1: String, _ p2: String) -> String {
        return Localizable.tr("ReceiveCard", "label.minimunAmountInfo", p1, p2)
      }
      /// For making a payment from your card you will be redirected to the merchant's website
      internal static var warningInfo: String { return Localizable.tr("ReceiveCard", "label.warningInfo") }
    }
  }
          internal enum ReceiveInvoice {

    internal enum Label {
      /// US Dollar
      internal static var dollar: String { return Localizable.tr("ReceiveInvoice", "label.dollar") }
    }
  }
          internal enum DexOrderBook {

    internal enum Button {
      /// BUY
      internal static var buy: String { return Localizable.tr("DexOrderBook", "button.buy") }
      /// SELL
      internal static var sell: String { return Localizable.tr("DexOrderBook", "button.sell") }
    }

    internal enum Label {
      /// Amount
      internal static var amount: String { return Localizable.tr("DexOrderBook", "label.amount") }
      /// Nothing Here…\nThe order book is empty
      internal static var emptyData: String { return Localizable.tr("DexOrderBook", "label.emptyData") }
      /// LAST PRICE
      internal static var lastPrice: String { return Localizable.tr("DexOrderBook", "label.lastPrice") }
      /// Loading orderbook…
      internal static var loadingOrderbook: String { return Localizable.tr("DexOrderBook", "label.loadingOrderbook") }
      /// Price
      internal static var price: String { return Localizable.tr("DexOrderBook", "label.price") }
      /// SPREAD
      internal static var spread: String { return Localizable.tr("DexOrderBook", "label.spread") }
      /// Sum
      internal static var sum: String { return Localizable.tr("DexOrderBook", "label.sum") }
    }
  }
          internal enum ReceiveCryptocurrency {

    internal enum Label {
      /// The minimum amount of deposit is %@
      internal static func minumumAmountOfDeposit(_ p1: String) -> String {
        return Localizable.tr("ReceiveCryptocurrency", "label.minumumAmountOfDeposit", p1)
      }
      /// Send only %@ to this deposit address
      internal static func sendOnlyOnThisDeposit(_ p1: String) -> String {
        return Localizable.tr("ReceiveCryptocurrency", "label.sendOnlyOnThisDeposit", p1)
      }
      /// If you will send less than %@, you will lose that money.
      internal static func warningMinimumAmountOfDeposit(_ p1: String) -> String {
        return Localizable.tr("ReceiveCryptocurrency", "label.warningMinimumAmountOfDeposit", p1)
      }
      /// Sending any other currency to this address may result in the loss of your deposit.
      internal static var warningSendOnlyOnThisDeposit: String { return Localizable.tr("ReceiveCryptocurrency", "label.warningSendOnlyOnThisDeposit") }
    }
  }
          internal enum DexList {

    internal enum Button {
      /// Add Markets
      internal static var addMarkets: String { return Localizable.tr("DexList", "button.addMarkets") }
    }

    internal enum Label {
      /// Decentralised Exchange
      internal static var decentralisedExchange: String { return Localizable.tr("DexList", "label.decentralisedExchange") }
      /// Trade quickly and securely. You retain complete control over your funds when trading them on our decentralised exchange.
      internal static var description: String { return Localizable.tr("DexList", "label.description") }
      /// Last update
      internal static var lastUpdate: String { return Localizable.tr("DexList", "label.lastUpdate") }
      /// Price
      internal static var price: String { return Localizable.tr("DexList", "label.price") }
      /// today
      internal static var today: String { return Localizable.tr("DexList", "label.today") }
      /// yesterday
      internal static var yesterday: String { return Localizable.tr("DexList", "label.yesterday") }
    }

    internal enum Navigationbar {
      /// Dex
      internal static var title: String { return Localizable.tr("DexList", "navigationBar.title") }
    }
  }
          internal enum UseTouchID {

    internal enum Button {

      internal enum Notnow {
        /// Not now
        internal static var text: String { return Localizable.tr("UseTouchID", "button.notNow.text") }
      }

      internal enum Usebiometric {
        /// Use %@
        internal static func text(_ p1: String) -> String {
          return Localizable.tr("UseTouchID", "button.useBiometric.text", p1)
        }
      }
    }

    internal enum Label {

      internal enum Detail {
        /// Use your %@ for faster, easier access to your account
        internal static func text(_ p1: String) -> String {
          return Localizable.tr("UseTouchID", "label.detail.text", p1)
        }
      }

      internal enum Title {
        /// Use %@ to sign in?
        internal static func text(_ p1: String) -> String {
          return Localizable.tr("UseTouchID", "label.title.text", p1)
        }
      }
    }
  }
          internal enum General {

    internal enum Biometric {

      internal enum Faceid {
        /// Face ID
        internal static var title: String { return Localizable.tr("General", "biometric.faceID.title") }
      }

      internal enum Touchid {
        /// Touch ID
        internal static var title: String { return Localizable.tr("General", "biometric.touchID.title") }
      }
    }

    internal enum History {

      internal enum Transaction {

        internal enum Title {
          /// Create Alias
          internal static var alias: String { return Localizable.tr("General", "history.transaction.title.alias") }
          /// Canceled Leasing
          internal static var canceledLeasing: String { return Localizable.tr("General", "history.transaction.title.canceledLeasing") }
          /// Data transaction
          internal static var data: String { return Localizable.tr("General", "history.transaction.title.data") }
          /// Exchange
          internal static var exchange: String { return Localizable.tr("General", "history.transaction.title.exchange") }
          /// Incoming Leasing
          internal static var incomingLeasing: String { return Localizable.tr("General", "history.transaction.title.incomingLeasing") }
          /// Received
          internal static var received: String { return Localizable.tr("General", "history.transaction.title.received") }
          /// Self-transfer
          internal static var selfTransfer: String { return Localizable.tr("General", "history.transaction.title.selfTransfer") }
          /// Sent
          internal static var sent: String { return Localizable.tr("General", "history.transaction.title.sent") }
          /// Started Leasing
          internal static var startedLeasing: String { return Localizable.tr("General", "history.transaction.title.startedLeasing") }
          /// Token Burn
          internal static var tokenBurn: String { return Localizable.tr("General", "history.transaction.title.tokenBurn") }
          /// Token Generation
          internal static var tokenGeneration: String { return Localizable.tr("General", "history.transaction.title.tokenGeneration") }
          /// Token Reissue
          internal static var tokenReissue: String { return Localizable.tr("General", "history.transaction.title.tokenReissue") }
          /// Unrecognised Transaction
          internal static var unrecognisedTransaction: String { return Localizable.tr("General", "history.transaction.title.unrecognisedTransaction") }
        }

        internal enum Value {
          /// Entry in blockchain
          internal static var data: String { return Localizable.tr("General", "history.transaction.value.data") }
        }
      }
    }

    internal enum Label {

      internal enum Title {
        /// / My Asset
        internal static var myasset: String { return Localizable.tr("General", "label.title.myasset") }
      }
    }

    internal enum Tabbar {

      internal enum Title {
        /// DEX
        internal static var dex: String { return Localizable.tr("General", "tabbar.title.dex") }
        /// History
        internal static var history: String { return Localizable.tr("General", "tabbar.title.history") }
        /// Profile
        internal static var profile: String { return Localizable.tr("General", "tabbar.title.profile") }
        /// Wallet
        internal static var wallet: String { return Localizable.tr("General", "tabbar.title.wallet") }
      }
    }

    internal enum Ticker {

      internal enum Title {
        /// Cryptocurrency
        internal static var cryptocurrency: String { return Localizable.tr("General", "ticker.title.cryptocurrency") }
        /// Fiat Money
        internal static var fiatmoney: String { return Localizable.tr("General", "ticker.title.fiatmoney") }
        /// SPAM
        internal static var spam: String { return Localizable.tr("General", "ticker.title.spam") }
        /// Waves Token
        internal static var wavestoken: String { return Localizable.tr("General", "ticker.title.wavestoken") }
      }
    }
  }
          internal enum Hello {

    internal enum Button {
      /// Continue
      internal static var `continue`: String { return Localizable.tr("Hello", "button.continue") }
      /// Next
      internal static var next: String { return Localizable.tr("Hello", "button.next") }
      /// I Understand
      internal static var understand: String { return Localizable.tr("Hello", "button.understand") }
    }

    internal enum Page {

      internal enum Info {

        internal enum Fifth {
          /// How To Protect Yourself from Phishers
          internal static var title: String { return Localizable.tr("Hello", "page.info.fifth.title") }

          internal enum Detail {
            /// Do not open emails or links from unknown senders.
            internal static var first: String { return Localizable.tr("Hello", "page.info.fifth.detail.first") }
            /// Do not access your wallet when using public Wi-Fi or someone else’s device.
            internal static var fourth: String { return Localizable.tr("Hello", "page.info.fifth.detail.fourth") }
            /// Regularly update your operating system.
            internal static var second: String { return Localizable.tr("Hello", "page.info.fifth.detail.second") }
            /// Use official security software. Do not install unknown software which could be hacked.
            internal static var third: String { return Localizable.tr("Hello", "page.info.fifth.detail.third") }
          }
        }

        internal enum First {
          /// Please take some time to understand some important things for your own safety. 🙏\n\nWe cannot recover your funds or freeze your account if you visit a phishing site or lose your backup phrase (aka SEED phrase).\n\nBy continuing to use our platform, you agree to accept all risks associated with the loss of your SEED, including but not limited to the inability to obtain your funds and dispose of them. In case you lose your SEED, you agree and acknowledge that the Waves Platform would not be responsible for the negative consequences of this.
          internal static var detail: String { return Localizable.tr("Hello", "page.info.first.detail") }
          /// Welcome to the Waves Platform!
          internal static var title: String { return Localizable.tr("Hello", "page.info.first.title") }
        }

        internal enum Fourth {
          /// One of the most common forms of scamming is phishing, which is when scammers create fake communities on Facebook or other websites that look similar to the authentic ones.
          internal static var detail: String { return Localizable.tr("Hello", "page.info.fourth.detail") }
          /// How To Protect Yourself from Phishers
          internal static var title: String { return Localizable.tr("Hello", "page.info.fourth.title") }
        }

        internal enum Second {
          /// When registering your account, you will be asked to save your secret phrase (Seed) and to protect your account with a password. On normal centralized servers, special attention is paid to the password, which can be changed and reset via email, if the need arises. However, on decentralized platforms such as Waves, everything is arranged differently:
          internal static var detail: String { return Localizable.tr("Hello", "page.info.second.detail") }
          /// What you need to know about your SEED
          internal static var title: String { return Localizable.tr("Hello", "page.info.second.title") }
        }

        internal enum Third {
          /// What you need to know about your SEED
          internal static var title: String { return Localizable.tr("Hello", "page.info.third.title") }

          internal enum Detail {
            /// You use your wallet anonymously, meaning your account is not connected to an email account or any other identifying data.
            internal static var first: String { return Localizable.tr("Hello", "page.info.third.detail.first") }
            /// You cannot change your secret phrase. If you accidentally sent it to someone or suspect that scammers have taken it over, then create a new Waves wallet immediately and transfer your funds to it.
            internal static var fourth: String { return Localizable.tr("Hello", "page.info.third.detail.fourth") }
            /// Your password protects your account when working on a certain device or browser. It is needed in order to ensure that your secret phrase is not saved in storage.
            internal static var second: String { return Localizable.tr("Hello", "page.info.third.detail.second") }
            /// If you forget your password, you can easily create a new one by using the account recovery form via your secret phrase. If you lose your secret phrase, however, you will have no way to access your account.
            internal static var third: String { return Localizable.tr("Hello", "page.info.third.detail.third") }
          }
        }
      }
    }
  }
          internal enum AccountPassword {

    internal enum Button {

      internal enum Signin {
        /// Sign In
        internal static var title: String { return Localizable.tr("AccountPassword", "button.signIn.title") }
      }
    }

    internal enum Textfield {

      internal enum Error {
        /// at least %d characters
        internal static func atleastcharacters(_ p1: Int) -> String {
          return Localizable.tr("AccountPassword", "textfield.error.atleastcharacters", p1)
        }
      }

      internal enum Password {
        /// Account password
        internal static var placeholder: String { return Localizable.tr("AccountPassword", "textfield.password.placeholder") }
      }
    }
  }
          internal enum History {

    internal enum Navigationbar {
      /// History
      internal static var title: String { return Localizable.tr("History", "navigationBar.title") }
    }

    internal enum Segmentedcontrol {
      /// Active Now
      internal static var activeNow: String { return Localizable.tr("History", "segmentedControl.activeNow") }
      /// All
      internal static var all: String { return Localizable.tr("History", "segmentedControl.all") }
      /// Canceled
      internal static var canceled: String { return Localizable.tr("History", "segmentedControl.canceled") }
      /// Exchanged
      internal static var exchanged: String { return Localizable.tr("History", "segmentedControl.exchanged") }
      /// Issued
      internal static var issued: String { return Localizable.tr("History", "segmentedControl.issued") }
      /// Leased
      internal static var leased: String { return Localizable.tr("History", "segmentedControl.leased") }
      /// Received
      internal static var received: String { return Localizable.tr("History", "segmentedControl.received") }
      /// Sent
      internal static var sent: String { return Localizable.tr("History", "segmentedControl.sent") }
    }
  }
          internal enum ReceiveGenerate {

    internal enum Label {
      /// Generate…
      internal static var generate: String { return Localizable.tr("ReceiveGenerate", "label.generate") }
      /// Your %@ address
      internal static func yourAddress(_ p1: String) -> String {
        return Localizable.tr("ReceiveGenerate", "label.yourAddress", p1)
      }
    }
  }
          internal enum Asset {

    internal enum Cell {
      /// View history
      internal static var viewHistory: String { return Localizable.tr("Asset", "cell.viewHistory") }

      internal enum Assetinfo {
        /// Description
        internal static var description: String { return Localizable.tr("Asset", "cell.assetInfo.description") }
        /// ID
        internal static var id: String { return Localizable.tr("Asset", "cell.assetInfo.id") }
        /// Issue date
        internal static var issueDate: String { return Localizable.tr("Asset", "cell.assetInfo.issueDate") }
        /// Issuer
        internal static var issuer: String { return Localizable.tr("Asset", "cell.assetInfo.issuer") }
        /// Name
        internal static var name: String { return Localizable.tr("Asset", "cell.assetInfo.name") }
        /// Asset Info
        internal static var title: String { return Localizable.tr("Asset", "cell.assetInfo.title") }

        internal enum Kind {
          /// Not reissuable
          internal static var notReissuable: String { return Localizable.tr("Asset", "cell.assetInfo.kind.notReissuable") }
          /// Reissuable
          internal static var reissuable: String { return Localizable.tr("Asset", "cell.assetInfo.kind.reissuable") }
          /// Type
          internal static var title: String { return Localizable.tr("Asset", "cell.assetInfo.kind.title") }
        }
      }

      internal enum Balance {
        /// Available balance
        internal static var avaliableBalance: String { return Localizable.tr("Asset", "cell.balance.avaliableBalance") }
        /// In order
        internal static var inOrderBalance: String { return Localizable.tr("Asset", "cell.balance.inOrderBalance") }
        /// Leased
        internal static var leased: String { return Localizable.tr("Asset", "cell.balance.leased") }
        /// Total
        internal static var totalBalance: String { return Localizable.tr("Asset", "cell.balance.totalBalance") }

        internal enum Button {
          /// Exchange
          internal static var exchange: String { return Localizable.tr("Asset", "cell.balance.button.exchange") }
          /// Receive
          internal static var receive: String { return Localizable.tr("Asset", "cell.balance.button.receive") }
          /// Send
          internal static var send: String { return Localizable.tr("Asset", "cell.balance.button.send") }
        }
      }
    }

    internal enum Header {
      /// Last transactions
      internal static var lastTransactions: String { return Localizable.tr("Asset", "header.lastTransactions") }
      /// You do not have any transactions
      internal static var notHaveTransactions: String { return Localizable.tr("Asset", "header.notHaveTransactions") }
    }
  }
          internal enum Profile {

    internal enum Alert {

      internal enum Deleteaccount {
        /// Are you sure you want to delete this account from device?
        internal static var message: String { return Localizable.tr("Profile", "alert.deleteAccount.message") }
        /// Delete account
        internal static var title: String { return Localizable.tr("Profile", "alert.deleteAccount.title") }

        internal enum Button {
          /// Cancel
          internal static var cancel: String { return Localizable.tr("Profile", "alert.deleteAccount.button.cancel") }
          /// Delete
          internal static var delete: String { return Localizable.tr("Profile", "alert.deleteAccount.button.delete") }
        }

        internal enum Withoutbackup {
          /// Deleting an account will lead to its irretrievable loss!
          internal static var message: String { return Localizable.tr("Profile", "alert.deleteAccount.withoutbackup.message") }
        }
      }
    }

    internal enum Button {

      internal enum Delete {
        /// Delete account from device
        internal static var title: String { return Localizable.tr("Profile", "button.delete.title") }
      }

      internal enum Logout {
        /// Logout of account
        internal static var title: String { return Localizable.tr("Profile", "button.logout.title") }
      }
    }

    internal enum Cell {

      internal enum Addressbook {
        /// Address book
        internal static var title: String { return Localizable.tr("Profile", "cell.addressbook.title") }
      }

      internal enum Addresses {
        /// Addresses, keys
        internal static var title: String { return Localizable.tr("Profile", "cell.addresses.title") }
      }

      internal enum Backupphrase {
        /// Backup phrase
        internal static var title: String { return Localizable.tr("Profile", "cell.backupphrase.title") }
      }

      internal enum Changepasscode {
        /// Change passcode
        internal static var title: String { return Localizable.tr("Profile", "cell.changepasscode.title") }
      }

      internal enum Changepassword {
        /// Change password
        internal static var title: String { return Localizable.tr("Profile", "cell.changepassword.title") }
      }

      internal enum Currentheight {
        /// Current height
        internal static var title: String { return Localizable.tr("Profile", "cell.currentheight.title") }
      }

      internal enum Feedback {
        /// Feedback
        internal static var title: String { return Localizable.tr("Profile", "cell.feedback.title") }
      }

      internal enum Info {

        internal enum Currentheight {
          /// Current height
          internal static var title: String { return Localizable.tr("Profile", "cell.info.currentheight.title") }
        }

        internal enum Version {
          /// Version
          internal static var title: String { return Localizable.tr("Profile", "cell.info.version.title") }
        }
      }

      internal enum Language {
        /// Language
        internal static var title: String { return Localizable.tr("Profile", "cell.language.title") }
      }

      internal enum Network {
        /// Network
        internal static var title: String { return Localizable.tr("Profile", "cell.network.title") }
      }

      internal enum Pushnotifications {
        /// Push Notifications
        internal static var title: String { return Localizable.tr("Profile", "cell.pushnotifications.title") }
      }

      internal enum Rateapp {
        /// Rate app
        internal static var title: String { return Localizable.tr("Profile", "cell.rateApp.title") }
      }

      internal enum Supportwavesplatform {
        /// Support Wavesplatform
        internal static var title: String { return Localizable.tr("Profile", "cell.supportwavesplatform.title") }
      }
    }

    internal enum Header {

      internal enum General {
        /// General settings
        internal static var title: String { return Localizable.tr("Profile", "header.general.title") }
      }

      internal enum Other {
        /// Other
        internal static var title: String { return Localizable.tr("Profile", "header.other.title") }
      }

      internal enum Security {
        /// Security
        internal static var title: String { return Localizable.tr("Profile", "header.security.title") }
      }
    }

    internal enum Language {

      internal enum Navigation {
        /// Language
        internal static var title: String { return Localizable.tr("Profile", "language.navigation.title") }
      }
    }

    internal enum Navigation {
      /// Profile
      internal static var title: String { return Localizable.tr("Profile", "navigation.title") }
    }
  }
          internal enum Import {

    internal enum Account {

      internal enum Button {

        internal enum Enter {
          /// Enter seed manually
          internal static var title: String { return Localizable.tr("Import", "account.button.enter.title") }
        }

        internal enum Scan {
          /// Scan pairing code
          internal static var title: String { return Localizable.tr("Import", "account.button.scan.title") }
        }
      }

      internal enum Label {

        internal enum Info {

          internal enum Step {

            internal enum One {
              /// Settings > Security > Pairing code
              internal static var detail: String { return Localizable.tr("Import", "account.label.info.step.one.detail") }
              /// Log in to your Beta Client via your PC or Mac at https://beta.wavesplatform.com
              internal static var title: String { return Localizable.tr("Import", "account.label.info.step.one.title") }
            }

            internal enum Two {
              /// Click «Show Pairing Code» to reveal a QR Code. Scan the code with your camera.
              internal static var title: String { return Localizable.tr("Import", "account.label.info.step.two.title") }
            }
          }
        }
      }

      internal enum Navigation {
        /// Import account
        internal static var title: String { return Localizable.tr("Import", "account.navigation.title") }
      }
    }

    internal enum Welcome {

      internal enum Button {
        /// Continue
        internal static var `continue`: String { return Localizable.tr("Import", "welcome.button.continue") }
      }

      internal enum Label {

        internal enum Address {
          /// Your seed is the 15 words you saved when creating your account
          internal static var placeholder: String { return Localizable.tr("Import", "welcome.label.address.placeholder") }
          /// Your account seed
          internal static var title: String { return Localizable.tr("Import", "welcome.label.address.title") }
        }
      }

      internal enum Navigation {
        /// Welcome back
        internal static var title: String { return Localizable.tr("Import", "welcome.navigation.title") }
      }
    }
  }
          internal enum Checkbox {

    internal enum Box {
      /// I understand that my funds are held securely on this device, not by a company
      internal static var first: String { return Localizable.tr("Checkbox", "box.first") }
      /// I understand that if this app is moved to another device or deleted, my Waves can only be recovered with the backup phrase
      internal static var second: String { return Localizable.tr("Checkbox", "box.second") }
      /// Terms of Use
      internal static var termsOfUse: String { return Localizable.tr("Checkbox", "box.termsOfUse") }
      /// I have read, understood, and agree to the
      internal static var third: String { return Localizable.tr("Checkbox", "box.third") }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension Localizable {

    struct Current {
        var locale: Locale
        var bundle: Bundle
    }

    static var current: Localizable.Current = Localizable.Current(locale: Locale.current, bundle: Bundle(for: BundleToken.self))

    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: table, bundle: current.bundle, comment: "")
        return String(format: format, locale: current.locale, arguments: args)
    }
}

private final class BundleToken {}
