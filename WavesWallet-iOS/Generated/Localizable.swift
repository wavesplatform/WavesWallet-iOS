// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {
          internal enum InfoPlist {
    /// The camera is needed to scan QR codes
    internal static var nsCameraUsageDescription: String { return Localizable.tr("InfoPlist", "NSCameraUsageDescription") }
    /// Access to your wallet
    internal static var nsFaceIDUsageDescription: String { return Localizable.tr("InfoPlist", "NSFaceIDUsageDescription") }
  }
          internal enum Waves {

    internal enum Accountpassword {

      internal enum Button {

        internal enum Signin {
          /// Sign In
          internal static var title: String { return Localizable.tr("Waves", "accountpassword.button.signIn.title") }
        }
      }

      internal enum Textfield {

        internal enum Error {
          /// at least %d characters
          internal static func atleastcharacters(_ p1: Int) -> String {
            return Localizable.tr("Waves", "accountpassword.textfield.error.atleastcharacters", p1)
          }
        }

        internal enum Password {
          /// Account password
          internal static var placeholder: String { return Localizable.tr("Waves", "accountpassword.textfield.password.placeholder") }
        }
      }
    }

    internal enum Addaddressbook {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { return Localizable.tr("Waves", "addAddressbook.button.cancel") }
        /// Delete
        internal static var delete: String { return Localizable.tr("Waves", "addAddressbook.button.delete") }
        /// Delete address
        internal static var deleteAddress: String { return Localizable.tr("Waves", "addAddressbook.button.deleteAddress") }
        /// Save
        internal static var save: String { return Localizable.tr("Waves", "addAddressbook.button.save") }
      }

      internal enum Label {
        /// Add
        internal static var add: String { return Localizable.tr("Waves", "addAddressbook.label.add") }
        /// Address
        internal static var address: String { return Localizable.tr("Waves", "addAddressbook.label.address") }
        /// Are you sure you want to delete address form address book?
        internal static var deleteAlertMessage: String { return Localizable.tr("Waves", "addAddressbook.label.deleteAlertMessage") }
        /// Edit
        internal static var edit: String { return Localizable.tr("Waves", "addAddressbook.label.edit") }
        /// Name
        internal static var name: String { return Localizable.tr("Waves", "addAddressbook.label.name") }
      }
    }

    internal enum Addressbook {

      internal enum Label {
        /// Address book
        internal static var addressBook: String { return Localizable.tr("Waves", "addressbook.label.addressBook") }
        /// Address deleted
        internal static var addressDeleted: String { return Localizable.tr("Waves", "addressbook.label.addressDeleted") }
        /// Nothing Here…\nYou can create new address
        internal static var noInfo: String { return Localizable.tr("Waves", "addressbook.label.noInfo") }
      }
    }

    internal enum Addresseskeys {

      internal enum Cell {

        internal enum Address {
          /// Your address
          internal static var title: String { return Localizable.tr("Waves", "addresseskeys.cell.address.title") }
        }

        internal enum Aliases {

          internal enum Subtitle {
            /// You have %d
            internal static func withaliaces(_ p1: Int) -> String {
              return Localizable.tr("Waves", "addresseskeys.cell.aliases.subtitle.withaliaces", p1)
            }
            /// You do not have
            internal static var withoutaliaces: String { return Localizable.tr("Waves", "addresseskeys.cell.aliases.subtitle.withoutaliaces") }
          }
        }

        internal enum Privatekey {
          /// Private Key
          internal static var title: String { return Localizable.tr("Waves", "addresseskeys.cell.privatekey.title") }
        }

        internal enum Privatekeyhidde {

          internal enum Button {
            /// Show
            internal static var title: String { return Localizable.tr("Waves", "addresseskeys.cell.privatekeyhidde.button.title") }
          }
        }

        internal enum Publickey {
          /// Public Key
          internal static var title: String { return Localizable.tr("Waves", "addresseskeys.cell.publickey.title") }
        }

        internal enum Seed {
          /// Seed
          internal static var title: String { return Localizable.tr("Waves", "addresseskeys.cell.seed.title") }
        }
      }

      internal enum Navigation {
        /// Addresses, keys
        internal static var title: String { return Localizable.tr("Waves", "addresseskeys.navigation.title") }
      }
    }

    internal enum Aliases {

      internal enum Cell {

        internal enum Head {
          /// Your Aliases
          internal static var title: String { return Localizable.tr("Waves", "aliases.cell.head.title") }
        }
      }

      internal enum View {

        internal enum Info {

          internal enum Button {
            /// Create new alias
            internal static var create: String { return Localizable.tr("Waves", "aliases.view.info.button.create") }
          }

          internal enum Label {
            /// Transaction Fee 0.001 Waves
            internal static var fee: String { return Localizable.tr("Waves", "aliases.view.info.label.fee") }
            /// Your Alias must be between 4 and 30 characters long, and must contain only lowercase Latin letters, digits and symbols (@, -, _ etc)
            internal static var secondsubtitle: String { return Localizable.tr("Waves", "aliases.view.info.label.secondsubtitle") }
            /// An Alias is a nickname for your address. You can use an Alias instead of an address to make transactions.
            internal static var subtitle: String { return Localizable.tr("Waves", "aliases.view.info.label.subtitle") }
            /// About Alias
            internal static var title: String { return Localizable.tr("Waves", "aliases.view.info.label.title") }
          }
        }
      }
    }

    internal enum Aliaseswithout {

      internal enum View {

        internal enum Info {

          internal enum Button {
            /// Create new alias
            internal static var create: String { return Localizable.tr("Waves", "aliaseswithout.view.info.button.create") }
          }

          internal enum Label {
            /// Transaction Fee 0.001 Waves
            internal static var fee: String { return Localizable.tr("Waves", "aliaseswithout.view.info.label.fee") }
            /// Your Alias must be between 4 and 30 characters long, and must contain only lowercase Latin letters, digits and symbols (@, -, _ etc)
            internal static var secondsubtitle: String { return Localizable.tr("Waves", "aliaseswithout.view.info.label.secondsubtitle") }
            /// An Alias is a nickname for your address. You can use an Alias instead of an address to make transactions.
            internal static var subtitle: String { return Localizable.tr("Waves", "aliaseswithout.view.info.label.subtitle") }
            /// About Alias
            internal static var title: String { return Localizable.tr("Waves", "aliaseswithout.view.info.label.title") }
          }
        }
      }
    }

    internal enum Asset {

      internal enum Cell {
        /// View history
        internal static var viewHistory: String { return Localizable.tr("Waves", "asset.cell.viewHistory") }

        internal enum Assetinfo {
          /// Description
          internal static var description: String { return Localizable.tr("Waves", "asset.cell.assetInfo.description") }
          /// ID
          internal static var id: String { return Localizable.tr("Waves", "asset.cell.assetInfo.id") }
          /// Issue date
          internal static var issueDate: String { return Localizable.tr("Waves", "asset.cell.assetInfo.issueDate") }
          /// Issuer
          internal static var issuer: String { return Localizable.tr("Waves", "asset.cell.assetInfo.issuer") }
          /// Name
          internal static var name: String { return Localizable.tr("Waves", "asset.cell.assetInfo.name") }
          /// Asset Info
          internal static var title: String { return Localizable.tr("Waves", "asset.cell.assetInfo.title") }

          internal enum Kind {
            /// Not reissuable
            internal static var notReissuable: String { return Localizable.tr("Waves", "asset.cell.assetInfo.kind.notReissuable") }
            /// Reissuable
            internal static var reissuable: String { return Localizable.tr("Waves", "asset.cell.assetInfo.kind.reissuable") }
            /// Type
            internal static var title: String { return Localizable.tr("Waves", "asset.cell.assetInfo.kind.title") }
          }
        }

        internal enum Balance {
          /// Available balance
          internal static var avaliableBalance: String { return Localizable.tr("Waves", "asset.cell.balance.avaliableBalance") }
          /// In order
          internal static var inOrderBalance: String { return Localizable.tr("Waves", "asset.cell.balance.inOrderBalance") }
          /// Leased
          internal static var leased: String { return Localizable.tr("Waves", "asset.cell.balance.leased") }
          /// Total
          internal static var totalBalance: String { return Localizable.tr("Waves", "asset.cell.balance.totalBalance") }

          internal enum Button {
            /// Exchange
            internal static var exchange: String { return Localizable.tr("Waves", "asset.cell.balance.button.exchange") }
            /// Receive
            internal static var receive: String { return Localizable.tr("Waves", "asset.cell.balance.button.receive") }
            /// Send
            internal static var send: String { return Localizable.tr("Waves", "asset.cell.balance.button.send") }
          }
        }
      }

      internal enum Header {
        /// Last transactions
        internal static var lastTransactions: String { return Localizable.tr("Waves", "asset.header.lastTransactions") }
        /// You do not have any transactions
        internal static var notHaveTransactions: String { return Localizable.tr("Waves", "asset.header.notHaveTransactions") }
      }
    }

    internal enum Assetlist {

      internal enum Button {
        /// All list
        internal static var allList: String { return Localizable.tr("Waves", "assetlist.button.allList") }
        /// My list
        internal static var myList: String { return Localizable.tr("Waves", "assetlist.button.myList") }
        /// With balance
        internal static var withBalance: String { return Localizable.tr("Waves", "assetlist.button.withBalance") }
      }

      internal enum Label {
        /// Assets
        internal static var assets: String { return Localizable.tr("Waves", "assetlist.label.assets") }
        /// Loading assets…
        internal static var loadingAssets: String { return Localizable.tr("Waves", "assetlist.label.loadingAssets") }
      }
    }

    internal enum Backup {

      internal enum Confirmbackup {

        internal enum Button {
          /// Confirm
          internal static var confirm: String { return Localizable.tr("Waves", "backup.confirmbackup.button.confirm") }
        }

        internal enum Error {
          /// Wrong order, try again
          internal static var label: String { return Localizable.tr("Waves", "backup.confirmbackup.error.label") }
        }

        internal enum Info {
          /// Please, tap each word in the correct order
          internal static var label: String { return Localizable.tr("Waves", "backup.confirmbackup.info.label") }
        }

        internal enum Navigation {
          /// Confirm backup
          internal static var title: String { return Localizable.tr("Waves", "backup.confirmbackup.navigation.title") }
        }
      }

      internal enum Infobackup {

        internal enum Button {
          /// I understand
          internal static var iunderstand: String { return Localizable.tr("Waves", "backup.infobackup.button.iunderstand") }
        }

        internal enum Label {
          /// Waves Platform would like to warn you about the increased frequency of scam and phishing attacks over the last month. Fraudsters are hiding their malware in their own versions of the Waves client and promising bonuses and discounts to lure in users.\n \n Please be careful and never input your SEED into these 'clients', because your account will be compromised and you will lose all of your funds.\n \nYou should ONLY use the official Waves client.
          internal static var detail: String { return Localizable.tr("Waves", "backup.infobackup.label.detail") }
          /// Treat your backup phrase with care!
          internal static var title: String { return Localizable.tr("Waves", "backup.infobackup.label.title") }
        }
      }

      internal enum Needbackup {

        internal enum Button {
          /// Back Up Now
          internal static var backupnow: String { return Localizable.tr("Waves", "backup.needbackup.button.backupnow") }
          /// Do it later
          internal static var doitlater: String { return Localizable.tr("Waves", "backup.needbackup.button.doitlater") }
        }

        internal enum Label {
          /// You must save the secret phrase. It is crucial for accessing your account.
          internal static var detail: String { return Localizable.tr("Waves", "backup.needbackup.label.detail") }
          /// No Backup, No Money
          internal static var title: String { return Localizable.tr("Waves", "backup.needbackup.label.title") }
        }
      }

      internal enum Savebackup {

        internal enum Copy {

          internal enum Label {
            /// Please carefully write down these 15 words or copy them
            internal static var title: String { return Localizable.tr("Waves", "backup.savebackup.copy.label.title") }
          }
        }

        internal enum Label {
          /// Since only you control your money, you’ll need to save your backup phrase in case this app is deleted or go back
          internal static var title: String { return Localizable.tr("Waves", "backup.savebackup.label.title") }
        }

        internal enum Navigation {
          /// Save backup phrase
          internal static var title: String { return Localizable.tr("Waves", "backup.savebackup.navigation.title") }
        }

        internal enum Next {

          internal enum Button {
            /// I've written it down
            internal static var title: String { return Localizable.tr("Waves", "backup.savebackup.next.button.title") }
          }

          internal enum Label {
            /// You will confirm this phrase on the next screen
            internal static var title: String { return Localizable.tr("Waves", "backup.savebackup.next.label.title") }
          }
        }
      }
    }

    internal enum Changepassword {

      internal enum Button {

        internal enum Confirm {
          /// Confirm
          internal static var title: String { return Localizable.tr("Waves", "changepassword.button.confirm.title") }
        }
      }

      internal enum Navigation {
        /// Changed password
        internal static var title: String { return Localizable.tr("Waves", "changepassword.navigation.title") }
      }

      internal enum Textfield {

        internal enum Confirmpassword {
          /// Confirm password
          internal static var title: String { return Localizable.tr("Waves", "changepassword.textfield.confirmpassword.title") }
        }

        internal enum Createpassword {
          /// New password
          internal static var title: String { return Localizable.tr("Waves", "changepassword.textfield.createpassword.title") }
        }

        internal enum Error {
          /// at least %d characters
          internal static func atleastcharacters(_ p1: Int) -> String {
            return Localizable.tr("Waves", "changepassword.textfield.error.atleastcharacters", p1)
          }
          /// incorrect password
          internal static var incorrectpassword: String { return Localizable.tr("Waves", "changepassword.textfield.error.incorrectpassword") }
          /// password not match
          internal static var passwordnotmatch: String { return Localizable.tr("Waves", "changepassword.textfield.error.passwordnotmatch") }
        }

        internal enum Oldpassword {
          /// Old password
          internal static var title: String { return Localizable.tr("Waves", "changepassword.textfield.oldpassword.title") }
        }
      }
    }

    internal enum Chooseaccount {

      internal enum Alert {

        internal enum Button {
          /// Cancel
          internal static var no: String { return Localizable.tr("Waves", "chooseaccount.alert.button.no") }
          /// Yes
          internal static var ok: String { return Localizable.tr("Waves", "chooseaccount.alert.button.ok") }
        }

        internal enum Delete {
          /// Are you sure you want to delete this account?
          internal static var message: String { return Localizable.tr("Waves", "chooseaccount.alert.delete.message") }
          /// Delete account
          internal static var title: String { return Localizable.tr("Waves", "chooseaccount.alert.delete.title") }
        }
      }

      internal enum Label {
        /// Nothing Here…\nYou do not have saved accounts
        internal static var nothingWallets: String { return Localizable.tr("Waves", "chooseaccount.label.nothingWallets") }
      }

      internal enum Navigation {
        /// Choose account
        internal static var title: String { return Localizable.tr("Waves", "chooseaccount.navigation.title") }
      }
    }

    internal enum Createalias {

      internal enum Button {

        internal enum Create {
          /// Create
          internal static var title: String { return Localizable.tr("Waves", "createalias.button.create.title") }
        }
      }

      internal enum Cell {

        internal enum Input {

          internal enum Textfiled {

            internal enum Input {
              /// Symbolic name
              internal static var placeholder: String { return Localizable.tr("Waves", "createalias.cell.input.textfiled.input.placeholder") }
              /// Symbolic name
              internal static var title: String { return Localizable.tr("Waves", "createalias.cell.input.textfiled.input.title") }
            }
          }
        }
      }

      internal enum Navigation {
        /// New alias
        internal static var title: String { return Localizable.tr("Waves", "createalias.navigation.title") }
      }
    }

    internal enum Dexchart {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { return Localizable.tr("Waves", "dexchart.button.cancel") }
      }

      internal enum Label {
        /// No chart data available
        internal static var emptyData: String { return Localizable.tr("Waves", "dexchart.label.emptyData") }
        /// hour
        internal static var hour: String { return Localizable.tr("Waves", "dexchart.label.hour") }
        /// hours
        internal static var hours: String { return Localizable.tr("Waves", "dexchart.label.hours") }
        /// Loading chart…
        internal static var loadingChart: String { return Localizable.tr("Waves", "dexchart.label.loadingChart") }
        /// minutes
        internal static var minutes: String { return Localizable.tr("Waves", "dexchart.label.minutes") }
      }
    }

    internal enum Dexcompleteorder {

      internal enum Button {
        /// Okay
        internal static var okey: String { return Localizable.tr("Waves", "dexcompleteorder.button.okey") }
      }

      internal enum Label {
        /// Amount
        internal static var amount: String { return Localizable.tr("Waves", "dexcompleteorder.label.amount") }
        /// Open
        internal static var `open`: String { return Localizable.tr("Waves", "dexcompleteorder.label.open") }
        /// The order is created
        internal static var orderIsCreated: String { return Localizable.tr("Waves", "dexcompleteorder.label.orderIsCreated") }
        /// Price
        internal static var price: String { return Localizable.tr("Waves", "dexcompleteorder.label.price") }
        /// Status
        internal static var status: String { return Localizable.tr("Waves", "dexcompleteorder.label.status") }
        /// Time
        internal static var time: String { return Localizable.tr("Waves", "dexcompleteorder.label.time") }
      }
    }

    internal enum Dexcreateorder {

      internal enum Button {
        /// Ask
        internal static var ask: String { return Localizable.tr("Waves", "dexcreateorder.button.ask") }
        /// Bid
        internal static var bid: String { return Localizable.tr("Waves", "dexcreateorder.button.bid") }
        /// Buy
        internal static var buy: String { return Localizable.tr("Waves", "dexcreateorder.button.buy") }
        /// Cancel
        internal static var cancel: String { return Localizable.tr("Waves", "dexcreateorder.button.cancel") }
        /// day
        internal static var day: String { return Localizable.tr("Waves", "dexcreateorder.button.day") }
        /// days
        internal static var days: String { return Localizable.tr("Waves", "dexcreateorder.button.days") }
        /// hour
        internal static var hour: String { return Localizable.tr("Waves", "dexcreateorder.button.hour") }
        /// Last
        internal static var last: String { return Localizable.tr("Waves", "dexcreateorder.button.last") }
        /// minutes
        internal static var minutes: String { return Localizable.tr("Waves", "dexcreateorder.button.minutes") }
        /// Sell
        internal static var sell: String { return Localizable.tr("Waves", "dexcreateorder.button.sell") }
        /// Use total balance
        internal static var useTotalBalanace: String { return Localizable.tr("Waves", "dexcreateorder.button.useTotalBalanace") }
        /// week
        internal static var week: String { return Localizable.tr("Waves", "dexcreateorder.button.week") }
      }

      internal enum Label {
        /// Amount in
        internal static var amountIn: String { return Localizable.tr("Waves", "dexcreateorder.label.amountIn") }
        /// Value is too big
        internal static var bigValue: String { return Localizable.tr("Waves", "dexcreateorder.label.bigValue") }
        /// days
        internal static var days: String { return Localizable.tr("Waves", "dexcreateorder.label.days") }
        /// Expiration
        internal static var expiration: String { return Localizable.tr("Waves", "dexcreateorder.label.Expiration") }
        /// Fee
        internal static var fee: String { return Localizable.tr("Waves", "dexcreateorder.label.fee") }
        /// Limit Price in
        internal static var limitPriceIn: String { return Localizable.tr("Waves", "dexcreateorder.label.limitPriceIn") }
        /// Not enough
        internal static var notEnough: String { return Localizable.tr("Waves", "dexcreateorder.label.notEnough") }
        /// Total in
        internal static var totalIn: String { return Localizable.tr("Waves", "dexcreateorder.label.totalIn") }
      }
    }

    internal enum Dexinfo {

      internal enum Label {
        /// Amount Asset
        internal static var amountAsset: String { return Localizable.tr("Waves", "dexinfo.label.amountAsset") }
        /// Popular
        internal static var popular: String { return Localizable.tr("Waves", "dexinfo.label.popular") }
        /// Price Asset
        internal static var priceAsset: String { return Localizable.tr("Waves", "dexinfo.label.priceAsset") }
      }
    }

    internal enum Dexlasttrades {

      internal enum Button {
        /// BUY
        internal static var buy: String { return Localizable.tr("Waves", "dexlasttrades.button.buy") }
        /// SELL
        internal static var sell: String { return Localizable.tr("Waves", "dexlasttrades.button.sell") }
      }

      internal enum Label {
        /// Amount
        internal static var amount: String { return Localizable.tr("Waves", "dexlasttrades.label.amount") }
        /// Nothing Here…\nThe trading history is empty
        internal static var emptyData: String { return Localizable.tr("Waves", "dexlasttrades.label.emptyData") }
        /// Loading last trades…
        internal static var loadingLastTrades: String { return Localizable.tr("Waves", "dexlasttrades.label.loadingLastTrades") }
        /// Price
        internal static var price: String { return Localizable.tr("Waves", "dexlasttrades.label.price") }
        /// Sum
        internal static var sum: String { return Localizable.tr("Waves", "dexlasttrades.label.sum") }
        /// Time
        internal static var time: String { return Localizable.tr("Waves", "dexlasttrades.label.time") }
      }
    }

    internal enum Dexlist {

      internal enum Button {
        /// Add Markets
        internal static var addMarkets: String { return Localizable.tr("Waves", "dexlist.button.addMarkets") }
      }

      internal enum Label {
        /// Decentralised Exchange
        internal static var decentralisedExchange: String { return Localizable.tr("Waves", "dexlist.label.decentralisedExchange") }
        /// Trade quickly and securely. You retain complete control over your funds when trading them on our decentralised exchange.
        internal static var description: String { return Localizable.tr("Waves", "dexlist.label.description") }
        /// Last update
        internal static var lastUpdate: String { return Localizable.tr("Waves", "dexlist.label.lastUpdate") }
        /// Price
        internal static var price: String { return Localizable.tr("Waves", "dexlist.label.price") }
        /// today
        internal static var today: String { return Localizable.tr("Waves", "dexlist.label.today") }
        /// yesterday
        internal static var yesterday: String { return Localizable.tr("Waves", "dexlist.label.yesterday") }
      }

      internal enum Navigationbar {
        /// Dex
        internal static var title: String { return Localizable.tr("Waves", "dexlist.navigationBar.title") }
      }
    }

    internal enum Dexmarket {

      internal enum Label {
        /// Loading markets…
        internal static var loadingMarkets: String { return Localizable.tr("Waves", "dexmarket.label.loadingMarkets") }
      }

      internal enum Navigationbar {
        /// Markets
        internal static var title: String { return Localizable.tr("Waves", "dexmarket.navigationBar.title") }
      }

      internal enum Searchbar {
        /// Search
        internal static var placeholder: String { return Localizable.tr("Waves", "dexmarket.searchBar.placeholder") }
      }
    }

    internal enum Dexmyorders {

      internal enum Label {
        /// Amount
        internal static var amount: String { return Localizable.tr("Waves", "dexmyorders.label.amount") }
        /// Nothing Here…\nYou do not have any orders
        internal static var emptyData: String { return Localizable.tr("Waves", "dexmyorders.label.emptyData") }
        /// Loading orders…
        internal static var loadingLastTrades: String { return Localizable.tr("Waves", "dexmyorders.label.loadingLastTrades") }
        /// Price
        internal static var price: String { return Localizable.tr("Waves", "dexmyorders.label.price") }
        /// Status
        internal static var status: String { return Localizable.tr("Waves", "dexmyorders.label.status") }
        /// Time
        internal static var time: String { return Localizable.tr("Waves", "dexmyorders.label.time") }

        internal enum Status {
          /// Open
          internal static var accepted: String { return Localizable.tr("Waves", "dexmyorders.label.status.accepted") }
          /// Cancelled
          internal static var cancelled: String { return Localizable.tr("Waves", "dexmyorders.label.status.cancelled") }
          /// Filled
          internal static var filled: String { return Localizable.tr("Waves", "dexmyorders.label.status.filled") }
          /// Partial
          internal static var partiallyFilled: String { return Localizable.tr("Waves", "dexmyorders.label.status.partiallyFilled") }
        }
      }
    }

    internal enum Dexorderbook {

      internal enum Button {
        /// BUY
        internal static var buy: String { return Localizable.tr("Waves", "dexorderbook.button.buy") }
        /// SELL
        internal static var sell: String { return Localizable.tr("Waves", "dexorderbook.button.sell") }
      }

      internal enum Label {
        /// Amount
        internal static var amount: String { return Localizable.tr("Waves", "dexorderbook.label.amount") }
        /// Nothing Here…\nThe order book is empty
        internal static var emptyData: String { return Localizable.tr("Waves", "dexorderbook.label.emptyData") }
        /// LAST PRICE
        internal static var lastPrice: String { return Localizable.tr("Waves", "dexorderbook.label.lastPrice") }
        /// Loading orderbook…
        internal static var loadingOrderbook: String { return Localizable.tr("Waves", "dexorderbook.label.loadingOrderbook") }
        /// Price
        internal static var price: String { return Localizable.tr("Waves", "dexorderbook.label.price") }
        /// SPREAD
        internal static var spread: String { return Localizable.tr("Waves", "dexorderbook.label.spread") }
        /// Sum
        internal static var sum: String { return Localizable.tr("Waves", "dexorderbook.label.sum") }
      }
    }

    internal enum Dexsort {

      internal enum Navigationbar {
        /// Sorting
        internal static var title: String { return Localizable.tr("Waves", "dexsort.navigationBar.title") }
      }
    }

    internal enum Dextradercontainer {

      internal enum Button {
        /// Chart
        internal static var chart: String { return Localizable.tr("Waves", "dextradercontainer.button.chart") }
        /// Last trades
        internal static var lastTrades: String { return Localizable.tr("Waves", "dextradercontainer.button.lastTrades") }
        /// My orders
        internal static var myOrders: String { return Localizable.tr("Waves", "dextradercontainer.button.myOrders") }
        /// Orderbook
        internal static var orderbook: String { return Localizable.tr("Waves", "dextradercontainer.button.orderbook") }
      }
    }

    internal enum Enter {

      internal enum Block {

        internal enum Blockchain {
          /// Become part of a fast-growing area of the crypto world. You are the only person who can access your crypto assets.
          internal static var text: String { return Localizable.tr("Waves", "enter.block.blockchain.text") }
          /// Get Started with Blockchain
          internal static var title: String { return Localizable.tr("Waves", "enter.block.blockchain.title") }
        }

        internal enum Exchange {
          /// Trade quickly and securely. You retain complete control over your funds when trading them on our decentralised exchange.
          internal static var text: String { return Localizable.tr("Waves", "enter.block.exchange.text") }
          /// Decentralised Exchange
          internal static var title: String { return Localizable.tr("Waves", "enter.block.exchange.title") }
        }

        internal enum Token {
          /// Issue your own tokens. These can be integrated into your business not only as an internal currency but also as a token for decentralised voting, as a rating system, or loyalty program.
          internal static var text: String { return Localizable.tr("Waves", "enter.block.token.text") }
          /// Token Launcher
          internal static var title: String { return Localizable.tr("Waves", "enter.block.token.title") }
        }

        internal enum Wallet {
          /// Store, manage and receive interest on your digital assets balance, easily and securely.
          internal static var text: String { return Localizable.tr("Waves", "enter.block.wallet.text") }
          /// Wallet
          internal static var title: String { return Localizable.tr("Waves", "enter.block.wallet.title") }
        }
      }

      internal enum Button {

        internal enum Confirm {
          /// Confirm
          internal static var title: String { return Localizable.tr("Waves", "enter.button.confirm.title") }
        }

        internal enum Createnewaccount {
          /// Create a new account
          internal static var title: String { return Localizable.tr("Waves", "enter.button.createNewAccount.title") }
        }

        internal enum Importaccount {
          /// via paring code or manually
          internal static var detail: String { return Localizable.tr("Waves", "enter.button.importAccount.detail") }
          /// Import account
          internal static var title: String { return Localizable.tr("Waves", "enter.button.importAccount.title") }
        }

        internal enum Signin {
          /// to a saved account
          internal static var detail: String { return Localizable.tr("Waves", "enter.button.signIn.detail") }
          /// Sign in
          internal static var title: String { return Localizable.tr("Waves", "enter.button.signIn.title") }
        }
      }

      internal enum Language {

        internal enum Navigation {
          /// Change language
          internal static var title: String { return Localizable.tr("Waves", "enter.language.navigation.title") }
        }
      }
    }

    internal enum General {

      internal enum Biometric {

        internal enum Faceid {
          /// Face ID
          internal static var title: String { return Localizable.tr("Waves", "general.biometric.faceID.title") }
        }

        internal enum Touchid {
          /// Touch ID
          internal static var title: String { return Localizable.tr("Waves", "general.biometric.touchID.title") }
        }
      }

      internal enum Label {

        internal enum Title {
          /// / My Asset
          internal static var myasset: String { return Localizable.tr("Waves", "general.label.title.myasset") }
        }
      }

      internal enum Tabbar {

        internal enum Title {
          /// DEX
          internal static var dex: String { return Localizable.tr("Waves", "general.tabbar.title.dex") }
          /// History
          internal static var history: String { return Localizable.tr("Waves", "general.tabbar.title.history") }
          /// Profile
          internal static var profile: String { return Localizable.tr("Waves", "general.tabbar.title.profile") }
          /// Wallet
          internal static var wallet: String { return Localizable.tr("Waves", "general.tabbar.title.wallet") }
        }
      }

      internal enum Ticker {

        internal enum Title {
          /// Cryptocurrency
          internal static var cryptocurrency: String { return Localizable.tr("Waves", "general.ticker.title.cryptocurrency") }
          /// Fiat Money
          internal static var fiatmoney: String { return Localizable.tr("Waves", "general.ticker.title.fiatmoney") }
          /// SPAM
          internal static var spam: String { return Localizable.tr("Waves", "general.ticker.title.spam") }
          /// Waves Token
          internal static var wavestoken: String { return Localizable.tr("Waves", "general.ticker.title.wavestoken") }
        }
      }
    }

    internal enum Hello {

      internal enum Button {
        /// Continue
        internal static var `continue`: String { return Localizable.tr("Waves", "hello.button.continue") }
        /// Next
        internal static var next: String { return Localizable.tr("Waves", "hello.button.next") }
        /// I Understand
        internal static var understand: String { return Localizable.tr("Waves", "hello.button.understand") }
      }

      internal enum Page {

        internal enum Info {

          internal enum Fifth {
            /// How To Protect Yourself from Phishers
            internal static var title: String { return Localizable.tr("Waves", "hello.page.info.fifth.title") }

            internal enum Detail {
              /// Do not open emails or links from unknown senders.
              internal static var first: String { return Localizable.tr("Waves", "hello.page.info.fifth.detail.first") }
              /// Do not access your wallet when using public Wi-Fi or someone else’s device.
              internal static var fourth: String { return Localizable.tr("Waves", "hello.page.info.fifth.detail.fourth") }
              /// Regularly update your operating system.
              internal static var second: String { return Localizable.tr("Waves", "hello.page.info.fifth.detail.second") }
              /// Use official security software. Do not install unknown software which could be hacked.
              internal static var third: String { return Localizable.tr("Waves", "hello.page.info.fifth.detail.third") }
            }
          }

          internal enum First {
            /// Please take some time to understand some important things for your own safety. 🙏\n\nWe cannot recover your funds or freeze your account if you visit a phishing site or lose your backup phrase (aka SEED phrase).\n\nBy continuing to use our platform, you agree to accept all risks associated with the loss of your SEED, including but not limited to the inability to obtain your funds and dispose of them. In case you lose your SEED, you agree and acknowledge that the Waves Platform would not be responsible for the negative consequences of this.
            internal static var detail: String { return Localizable.tr("Waves", "hello.page.info.first.detail") }
            /// Welcome to the Waves Platform!
            internal static var title: String { return Localizable.tr("Waves", "hello.page.info.first.title") }
          }

          internal enum Fourth {
            /// One of the most common forms of scamming is phishing, which is when scammers create fake communities on Facebook or other websites that look similar to the authentic ones.
            internal static var detail: String { return Localizable.tr("Waves", "hello.page.info.fourth.detail") }
            /// How To Protect Yourself from Phishers
            internal static var title: String { return Localizable.tr("Waves", "hello.page.info.fourth.title") }
          }

          internal enum Second {
            /// When registering your account, you will be asked to save your secret phrase (Seed) and to protect your account with a password. On normal centralized servers, special attention is paid to the password, which can be changed and reset via email, if the need arises. However, on decentralized platforms such as Waves, everything is arranged differently:
            internal static var detail: String { return Localizable.tr("Waves", "hello.page.info.second.detail") }
            /// What you need to know about your SEED
            internal static var title: String { return Localizable.tr("Waves", "hello.page.info.second.title") }
          }

          internal enum Third {
            /// What you need to know about your SEED
            internal static var title: String { return Localizable.tr("Waves", "hello.page.info.third.title") }

            internal enum Detail {
              /// You use your wallet anonymously, meaning your account is not connected to an email account or any other identifying data.
              internal static var first: String { return Localizable.tr("Waves", "hello.page.info.third.detail.first") }
              /// You cannot change your secret phrase. If you accidentally sent it to someone or suspect that scammers have taken it over, then create a new Waves wallet immediately and transfer your funds to it.
              internal static var fourth: String { return Localizable.tr("Waves", "hello.page.info.third.detail.fourth") }
              /// Your password protects your account when working on a certain device or browser. It is needed in order to ensure that your secret phrase is not saved in storage.
              internal static var second: String { return Localizable.tr("Waves", "hello.page.info.third.detail.second") }
              /// If you forget your password, you can easily create a new one by using the account recovery form via your secret phrase. If you lose your secret phrase, however, you will have no way to access your account.
              internal static var third: String { return Localizable.tr("Waves", "hello.page.info.third.detail.third") }
            }
          }
        }
      }
    }

    internal enum History {

      internal enum Navigationbar {
        /// History
        internal static var title: String { return Localizable.tr("Waves", "history.navigationBar.title") }
      }

      internal enum Segmentedcontrol {
        /// Active Now
        internal static var activeNow: String { return Localizable.tr("Waves", "history.segmentedControl.activeNow") }
        /// All
        internal static var all: String { return Localizable.tr("Waves", "history.segmentedControl.all") }
        /// Canceled
        internal static var canceled: String { return Localizable.tr("Waves", "history.segmentedControl.canceled") }
        /// Exchanged
        internal static var exchanged: String { return Localizable.tr("Waves", "history.segmentedControl.exchanged") }
        /// Issued
        internal static var issued: String { return Localizable.tr("Waves", "history.segmentedControl.issued") }
        /// Leased
        internal static var leased: String { return Localizable.tr("Waves", "history.segmentedControl.leased") }
        /// Received
        internal static var received: String { return Localizable.tr("Waves", "history.segmentedControl.received") }
        /// Sent
        internal static var sent: String { return Localizable.tr("Waves", "history.segmentedControl.sent") }
      }

      internal enum Transaction {

        internal enum Title {
          /// Create Alias
          internal static var alias: String { return Localizable.tr("Waves", "history.transaction.title.alias") }
          /// Canceled Leasing
          internal static var canceledLeasing: String { return Localizable.tr("Waves", "history.transaction.title.canceledLeasing") }
          /// Data transaction
          internal static var data: String { return Localizable.tr("Waves", "history.transaction.title.data") }
          /// Exchange
          internal static var exchange: String { return Localizable.tr("Waves", "history.transaction.title.exchange") }
          /// Incoming Leasing
          internal static var incomingLeasing: String { return Localizable.tr("Waves", "history.transaction.title.incomingLeasing") }
          /// Received
          internal static var received: String { return Localizable.tr("Waves", "history.transaction.title.received") }
          /// Self-transfer
          internal static var selfTransfer: String { return Localizable.tr("Waves", "history.transaction.title.selfTransfer") }
          /// Sent
          internal static var sent: String { return Localizable.tr("Waves", "history.transaction.title.sent") }
          /// Started Leasing
          internal static var startedLeasing: String { return Localizable.tr("Waves", "history.transaction.title.startedLeasing") }
          /// Token Burn
          internal static var tokenBurn: String { return Localizable.tr("Waves", "history.transaction.title.tokenBurn") }
          /// Token Generation
          internal static var tokenGeneration: String { return Localizable.tr("Waves", "history.transaction.title.tokenGeneration") }
          /// Token Reissue
          internal static var tokenReissue: String { return Localizable.tr("Waves", "history.transaction.title.tokenReissue") }
          /// Unrecognised Transaction
          internal static var unrecognisedTransaction: String { return Localizable.tr("Waves", "history.transaction.title.unrecognisedTransaction") }
        }

        internal enum Value {
          /// Entry in blockchain
          internal static var data: String { return Localizable.tr("Waves", "history.transaction.value.data") }
        }
      }
    }

    internal enum Import {

      internal enum Account {

        internal enum Button {

          internal enum Enter {
            /// Enter seed manually
            internal static var title: String { return Localizable.tr("Waves", "import.account.button.enter.title") }
          }

          internal enum Scan {
            /// Scan pairing code
            internal static var title: String { return Localizable.tr("Waves", "import.account.button.scan.title") }
          }
        }

        internal enum Label {

          internal enum Info {

            internal enum Step {

              internal enum One {
                /// Settings > Security > Pairing code
                internal static var detail: String { return Localizable.tr("Waves", "import.account.label.info.step.one.detail") }
                /// Log in to your Beta Client via your PC or Mac at https://beta.wavesplatform.com
                internal static var title: String { return Localizable.tr("Waves", "import.account.label.info.step.one.title") }
              }

              internal enum Two {
                /// Click «Show Pairing Code» to reveal a QR Code. Scan the code with your camera.
                internal static var title: String { return Localizable.tr("Waves", "import.account.label.info.step.two.title") }
              }
            }
          }
        }

        internal enum Navigation {
          /// Import account
          internal static var title: String { return Localizable.tr("Waves", "import.account.navigation.title") }
        }
      }

      internal enum Welcome {

        internal enum Button {
          /// Continue
          internal static var `continue`: String { return Localizable.tr("Waves", "import.welcome.button.continue") }
        }

        internal enum Label {

          internal enum Address {
            /// Your seed is the 15 words you saved when creating your account
            internal static var placeholder: String { return Localizable.tr("Waves", "import.welcome.label.address.placeholder") }
            /// Your account seed
            internal static var title: String { return Localizable.tr("Waves", "import.welcome.label.address.title") }
          }
        }

        internal enum Navigation {
          /// Welcome back
          internal static var title: String { return Localizable.tr("Waves", "import.welcome.navigation.title") }
        }
      }
    }

    internal enum Legal {

      internal enum Checkbox {

        internal enum Box {
          /// I understand that my funds are held securely on this device, not by a company
          internal static var first: String { return Localizable.tr("Waves", "legal.checkbox.box.first") }
          /// I understand that if this app is moved to another device or deleted, my Waves can only be recovered with the backup phrase
          internal static var second: String { return Localizable.tr("Waves", "legal.checkbox.box.second") }
          /// Terms of Use
          internal static var termsOfUse: String { return Localizable.tr("Waves", "legal.checkbox.box.termsOfUse") }
          /// I have read, understood, and agree to the
          internal static var third: String { return Localizable.tr("Waves", "legal.checkbox.box.third") }
        }
      }
    }

    internal enum Myaddress {

      internal enum Button {

        internal enum Copy {
          /// Copy
          internal static var title: String { return Localizable.tr("Waves", "myaddress.button.copy.title") }
        }

        internal enum Share {
          /// Share
          internal static var title: String { return Localizable.tr("Waves", "myaddress.button.share.title") }
        }
      }

      internal enum Cell {

        internal enum Aliases {
          /// Aliases
          internal static var title: String { return Localizable.tr("Waves", "myaddress.cell.aliases.title") }

          internal enum Subtitle {
            /// You have %d
            internal static func withaliaces(_ p1: Int) -> String {
              return Localizable.tr("Waves", "myaddress.cell.aliases.subtitle.withaliaces", p1)
            }
            /// You do not have
            internal static var withoutaliaces: String { return Localizable.tr("Waves", "myaddress.cell.aliases.subtitle.withoutaliaces") }
          }
        }

        internal enum Info {
          /// Your address
          internal static var title: String { return Localizable.tr("Waves", "myaddress.cell.info.title") }
        }

        internal enum Qrcode {
          /// Your QR Code
          internal static var title: String { return Localizable.tr("Waves", "myaddress.cell.qrcode.title") }
        }
      }
    }

    internal enum Networksettings {

      internal enum Button {

        internal enum Save {
          /// Save
          internal static var title: String { return Localizable.tr("Waves", "networksettings.button.save.title") }
        }

        internal enum Setdefault {
          /// Set default
          internal static var title: String { return Localizable.tr("Waves", "networksettings.button.setdefault.title") }
        }
      }

      internal enum Label {

        internal enum Switchspam {
          /// Switch off spam filtering
          internal static var title: String { return Localizable.tr("Waves", "networksettings.label.switchspam.title") }
        }
      }

      internal enum Navigation {
        /// Network
        internal static var title: String { return Localizable.tr("Waves", "networksettings.navigation.title") }
      }

      internal enum Textfield {

        internal enum Spamfilter {
          /// Spam filter
          internal static var title: String { return Localizable.tr("Waves", "networksettings.textfield.spamfilter.title") }
        }
      }
    }

    internal enum Newaccount {

      internal enum Avatar {
        /// This avatar is unique. You cannot change it later.
        internal static var detail: String { return Localizable.tr("Waves", "newaccount.avatar.detail") }
        /// Choose your address avatar
        internal static var title: String { return Localizable.tr("Waves", "newaccount.avatar.title") }
      }

      internal enum Backup {

        internal enum Navigation {
          /// New Account
          internal static var title: String { return Localizable.tr("Waves", "newaccount.backup.navigation.title") }
        }
      }

      internal enum Main {

        internal enum Navigation {
          /// New Account
          internal static var title: String { return Localizable.tr("Waves", "newaccount.main.navigation.title") }
        }
      }

      internal enum Secret {

        internal enum Navigation {
          /// New Account
          internal static var title: String { return Localizable.tr("Waves", "newaccount.secret.navigation.title") }
        }
      }

      internal enum Textfield {

        internal enum Accountname {
          /// Account name
          internal static var title: String { return Localizable.tr("Waves", "newaccount.textfield.accountName.title") }
        }

        internal enum Confirmpassword {
          /// Confirm password
          internal static var title: String { return Localizable.tr("Waves", "newaccount.textfield.confirmpassword.title") }
        }

        internal enum Createpassword {
          /// Create a password
          internal static var title: String { return Localizable.tr("Waves", "newaccount.textfield.createpassword.title") }
        }

        internal enum Error {
          /// at least %d characters
          internal static func atleastcharacters(_ p1: Int) -> String {
            return Localizable.tr("Waves", "newaccount.textfield.error.atleastcharacters", p1)
          }
          /// password not match
          internal static var passwordnotmatch: String { return Localizable.tr("Waves", "newaccount.textfield.error.passwordnotmatch") }
        }
      }
    }

    internal enum Passcode {

      internal enum Button {

        internal enum Forgotpasscode {
          /// Use account password
          internal static var title: String { return Localizable.tr("Waves", "passcode.button.forgotPasscode.title") }
        }
      }

      internal enum Label {

        internal enum Forgotpasscode {
          /// Forgot passcode?
          internal static var title: String { return Localizable.tr("Waves", "passcode.label.forgotPasscode.title") }
        }

        internal enum Passcode {
          /// Create a passcode
          internal static var create: String { return Localizable.tr("Waves", "passcode.label.passcode.create") }
          /// Enter Passcode
          internal static var enter: String { return Localizable.tr("Waves", "passcode.label.passcode.enter") }
          /// Enter old Passcode
          internal static var old: String { return Localizable.tr("Waves", "passcode.label.passcode.old") }
          /// Verify your passcode
          internal static var verify: String { return Localizable.tr("Waves", "passcode.label.passcode.verify") }
        }
      }
    }

    internal enum Profile {

      internal enum Alert {

        internal enum Deleteaccount {
          /// Are you sure you want to delete this account from device?
          internal static var message: String { return Localizable.tr("Waves", "profile.alert.deleteAccount.message") }
          /// Delete account
          internal static var title: String { return Localizable.tr("Waves", "profile.alert.deleteAccount.title") }

          internal enum Button {
            /// Cancel
            internal static var cancel: String { return Localizable.tr("Waves", "profile.alert.deleteAccount.button.cancel") }
            /// Delete
            internal static var delete: String { return Localizable.tr("Waves", "profile.alert.deleteAccount.button.delete") }
          }

          internal enum Withoutbackup {
            /// Deleting an account will lead to its irretrievable loss!
            internal static var message: String { return Localizable.tr("Waves", "profile.alert.deleteAccount.withoutbackup.message") }
          }
        }
      }

      internal enum Button {

        internal enum Delete {
          /// Delete account from device
          internal static var title: String { return Localizable.tr("Waves", "profile.button.delete.title") }
        }

        internal enum Logout {
          /// Logout of account
          internal static var title: String { return Localizable.tr("Waves", "profile.button.logout.title") }
        }
      }

      internal enum Cell {

        internal enum Addressbook {
          /// Address book
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.addressbook.title") }
        }

        internal enum Addresses {
          /// Addresses, keys
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.addresses.title") }
        }

        internal enum Backupphrase {
          /// Backup phrase
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.backupphrase.title") }
        }

        internal enum Changepasscode {
          /// Change passcode
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.changepasscode.title") }
        }

        internal enum Changepassword {
          /// Change password
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.changepassword.title") }
        }

        internal enum Currentheight {
          /// Current height
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.currentheight.title") }
        }

        internal enum Feedback {
          /// Feedback
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.feedback.title") }
        }

        internal enum Info {

          internal enum Currentheight {
            /// Current height
            internal static var title: String { return Localizable.tr("Waves", "profile.cell.info.currentheight.title") }
          }

          internal enum Version {
            /// Version
            internal static var title: String { return Localizable.tr("Waves", "profile.cell.info.version.title") }
          }
        }

        internal enum Language {
          /// Language
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.language.title") }
        }

        internal enum Network {
          /// Network
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.network.title") }
        }

        internal enum Pushnotifications {
          /// Push Notifications
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.pushnotifications.title") }
        }

        internal enum Rateapp {
          /// Rate app
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.rateApp.title") }
        }

        internal enum Supportwavesplatform {
          /// Support Wavesplatform
          internal static var title: String { return Localizable.tr("Waves", "profile.cell.supportwavesplatform.title") }
        }
      }

      internal enum Header {

        internal enum General {
          /// General settings
          internal static var title: String { return Localizable.tr("Waves", "profile.header.general.title") }
        }

        internal enum Other {
          /// Other
          internal static var title: String { return Localizable.tr("Waves", "profile.header.other.title") }
        }

        internal enum Security {
          /// Security
          internal static var title: String { return Localizable.tr("Waves", "profile.header.security.title") }
        }
      }

      internal enum Language {

        internal enum Navigation {
          /// Language
          internal static var title: String { return Localizable.tr("Waves", "profile.language.navigation.title") }
        }
      }

      internal enum Navigation {
        /// Profile
        internal static var title: String { return Localizable.tr("Waves", "profile.navigation.title") }
      }
    }

    internal enum Receive {

      internal enum Button {
        /// Card
        internal static var card: String { return Localizable.tr("Waves", "receive.button.card") }
        /// Continue
        internal static var `continue`: String { return Localizable.tr("Waves", "receive.button.continue") }
        /// Сryptocurrency
        internal static var cryptocurrency: String { return Localizable.tr("Waves", "receive.button.cryptocurrency") }
        /// Invoice
        internal static var invoice: String { return Localizable.tr("Waves", "receive.button.invoice") }
        /// Use total balance
        internal static var useTotalBalance: String { return Localizable.tr("Waves", "receive.button.useTotalBalance") }
      }

      internal enum Label {
        /// Amount
        internal static var amount: String { return Localizable.tr("Waves", "receive.label.amount") }
        /// Amount in
        internal static var amountIn: String { return Localizable.tr("Waves", "receive.label.amountIn") }
        /// Asset
        internal static var asset: String { return Localizable.tr("Waves", "receive.label.asset") }
        /// Receive
        internal static var receive: String { return Localizable.tr("Waves", "receive.label.receive") }
        /// Select your asset
        internal static var selectYourAsset: String { return Localizable.tr("Waves", "receive.label.selectYourAsset") }
      }
    }

    internal enum Receiveaddress {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { return Localizable.tr("Waves", "receiveaddress.button.cancel") }
        /// Close
        internal static var close: String { return Localizable.tr("Waves", "receiveaddress.button.close") }
        /// Сopied!
        internal static var copied: String { return Localizable.tr("Waves", "receiveaddress.button.copied") }
        /// Copy
        internal static var copy: String { return Localizable.tr("Waves", "receiveaddress.button.copy") }
        /// Share
        internal static var share: String { return Localizable.tr("Waves", "receiveaddress.button.share") }
      }

      internal enum Label {
        /// Link to an Invoice
        internal static var linkToInvoice: String { return Localizable.tr("Waves", "receiveaddress.label.linkToInvoice") }
        /// Your %@ address
        internal static func yourAddress(_ p1: String) -> String {
          return Localizable.tr("Waves", "receiveaddress.label.yourAddress", p1)
        }
        /// Your QR Code
        internal static var yourQRCode: String { return Localizable.tr("Waves", "receiveaddress.label.yourQRCode") }
      }
    }

    internal enum Receivecard {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { return Localizable.tr("Waves", "receivecard.button.cancel") }
      }

      internal enum Label {
        /// Change currency
        internal static var changeCurrency: String { return Localizable.tr("Waves", "receivecard.label.changeCurrency") }
        /// The minimum is %@, the maximum is %@
        internal static func minimunAmountInfo(_ p1: String, _ p2: String) -> String {
          return Localizable.tr("Waves", "receivecard.label.minimunAmountInfo", p1, p2)
        }
        /// For making a payment from your card you will be redirected to the merchant's website
        internal static var warningInfo: String { return Localizable.tr("Waves", "receivecard.label.warningInfo") }
      }
    }

    internal enum Receivecardcomplete {

      internal enum Button {
        /// Okay
        internal static var okay: String { return Localizable.tr("Waves", "receivecardcomplete.button.okay") }
      }

      internal enum Label {
        /// After payment has been made your balance will be updated
        internal static var afterPaymentUpdateBalance: String { return Localizable.tr("Waves", "receivecardcomplete.label.afterPaymentUpdateBalance") }
        /// You have been redirected to «Indacoin»
        internal static var redirectToIndacoin: String { return Localizable.tr("Waves", "receivecardcomplete.label.redirectToIndacoin") }
      }
    }

    internal enum Receivecryptocurrency {

      internal enum Label {
        /// The minimum amount of deposit is %@
        internal static func minumumAmountOfDeposit(_ p1: String) -> String {
          return Localizable.tr("Waves", "receivecryptocurrency.label.minumumAmountOfDeposit", p1)
        }
        /// Send only %@ to this deposit address
        internal static func sendOnlyOnThisDeposit(_ p1: String) -> String {
          return Localizable.tr("Waves", "receivecryptocurrency.label.sendOnlyOnThisDeposit", p1)
        }
        /// If you will send less than %@, you will lose that money.
        internal static func warningMinimumAmountOfDeposit(_ p1: String) -> String {
          return Localizable.tr("Waves", "receivecryptocurrency.label.warningMinimumAmountOfDeposit", p1)
        }
        /// Sending any other currency to this address may result in the loss of your deposit.
        internal static var warningSendOnlyOnThisDeposit: String { return Localizable.tr("Waves", "receivecryptocurrency.label.warningSendOnlyOnThisDeposit") }
      }
    }

    internal enum Receivegenerate {

      internal enum Label {
        /// Generate…
        internal static var generate: String { return Localizable.tr("Waves", "receivegenerate.label.generate") }
        /// Your %@ address
        internal static func yourAddress(_ p1: String) -> String {
          return Localizable.tr("Waves", "receivegenerate.label.yourAddress", p1)
        }
      }
    }

    internal enum Receiveinvoice {

      internal enum Label {
        /// US Dollar
        internal static var dollar: String { return Localizable.tr("Waves", "receiveinvoice.label.dollar") }
      }
    }

    internal enum Send {

      internal enum Button {
        /// Choose from Address book
        internal static var chooseFromAddressBook: String { return Localizable.tr("Waves", "send.button.chooseFromAddressBook") }
        /// Continue
        internal static var `continue`: String { return Localizable.tr("Waves", "send.button.continue") }
        /// Use total balance
        internal static var useTotalBalanace: String { return Localizable.tr("Waves", "send.button.useTotalBalanace") }
      }

      internal enum Label {
        /// The address is not valid
        internal static var addressNotValid: String { return Localizable.tr("Waves", "send.label.addressNotValid") }
        /// Amount
        internal static var amount: String { return Localizable.tr("Waves", "send.label.amount") }
        /// US Dollar
        internal static var dollar: String { return Localizable.tr("Waves", "send.label.dollar") }
        /// Gateway fee is
        internal static var gatewayFee: String { return Localizable.tr("Waves", "send.label.gatewayFee") }
        /// Monero Payment ID
        internal static var moneroPaymentId: String { return Localizable.tr("Waves", "send.label.moneroPaymentId") }
        /// Recipient
        internal static var recipient: String { return Localizable.tr("Waves", "send.label.recipient") }
        /// Recipient address…
        internal static var recipientAddress: String { return Localizable.tr("Waves", "send.label.recipientAddress") }
        /// Send
        internal static var send: String { return Localizable.tr("Waves", "send.label.send") }
        /// Transaction Fee
        internal static var transactionFee: String { return Localizable.tr("Waves", "send.label.transactionFee") }

        internal enum Error {
          /// Insufficient funds
          internal static var insufficientFunds: String { return Localizable.tr("Waves", "send.label.error.insufficientFunds") }
          /// invalid ID
          internal static var invalidId: String { return Localizable.tr("Waves", "send.label.error.invalidId") }
          /// You don't have enough funds to pay the required fees.
          internal static var notFundsFee: String { return Localizable.tr("Waves", "send.label.error.notFundsFee") }
          /// You don't have enough funds to pay the required fees. You must pay %@ transaction fee and %@ gateway fee.
          internal static func notFundsFeeGateway(_ p1: String, _ p2: String) -> String {
            return Localizable.tr("Waves", "send.label.error.notFundsFeeGateway", p1, p2)
          }
        }

        internal enum Warning {
          /// Do not withdraw %@ to an ICO. We will not credit your account with tokens from that sale.
          internal static func description(_ p1: String) -> String {
            return Localizable.tr("Waves", "send.label.warning.description", p1)
          }
          /// We detected %@ address and will send your money through Coinomat gateway to that address. Minimum amount is %@, maximum amount is %@.
          internal static func subtitle(_ p1: String, _ p2: String, _ p3: String) -> String {
            return Localizable.tr("Waves", "send.label.warning.subtitle", p1, p2, p3)
          }
        }
      }

      internal enum Textfield {
        /// Paste or type your Payment ID
        internal static var placeholderPaymentId: String { return Localizable.tr("Waves", "send.textField.placeholderPaymentId") }
      }
    }

    internal enum Sendcomplete {

      internal enum Button {
        /// Okay
        internal static var okey: String { return Localizable.tr("Waves", "sendcomplete.button.okey") }
      }

      internal enum Label {
        /// Do you want to save this address?
        internal static var saveThisAddress: String { return Localizable.tr("Waves", "sendcomplete.label.saveThisAddress") }
        /// Your transaction is on the way!
        internal static var transactionIsOnWay: String { return Localizable.tr("Waves", "sendcomplete.label.transactionIsOnWay") }
        /// You have sent
        internal static var youHaveSent: String { return Localizable.tr("Waves", "sendcomplete.label.youHaveSent") }
      }
    }

    internal enum Sendconfirmation {

      internal enum Button {
        /// Confirm
        internal static var confim: String { return Localizable.tr("Waves", "sendconfirmation.button.confim") }
      }

      internal enum Label {
        /// Confirmation
        internal static var confirmation: String { return Localizable.tr("Waves", "sendconfirmation.label.confirmation") }
        /// Description
        internal static var description: String { return Localizable.tr("Waves", "sendconfirmation.label.description") }
        /// The description is too long
        internal static var descriptionIsTooLong: String { return Localizable.tr("Waves", "sendconfirmation.label.descriptionIsTooLong") }
        /// US Dollar
        internal static var dollar: String { return Localizable.tr("Waves", "sendconfirmation.label.dollar") }
        /// Fee
        internal static var fee: String { return Localizable.tr("Waves", "sendconfirmation.label.fee") }
        /// Write an optional message
        internal static var optionalMessage: String { return Localizable.tr("Waves", "sendconfirmation.label.optionalMessage") }
        /// Sent to
        internal static var sentTo: String { return Localizable.tr("Waves", "sendconfirmation.label.sentTo") }
      }
    }

    internal enum Sendloading {

      internal enum Label {
        /// Sending...
        internal static var sending: String { return Localizable.tr("Waves", "sendloading.label.sending") }
      }
    }

    internal enum Startleasing {

      internal enum Button {
        /// Choose from Address book
        internal static var chooseFromAddressBook: String { return Localizable.tr("Waves", "startleasing.button.chooseFromAddressBook") }
        /// Start Lease
        internal static var startLease: String { return Localizable.tr("Waves", "startleasing.button.startLease") }
        /// Use total balance
        internal static var useTotalBalanace: String { return Localizable.tr("Waves", "startleasing.button.useTotalBalanace") }
        /// Use total balance
        internal static var useTotalBalance: String { return Localizable.tr("Waves", "startleasing.button.useTotalBalance") }
      }

      internal enum Label {
        /// Address is not valid
        internal static var addressIsNotValid: String { return Localizable.tr("Waves", "startleasing.label.addressIsNotValid") }
        /// Amount
        internal static var amount: String { return Localizable.tr("Waves", "startleasing.label.amount") }
        /// Balance
        internal static var balance: String { return Localizable.tr("Waves", "startleasing.label.balance") }
        /// Generator
        internal static var generator: String { return Localizable.tr("Waves", "startleasing.label.generator") }
        /// Node address...
        internal static var nodeAddress: String { return Localizable.tr("Waves", "startleasing.label.nodeAddress") }
        /// Not enough
        internal static var notEnough: String { return Localizable.tr("Waves", "startleasing.label.notEnough") }
        /// Start leasing
        internal static var startLeasing: String { return Localizable.tr("Waves", "startleasing.label.startLeasing") }
        /// Transaction Fee
        internal static var transactionFee: String { return Localizable.tr("Waves", "startleasing.label.transactionFee") }
      }
    }

    internal enum Transactionhistory {

      internal enum Button {
        /// Copied
        internal static var copied: String { return Localizable.tr("Waves", "transactionhistory.button.copied") }
        /// Copy all data
        internal static var copyAllData: String { return Localizable.tr("Waves", "transactionhistory.button.copyAllData") }
        /// Copy TX ID
        internal static var copyTXId: String { return Localizable.tr("Waves", "transactionhistory.button.copyTXId") }
      }

      internal enum Cell {
        /// Block
        internal static var block: String { return Localizable.tr("Waves", "transactionhistory.cell.block") }
        /// Confirmations
        internal static var confirmations: String { return Localizable.tr("Waves", "transactionhistory.cell.confirmations") }
        /// Data Transaction
        internal static var dataTransaction: String { return Localizable.tr("Waves", "transactionhistory.cell.dataTransaction") }
        /// Fee
        internal static var fee: String { return Localizable.tr("Waves", "transactionhistory.cell.fee") }
        /// From
        internal static var from: String { return Localizable.tr("Waves", "transactionhistory.cell.from") }
        /// ID
        internal static var id: String { return Localizable.tr("Waves", "transactionhistory.cell.id") }
        /// Leasing to
        internal static var leasingTo: String { return Localizable.tr("Waves", "transactionhistory.cell.leasingTo") }
        /// Not Reissuable
        internal static var notReissuable: String { return Localizable.tr("Waves", "transactionhistory.cell.notReissuable") }
        /// Price
        internal static var price: String { return Localizable.tr("Waves", "transactionhistory.cell.price") }
        /// Received from
        internal static var receivedFrom: String { return Localizable.tr("Waves", "transactionhistory.cell.receivedFrom") }
        /// Recipient
        internal static var recipient: String { return Localizable.tr("Waves", "transactionhistory.cell.recipient") }
        /// Reissuable
        internal static var reissuable: String { return Localizable.tr("Waves", "transactionhistory.cell.reissuable") }
        /// Sent to
        internal static var sentTo: String { return Localizable.tr("Waves", "transactionhistory.cell.sentTo") }

        internal enum Button {
          /// Cancel Leasing
          internal static var cancelLeasing: String { return Localizable.tr("Waves", "transactionhistory.cell.button.cancelLeasing") }
          /// Send again
          internal static var sendAgain: String { return Localizable.tr("Waves", "transactionhistory.cell.button.sendAgain") }
        }

        internal enum Status {
          /// at
          internal static var at: String { return Localizable.tr("Waves", "transactionhistory.cell.status.at") }
          /// Timestamp
          internal static var timestamp: String { return Localizable.tr("Waves", "transactionhistory.cell.status.timestamp") }

          internal enum Button {
            /// Active Now
            internal static var activeNow: String { return Localizable.tr("Waves", "transactionhistory.cell.status.button.activeNow") }
            /// Completed
            internal static var completed: String { return Localizable.tr("Waves", "transactionhistory.cell.status.button.completed") }
            /// Unconfirmed
            internal static var unconfirmed: String { return Localizable.tr("Waves", "transactionhistory.cell.status.button.unconfirmed") }
          }
        }
      }

      internal enum Copy {
        /// Amount
        internal static var amount: String { return Localizable.tr("Waves", "transactionhistory.copy.amount") }
        /// Date
        internal static var date: String { return Localizable.tr("Waves", "transactionhistory.copy.date") }
        /// Fee
        internal static var fee: String { return Localizable.tr("Waves", "transactionhistory.copy.fee") }
        /// Recipient
        internal static var recipient: String { return Localizable.tr("Waves", "transactionhistory.copy.recipient") }
        /// Sender
        internal static var sender: String { return Localizable.tr("Waves", "transactionhistory.copy.sender") }
        /// Transaction ID
        internal static var transactionId: String { return Localizable.tr("Waves", "transactionhistory.copy.transactionId") }
        /// Type
        internal static var type: String { return Localizable.tr("Waves", "transactionhistory.copy.type") }
      }
    }

    internal enum Usetouchid {

      internal enum Button {

        internal enum Notnow {
          /// Not now
          internal static var text: String { return Localizable.tr("Waves", "usetouchid.button.notNow.text") }
        }

        internal enum Usebiometric {
          /// Use %@
          internal static func text(_ p1: String) -> String {
            return Localizable.tr("Waves", "usetouchid.button.useBiometric.text", p1)
          }
        }
      }

      internal enum Label {

        internal enum Detail {
          /// Use your %@ for faster, easier access to your account
          internal static func text(_ p1: String) -> String {
            return Localizable.tr("Waves", "usetouchid.label.detail.text", p1)
          }
        }

        internal enum Title {
          /// Use %@ to sign in?
          internal static func text(_ p1: String) -> String {
            return Localizable.tr("Waves", "usetouchid.label.title.text", p1)
          }
        }
      }
    }

    internal enum Wallet {

      internal enum Button {
        /// Start Lease
        internal static var startLease: String { return Localizable.tr("Waves", "wallet.button.startLease") }
      }

      internal enum Label {
        /// Available
        internal static var available: String { return Localizable.tr("Waves", "wallet.label.available") }
        /// Leased
        internal static var leased: String { return Localizable.tr("Waves", "wallet.label.leased") }
        /// Leased in
        internal static var leasedIn: String { return Localizable.tr("Waves", "wallet.label.leasedIn") }
        /// Started Leasing
        internal static var startedLeasing: String { return Localizable.tr("Waves", "wallet.label.startedLeasing") }
        /// Total balance
        internal static var totalBalance: String { return Localizable.tr("Waves", "wallet.label.totalBalance") }
        /// View history
        internal static var viewHistory: String { return Localizable.tr("Waves", "wallet.label.viewHistory") }

        internal enum Quicknote {

          internal enum Description {
            /// You can only transfer or trade WAVES that aren’t leased. The leased amount cannot be transferred or traded by you or anyone else.
            internal static var first: String { return Localizable.tr("Waves", "wallet.label.quickNote.description.first") }
            /// You can cancel a leasing transaction as soon as it appears in the blockchain which usually occurs in a minute or less.
            internal static var second: String { return Localizable.tr("Waves", "wallet.label.quickNote.description.second") }
            /// The generating balance will be updated after 1000 blocks.
            internal static var third: String { return Localizable.tr("Waves", "wallet.label.quickNote.description.third") }
          }
        }
      }

      internal enum Navigationbar {
        /// Wallet
        internal static var title: String { return Localizable.tr("Waves", "wallet.navigationBar.title") }
      }

      internal enum Section {
        /// Active now (%d)
        internal static func activeNow(_ p1: Int) -> String {
          return Localizable.tr("Waves", "wallet.section.activeNow", p1)
        }
        /// Hidden assets (%d)
        internal static func hiddenAssets(_ p1: Int) -> String {
          return Localizable.tr("Waves", "wallet.section.hiddenAssets", p1)
        }
        /// Quick note
        internal static var quickNote: String { return Localizable.tr("Waves", "wallet.section.quickNote") }
        /// Spam assets (%d)
        internal static func spamAssets(_ p1: Int) -> String {
          return Localizable.tr("Waves", "wallet.section.spamAssets", p1)
        }
      }

      internal enum Segmentedcontrol {
        /// Assets
        internal static var assets: String { return Localizable.tr("Waves", "wallet.segmentedControl.assets") }
        /// Leasing
        internal static var leasing: String { return Localizable.tr("Waves", "wallet.segmentedControl.leasing") }
      }
    }

    internal enum Walletsort {

      internal enum Button {
        /// Position
        internal static var position: String { return Localizable.tr("Waves", "walletsort.button.position") }
        /// Visibility
        internal static var visibility: String { return Localizable.tr("Waves", "walletsort.button.visibility") }
      }

      internal enum Navigationbar {
        /// Sorting
        internal static var title: String { return Localizable.tr("Waves", "walletsort.navigationBar.title") }
      }
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
