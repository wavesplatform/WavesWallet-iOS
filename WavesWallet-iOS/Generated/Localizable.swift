// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation
import Extensions

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum Localizable {
          internal enum InfoPlist {
    /// The camera is needed to scan QR codes
    internal static var nsCameraUsageDescription: String { Localizable.tr("InfoPlist", "NSCameraUsageDescription") }
    internal static var nsCameraUsageDescriptionKey: String { "NSCameraUsageDescription" }
    /// Access to your wallet
    internal static var nsFaceIDUsageDescription: String { Localizable.tr("InfoPlist", "NSFaceIDUsageDescription") }
    internal static var nsFaceIDUsageDescriptionKey: String { "NSFaceIDUsageDescription" }
    /// The camera is needed to scan QR codes
    internal static var nsPhotoLibraryAddUsageDescription: String { Localizable.tr("InfoPlist", "NSPhotoLibraryAddUsageDescription") }
    internal static var nsPhotoLibraryAddUsageDescriptionKey: String { "NSPhotoLibraryAddUsageDescription" }
  }
          internal enum Waves {

    internal enum Accountpassword {

      internal enum Button {

        internal enum Signin {
          /// Sign In
          internal static var title: String { Localizable.tr("Waves", "accountpassword.button.signIn.title") }
          internal static var titleKey: String { "accountpassword.button.signIn.title" }
        }
      }

      internal enum Error {
        /// Wrong password
        internal static var wrongpassword: String { Localizable.tr("Waves", "accountpassword.error.wrongpassword") }
        internal static var wrongpasswordKey: String { "accountpassword.error.wrongpassword" }
      }

      internal enum Textfield {

        internal enum Error {
          /// Minimum %d characters
          internal static func atleastcharacters(_ p1: Int) -> String {
            Localizable.tr("Waves", "accountpassword.textfield.error.atleastcharacters", p1)
          }
        }

        internal enum Password {
          /// Account password
          internal static var placeholder: String { Localizable.tr("Waves", "accountpassword.textfield.password.placeholder") }
          internal static var placeholderKey: String { "accountpassword.textfield.password.placeholder" }
        }
      }
    }

    internal enum Addaddressbook {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { Localizable.tr("Waves", "addAddressbook.button.cancel") }
        internal static var cancelKey: String { "addAddressbook.button.cancel" }
        /// Delete
        internal static var delete: String { Localizable.tr("Waves", "addAddressbook.button.delete") }
        internal static var deleteKey: String { "addAddressbook.button.delete" }
        /// Delete address
        internal static var deleteAddress: String { Localizable.tr("Waves", "addAddressbook.button.deleteAddress") }
        internal static var deleteAddressKey: String { "addAddressbook.button.deleteAddress" }
        /// Save
        internal static var save: String { Localizable.tr("Waves", "addAddressbook.button.save") }
        internal static var saveKey: String { "addAddressbook.button.save" }
      }

      internal enum Error {
        /// %d characters maximum
        internal static func charactersMaximum(_ p1: Int) -> String {
          Localizable.tr("Waves", "addAddressbook.error.charactersMaximum", p1)
        }
        /// Minimum %d characters
        internal static func charactersMinimum(_ p1: Int) -> String {
          Localizable.tr("Waves", "addAddressbook.error.charactersMinimum", p1)
        }
      }

      internal enum Label {
        /// Add
        internal static var add: String { Localizable.tr("Waves", "addAddressbook.label.add") }
        internal static var addKey: String { "addAddressbook.label.add" }
        /// Address
        internal static var address: String { Localizable.tr("Waves", "addAddressbook.label.address") }
        internal static var addressKey: String { "addAddressbook.label.address" }
        /// Are you sure you want to delete address from address book?
        internal static var deleteAlertMessage: String { Localizable.tr("Waves", "addAddressbook.label.deleteAlertMessage") }
        internal static var deleteAlertMessageKey: String { "addAddressbook.label.deleteAlertMessage" }
        /// Edit
        internal static var edit: String { Localizable.tr("Waves", "addAddressbook.label.edit") }
        internal static var editKey: String { "addAddressbook.label.edit" }
        /// Name
        internal static var name: String { Localizable.tr("Waves", "addAddressbook.label.name") }
        internal static var nameKey: String { "addAddressbook.label.name" }
      }

      internal enum Textfield {

        internal enum Address {

          internal enum Error {
            /// Already in use
            internal static var addressexist: String { Localizable.tr("Waves", "addAddressbook.textfield.address.error.addressexist") }
            internal static var addressexistKey: String { "addAddressbook.textfield.address.error.addressexist" }
          }
        }
      }
    }

    internal enum Addressbook {

      internal enum Label {
        /// Address book
        internal static var addressBook: String { Localizable.tr("Waves", "addressbook.label.addressBook") }
        internal static var addressBookKey: String { "addressbook.label.addressBook" }
        /// Address deleted
        internal static var addressDeleted: String { Localizable.tr("Waves", "addressbook.label.addressDeleted") }
        internal static var addressDeletedKey: String { "addressbook.label.addressDeleted" }
        /// Nothing Here…\nYou can create new address
        internal static var noInfo: String { Localizable.tr("Waves", "addressbook.label.noInfo") }
        internal static var noInfoKey: String { "addressbook.label.noInfo" }
      }
    }

    internal enum Addressbookbutton {

      internal enum Title {
        /// Edit name
        internal static var editName: String { Localizable.tr("Waves", "addressBookButton.title.editName") }
        internal static var editNameKey: String { "addressBookButton.title.editName" }
        /// Save address
        internal static var saveAddress: String { Localizable.tr("Waves", "addressBookButton.title.saveAddress") }
        internal static var saveAddressKey: String { "addressBookButton.title.saveAddress" }
      }
    }

    internal enum Addresseskeys {

      internal enum Cell {

        internal enum Address {
          /// Your address
          internal static var title: String { Localizable.tr("Waves", "addresseskeys.cell.address.title") }
          internal static var titleKey: String { "addresseskeys.cell.address.title" }
        }

        internal enum Aliases {
          /// Aliases
          internal static var title: String { Localizable.tr("Waves", "addresseskeys.cell.aliases.title") }
          internal static var titleKey: String { "addresseskeys.cell.aliases.title" }

          internal enum Subtitle {
            /// You have %d
            internal static func withaliaces(_ p1: Int) -> String {
              Localizable.tr("Waves", "addresseskeys.cell.aliases.subtitle.withaliaces", p1)
            }
            /// You do not have
            internal static var withoutaliaces: String { Localizable.tr("Waves", "addresseskeys.cell.aliases.subtitle.withoutaliaces") }
            internal static var withoutaliacesKey: String { "addresseskeys.cell.aliases.subtitle.withoutaliaces" }
          }
        }

        internal enum Privatekey {
          /// Private Key
          internal static var title: String { Localizable.tr("Waves", "addresseskeys.cell.privatekey.title") }
          internal static var titleKey: String { "addresseskeys.cell.privatekey.title" }
        }

        internal enum Privatekeyhidde {

          internal enum Button {
            /// Show
            internal static var title: String { Localizable.tr("Waves", "addresseskeys.cell.privatekeyhidde.button.title") }
            internal static var titleKey: String { "addresseskeys.cell.privatekeyhidde.button.title" }
          }
        }

        internal enum Publickey {
          /// Public Key
          internal static var title: String { Localizable.tr("Waves", "addresseskeys.cell.publickey.title") }
          internal static var titleKey: String { "addresseskeys.cell.publickey.title" }
        }

        internal enum Seed {
          /// SEED
          internal static var title: String { Localizable.tr("Waves", "addresseskeys.cell.seed.title") }
          internal static var titleKey: String { "addresseskeys.cell.seed.title" }
        }
      }

      internal enum Navigation {
        /// Addresses, keys
        internal static var title: String { Localizable.tr("Waves", "addresseskeys.navigation.title") }
        internal static var titleKey: String { "addresseskeys.navigation.title" }
      }
    }

    internal enum Aliases {

      internal enum Cell {

        internal enum Head {
          /// Your Aliases
          internal static var title: String { Localizable.tr("Waves", "aliases.cell.head.title") }
          internal static var titleKey: String { "aliases.cell.head.title" }
        }
      }

      internal enum View {

        internal enum Info {

          internal enum Button {
            /// Create a new alias
            internal static var create: String { Localizable.tr("Waves", "aliases.view.info.button.create") }
            internal static var createKey: String { "aliases.view.info.button.create" }
          }

          internal enum Label {
            /// Your Alias must be between 4 and 30 characters long, and must contain only lowercase Latin letters, digits and symbols (@, -, _ and dot)
            internal static var secondsubtitle: String { Localizable.tr("Waves", "aliases.view.info.label.secondsubtitle") }
            internal static var secondsubtitleKey: String { "aliases.view.info.label.secondsubtitle" }
            /// An Alias is a nickname for your address. You can use an Alias instead of an address to make transactions.
            internal static var subtitle: String { Localizable.tr("Waves", "aliases.view.info.label.subtitle") }
            internal static var subtitleKey: String { "aliases.view.info.label.subtitle" }
            /// About Alias
            internal static var title: String { Localizable.tr("Waves", "aliases.view.info.label.title") }
            internal static var titleKey: String { "aliases.view.info.label.title" }
          }
        }
      }
    }

    internal enum Aliaseswithout {

      internal enum View {

        internal enum Info {

          internal enum Button {
            /// Create a new alias
            internal static var create: String { Localizable.tr("Waves", "aliaseswithout.view.info.button.create") }
            internal static var createKey: String { "aliaseswithout.view.info.button.create" }
          }

          internal enum Label {
            /// Your Alias must be between 4 and 30 characters long, and must contain only lowercase Latin letters, digits and symbols (@, -, _ and dot)
            internal static var secondsubtitle: String { Localizable.tr("Waves", "aliaseswithout.view.info.label.secondsubtitle") }
            internal static var secondsubtitleKey: String { "aliaseswithout.view.info.label.secondsubtitle" }
            /// An Alias is a nickname for your address. You can use an Alias instead of an address to make transactions.
            internal static var subtitle: String { Localizable.tr("Waves", "aliaseswithout.view.info.label.subtitle") }
            internal static var subtitleKey: String { "aliaseswithout.view.info.label.subtitle" }
            /// You do not have Aliases
            internal static var title: String { Localizable.tr("Waves", "aliaseswithout.view.info.label.title") }
            internal static var titleKey: String { "aliaseswithout.view.info.label.title" }
          }
        }
      }
    }

    internal enum Appnews {

      internal enum Button {
        /// Okay
        internal static var okey: String { Localizable.tr("Waves", "appnews.button.okey") }
        internal static var okeyKey: String { "appnews.button.okey" }
      }
    }

    internal enum Asset {

      internal enum Cell {
        /// Transaction history
        internal static var viewHistory: String { Localizable.tr("Waves", "asset.cell.viewHistory") }
        internal static var viewHistoryKey: String { "asset.cell.viewHistory" }

        internal enum Assetinfo {
          /// You can not perform transactions with this token
          internal static var cantPerformTransactions: String { Localizable.tr("Waves", "asset.cell.assetInfo.cantPerformTransactions") }
          internal static var cantPerformTransactionsKey: String { "asset.cell.assetInfo.cantPerformTransactions" }
          /// Decimal points
          internal static var decimalPoints: String { Localizable.tr("Waves", "asset.cell.assetInfo.decimalPoints") }
          internal static var decimalPointsKey: String { "asset.cell.assetInfo.decimalPoints" }
          /// Description
          internal static var description: String { Localizable.tr("Waves", "asset.cell.assetInfo.description") }
          internal static var descriptionKey: String { "asset.cell.assetInfo.description" }
          /// ID
          internal static var id: String { Localizable.tr("Waves", "asset.cell.assetInfo.id") }
          internal static var idKey: String { "asset.cell.assetInfo.id" }
          /// Issue date
          internal static var issueDate: String { Localizable.tr("Waves", "asset.cell.assetInfo.issueDate") }
          internal static var issueDateKey: String { "asset.cell.assetInfo.issueDate" }
          /// Issuer
          internal static var issuer: String { Localizable.tr("Waves", "asset.cell.assetInfo.issuer") }
          internal static var issuerKey: String { "asset.cell.assetInfo.issuer" }
          /// Name
          internal static var name: String { Localizable.tr("Waves", "asset.cell.assetInfo.name") }
          internal static var nameKey: String { "asset.cell.assetInfo.name" }
          /// Token Info
          internal static var title: String { Localizable.tr("Waves", "asset.cell.assetInfo.title") }
          internal static var titleKey: String { "asset.cell.assetInfo.title" }
          /// Total amount
          internal static var totalAmount: String { Localizable.tr("Waves", "asset.cell.assetInfo.totalAmount") }
          internal static var totalAmountKey: String { "asset.cell.assetInfo.totalAmount" }

          internal enum Kind {
            /// Not reissuable
            internal static var notReissuable: String { Localizable.tr("Waves", "asset.cell.assetInfo.kind.notReissuable") }
            internal static var notReissuableKey: String { "asset.cell.assetInfo.kind.notReissuable" }
            /// Reissuable
            internal static var reissuable: String { Localizable.tr("Waves", "asset.cell.assetInfo.kind.reissuable") }
            internal static var reissuableKey: String { "asset.cell.assetInfo.kind.reissuable" }
            /// Type
            internal static var title: String { Localizable.tr("Waves", "asset.cell.assetInfo.kind.title") }
            internal static var titleKey: String { "asset.cell.assetInfo.kind.title" }
          }
        }

        internal enum Balance {
          /// Available balance
          internal static var avaliableBalance: String { Localizable.tr("Waves", "asset.cell.balance.avaliableBalance") }
          internal static var avaliableBalanceKey: String { "asset.cell.balance.avaliableBalance" }
          /// In order
          internal static var inOrderBalance: String { Localizable.tr("Waves", "asset.cell.balance.inOrderBalance") }
          internal static var inOrderBalanceKey: String { "asset.cell.balance.inOrderBalance" }
          /// Leased
          internal static var leased: String { Localizable.tr("Waves", "asset.cell.balance.leased") }
          internal static var leasedKey: String { "asset.cell.balance.leased" }
          /// Total
          internal static var totalBalance: String { Localizable.tr("Waves", "asset.cell.balance.totalBalance") }
          internal static var totalBalanceKey: String { "asset.cell.balance.totalBalance" }

          internal enum Button {
            /// Exchange
            internal static var exchange: String { Localizable.tr("Waves", "asset.cell.balance.button.exchange") }
            internal static var exchangeKey: String { "asset.cell.balance.button.exchange" }
            /// Receive
            internal static var receive: String { Localizable.tr("Waves", "asset.cell.balance.button.receive") }
            internal static var receiveKey: String { "asset.cell.balance.button.receive" }
            /// Send
            internal static var send: String { Localizable.tr("Waves", "asset.cell.balance.button.send") }
            internal static var sendKey: String { "asset.cell.balance.button.send" }
            /// Trade
            internal static var trade: String { Localizable.tr("Waves", "asset.cell.balance.button.trade") }
            internal static var tradeKey: String { "asset.cell.balance.button.trade" }
          }
        }
      }

      internal enum Header {
        /// Last transactions
        internal static var lastTransactions: String { Localizable.tr("Waves", "asset.header.lastTransactions") }
        internal static var lastTransactionsKey: String { "asset.header.lastTransactions" }
        /// You do not have any transactions
        internal static var notHaveTransactions: String { Localizable.tr("Waves", "asset.header.notHaveTransactions") }
        internal static var notHaveTransactionsKey: String { "asset.header.notHaveTransactions" }
      }
    }

    internal enum Assetlist {

      internal enum Button {
        /// All list
        internal static var allList: String { Localizable.tr("Waves", "assetlist.button.allList") }
        internal static var allListKey: String { "assetlist.button.allList" }
        /// With balance
        internal static var myList: String { Localizable.tr("Waves", "assetlist.button.myList") }
        internal static var myListKey: String { "assetlist.button.myList" }
        /// With balance
        internal static var withBalance: String { Localizable.tr("Waves", "assetlist.button.withBalance") }
        internal static var withBalanceKey: String { "assetlist.button.withBalance" }
      }

      internal enum Label {
        /// Tokens
        internal static var assets: String { Localizable.tr("Waves", "assetlist.label.assets") }
        internal static var assetsKey: String { "assetlist.label.assets" }
        /// Loading tokens…
        internal static var loadingAssets: String { Localizable.tr("Waves", "assetlist.label.loadingAssets") }
        internal static var loadingAssetsKey: String { "assetlist.label.loadingAssets" }
      }
    }

    internal enum Assetsearch {

      internal enum Cell {

        internal enum Empty {
          /// No tokens matching your search
          internal static var title: String { Localizable.tr("Waves", "assetsearch.cell.empty.title") }
          internal static var titleKey: String { "assetsearch.cell.empty.title" }
        }
      }
    }

    internal enum Backup {

      internal enum Backup {

        internal enum Navigation {
          /// Backup phrase
          internal static var title: String { Localizable.tr("Waves", "backup.backup.navigation.title") }
          internal static var titleKey: String { "backup.backup.navigation.title" }
        }
      }

      internal enum Confirmbackup {

        internal enum Button {
          /// Confirm
          internal static var confirm: String { Localizable.tr("Waves", "backup.confirmbackup.button.confirm") }
          internal static var confirmKey: String { "backup.confirmbackup.button.confirm" }
        }

        internal enum Error {
          /// Wrong order, try again
          internal static var label: String { Localizable.tr("Waves", "backup.confirmbackup.error.label") }
          internal static var labelKey: String { "backup.confirmbackup.error.label" }
        }

        internal enum Info {
          /// Please, tap each word in the correct order
          internal static var label: String { Localizable.tr("Waves", "backup.confirmbackup.info.label") }
          internal static var labelKey: String { "backup.confirmbackup.info.label" }
        }

        internal enum Navigation {
          /// Confirm backup
          internal static var title: String { Localizable.tr("Waves", "backup.confirmbackup.navigation.title") }
          internal static var titleKey: String { "backup.confirmbackup.navigation.title" }
        }
      }

      internal enum Needbackup {

        internal enum Button {
          /// Back Up Now
          internal static var backupnow: String { Localizable.tr("Waves", "backup.needbackup.button.backupnow") }
          internal static var backupnowKey: String { "backup.needbackup.button.backupnow" }
          /// Do it later
          internal static var doitlater: String { Localizable.tr("Waves", "backup.needbackup.button.doitlater") }
          internal static var doitlaterKey: String { "backup.needbackup.button.doitlater" }
        }

        internal enum Label {
          /// You must save the secret phrase. It is crucial for accessing your account.
          internal static var detail: String { Localizable.tr("Waves", "backup.needbackup.label.detail") }
          internal static var detailKey: String { "backup.needbackup.label.detail" }
          /// No Backup, No Money
          internal static var title: String { Localizable.tr("Waves", "backup.needbackup.label.title") }
          internal static var titleKey: String { "backup.needbackup.label.title" }
        }
      }

      internal enum Savebackup {

        internal enum Copy {

          internal enum Label {
            /// Please carefully write down these 15 words or copy them
            internal static var title: String { Localizable.tr("Waves", "backup.savebackup.copy.label.title") }
            internal static var titleKey: String { "backup.savebackup.copy.label.title" }
          }
        }

        internal enum Label {
          /// Since only you control your money, you’ll need to save your backup phrase in case this app is deleted
          internal static var title: String { Localizable.tr("Waves", "backup.savebackup.label.title") }
          internal static var titleKey: String { "backup.savebackup.label.title" }
        }

        internal enum Navigation {
          /// Save backup phrase
          internal static var title: String { Localizable.tr("Waves", "backup.savebackup.navigation.title") }
          internal static var titleKey: String { "backup.savebackup.navigation.title" }
        }

        internal enum Next {

          internal enum Button {
            /// I've written it down
            internal static var title: String { Localizable.tr("Waves", "backup.savebackup.next.button.title") }
            internal static var titleKey: String { "backup.savebackup.next.button.title" }
          }

          internal enum Label {
            /// You will confirm this phrase on the next screen
            internal static var title: String { Localizable.tr("Waves", "backup.savebackup.next.label.title") }
            internal static var titleKey: String { "backup.savebackup.next.label.title" }
          }
        }
      }
    }

    internal enum Biometric {
      /// Cancel
      internal static var localizedCancelTitle: String { Localizable.tr("Waves", "biometric.localizedCancelTitle") }
      internal static var localizedCancelTitleKey: String { "biometric.localizedCancelTitle" }
      /// Enter Passcode
      internal static var localizedFallbackTitle: String { Localizable.tr("Waves", "biometric.localizedFallbackTitle") }
      internal static var localizedFallbackTitleKey: String { "biometric.localizedFallbackTitle" }
      /// Access to your wallet
      internal static var readfromkeychain: String { Localizable.tr("Waves", "biometric.readfromkeychain") }
      internal static var readfromkeychainKey: String { "biometric.readfromkeychain" }
      /// Access to your wallet
      internal static var saveinkeychain: String { Localizable.tr("Waves", "biometric.saveinkeychain") }
      internal static var saveinkeychainKey: String { "biometric.saveinkeychain" }

      internal enum Manyattempts {
        /// To unlock biometric, sign in with your account password
        internal static var subtitle: String { Localizable.tr("Waves", "biometric.manyattempts.subtitle") }
        internal static var subtitleKey: String { "biometric.manyattempts.subtitle" }
        /// Too many attempts
        internal static var title: String { Localizable.tr("Waves", "biometric.manyattempts.title") }
        internal static var titleKey: String { "biometric.manyattempts.title" }
      }
    }

    internal enum Cameraaccess {

      internal enum Alert {
        /// Allow Camera
        internal static var allow: String { Localizable.tr("Waves", "cameraAccess.alert.allow") }
        internal static var allowKey: String { "cameraAccess.alert.allow" }
        /// Cancel
        internal static var cancel: String { Localizable.tr("Waves", "cameraAccess.alert.cancel") }
        internal static var cancelKey: String { "cameraAccess.alert.cancel" }
        /// Camera access is required to make full use of this app
        internal static var message: String { Localizable.tr("Waves", "cameraAccess.alert.message") }
        internal static var messageKey: String { "cameraAccess.alert.message" }
        /// Need Camera Access
        internal static var title: String { Localizable.tr("Waves", "cameraAccess.alert.title") }
        internal static var titleKey: String { "cameraAccess.alert.title" }
      }
    }

    internal enum Changepassword {

      internal enum Button {

        internal enum Confirm {
          /// Confirm
          internal static var title: String { Localizable.tr("Waves", "changepassword.button.confirm.title") }
          internal static var titleKey: String { "changepassword.button.confirm.title" }
        }
      }

      internal enum Navigation {
        /// Changed password
        internal static var title: String { Localizable.tr("Waves", "changepassword.navigation.title") }
        internal static var titleKey: String { "changepassword.navigation.title" }
      }

      internal enum Textfield {

        internal enum Confirmpassword {
          /// Confirm password
          internal static var title: String { Localizable.tr("Waves", "changepassword.textfield.confirmpassword.title") }
          internal static var titleKey: String { "changepassword.textfield.confirmpassword.title" }
        }

        internal enum Createpassword {
          /// New password
          internal static var title: String { Localizable.tr("Waves", "changepassword.textfield.createpassword.title") }
          internal static var titleKey: String { "changepassword.textfield.createpassword.title" }
        }

        internal enum Error {
          /// Minimum %d characters
          internal static func atleastcharacters(_ p1: Int) -> String {
            Localizable.tr("Waves", "changepassword.textfield.error.atleastcharacters", p1)
          }
          /// incorrect password
          internal static var incorrectpassword: String { Localizable.tr("Waves", "changepassword.textfield.error.incorrectpassword") }
          internal static var incorrectpasswordKey: String { "changepassword.textfield.error.incorrectpassword" }
          /// password not match
          internal static var passwordnotmatch: String { Localizable.tr("Waves", "changepassword.textfield.error.passwordnotmatch") }
          internal static var passwordnotmatchKey: String { "changepassword.textfield.error.passwordnotmatch" }
        }

        internal enum Oldpassword {
          /// Old password
          internal static var title: String { Localizable.tr("Waves", "changepassword.textfield.oldpassword.title") }
          internal static var titleKey: String { "changepassword.textfield.oldpassword.title" }
        }
      }
    }

    internal enum Chooseaccount {

      internal enum Alert {
        /// Please select
        internal static var pleaseSelect: String { Localizable.tr("Waves", "chooseaccount.alert.pleaseSelect") }
        internal static var pleaseSelectKey: String { "chooseaccount.alert.pleaseSelect" }

        internal enum Button {
          /// Cancel
          internal static var no: String { Localizable.tr("Waves", "chooseaccount.alert.button.no") }
          internal static var noKey: String { "chooseaccount.alert.button.no" }
          /// Yes
          internal static var ok: String { Localizable.tr("Waves", "chooseaccount.alert.button.ok") }
          internal static var okKey: String { "chooseaccount.alert.button.ok" }
        }

        internal enum Delete {
          /// Are you sure you want to delete this account?
          internal static var message: String { Localizable.tr("Waves", "chooseaccount.alert.delete.message") }
          internal static var messageKey: String { "chooseaccount.alert.delete.message" }
          /// Delete account
          internal static var title: String { Localizable.tr("Waves", "chooseaccount.alert.delete.title") }
          internal static var titleKey: String { "chooseaccount.alert.delete.title" }
        }
      }

      internal enum Label {
        /// Nothing Here…\nYou do not have saved accounts
        internal static var nothingWallets: String { Localizable.tr("Waves", "chooseaccount.label.nothingWallets") }
        internal static var nothingWalletsKey: String { "chooseaccount.label.nothingWallets" }
      }

      internal enum Navigation {
        /// Choose account
        internal static var title: String { Localizable.tr("Waves", "chooseaccount.navigation.title") }
        internal static var titleKey: String { "chooseaccount.navigation.title" }
      }
    }

    internal enum Coinomat {
      /// Service temporarily unavailable
      internal static var temporarilyUnavailable: String { Localizable.tr("Waves", "coinomat.temporarilyUnavailable") }
      internal static var temporarilyUnavailableKey: String { "coinomat.temporarilyUnavailable" }
      /// Try again later
      internal static var tryAgain: String { Localizable.tr("Waves", "coinomat.tryAgain") }
      internal static var tryAgainKey: String { "coinomat.tryAgain" }
    }

    internal enum Createalias {

      internal enum Button {

        internal enum Create {
          /// Create
          internal static var title: String { Localizable.tr("Waves", "createalias.button.create.title") }
          internal static var titleKey: String { "createalias.button.create.title" }
        }
      }

      internal enum Cell {

        internal enum Input {

          internal enum Textfiled {

            internal enum Input {
              /// Symbolic name
              internal static var placeholder: String { Localizable.tr("Waves", "createalias.cell.input.textfiled.input.placeholder") }
              internal static var placeholderKey: String { "createalias.cell.input.textfiled.input.placeholder" }
              /// Symbolic name
              internal static var title: String { Localizable.tr("Waves", "createalias.cell.input.textfiled.input.title") }
              internal static var titleKey: String { "createalias.cell.input.textfiled.input.title" }
            }
          }
        }
      }

      internal enum Error {
        /// Already in use
        internal static var alreadyinuse: String { Localizable.tr("Waves", "createalias.error.alreadyinuse") }
        internal static var alreadyinuseKey: String { "createalias.error.alreadyinuse" }
        /// 30 characters maximum
        internal static var charactersmaximum: String { Localizable.tr("Waves", "createalias.error.charactersmaximum") }
        internal static var charactersmaximumKey: String { "createalias.error.charactersmaximum" }
        /// Invalid character
        internal static var invalidcharacter: String { Localizable.tr("Waves", "createalias.error.invalidcharacter") }
        internal static var invalidcharacterKey: String { "createalias.error.invalidcharacter" }
        /// Minimum 4 characters
        internal static var minimumcharacters: String { Localizable.tr("Waves", "createalias.error.minimumcharacters") }
        internal static var minimumcharactersKey: String { "createalias.error.minimumcharacters" }
      }

      internal enum Navigation {
        /// New alias
        internal static var title: String { Localizable.tr("Waves", "createalias.navigation.title") }
        internal static var titleKey: String { "createalias.navigation.title" }
      }
    }

    internal enum Dex {

      internal enum General {

        internal enum Error {
          /// Nothing Here…
          internal static var nothingHere: String { Localizable.tr("Waves", "dex.general.error.nothingHere") }
          internal static var nothingHereKey: String { "dex.general.error.nothingHere" }
          /// Something went wrong
          internal static var somethingWentWrong: String { Localizable.tr("Waves", "dex.general.error.somethingWentWrong") }
          internal static var somethingWentWrongKey: String { "dex.general.error.somethingWentWrong" }
        }
      }
    }

    internal enum Dexchart {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { Localizable.tr("Waves", "dexchart.button.cancel") }
        internal static var cancelKey: String { "dexchart.button.cancel" }
      }

      internal enum Label {
        /// day
        internal static var day: String { Localizable.tr("Waves", "dexchart.label.day") }
        internal static var dayKey: String { "dexchart.label.day" }
        /// No chart data available
        internal static var emptyData: String { Localizable.tr("Waves", "dexchart.label.emptyData") }
        internal static var emptyDataKey: String { "dexchart.label.emptyData" }
        /// hour
        internal static var hour: String { Localizable.tr("Waves", "dexchart.label.hour") }
        internal static var hourKey: String { "dexchart.label.hour" }
        /// hours
        internal static var hours: String { Localizable.tr("Waves", "dexchart.label.hours") }
        internal static var hoursKey: String { "dexchart.label.hours" }
        /// Loading chart…
        internal static var loadingChart: String { Localizable.tr("Waves", "dexchart.label.loadingChart") }
        internal static var loadingChartKey: String { "dexchart.label.loadingChart" }
        /// minutes
        internal static var minutes: String { Localizable.tr("Waves", "dexchart.label.minutes") }
        internal static var minutesKey: String { "dexchart.label.minutes" }
        /// Month
        internal static var month: String { Localizable.tr("Waves", "dexchart.label.month") }
        internal static var monthKey: String { "dexchart.label.month" }
        /// Today
        internal static var today: String { Localizable.tr("Waves", "dexchart.label.today") }
        internal static var todayKey: String { "dexchart.label.today" }
        /// Week
        internal static var week: String { Localizable.tr("Waves", "dexchart.label.week") }
        internal static var weekKey: String { "dexchart.label.week" }
        /// Yesterday
        internal static var yesterday: String { Localizable.tr("Waves", "dexchart.label.yesterday") }
        internal static var yesterdayKey: String { "dexchart.label.yesterday" }
      }
    }

    internal enum Dexcompleteorder {

      internal enum Button {
        /// Okay
        internal static var okey: String { Localizable.tr("Waves", "dexcompleteorder.button.okey") }
        internal static var okeyKey: String { "dexcompleteorder.button.okey" }
      }

      internal enum Label {
        /// Amount
        internal static var amount: String { Localizable.tr("Waves", "dexcompleteorder.label.amount") }
        internal static var amountKey: String { "dexcompleteorder.label.amount" }
        /// Open
        internal static var `open`: String { Localizable.tr("Waves", "dexcompleteorder.label.open") }
        internal static var openKey: String { "dexcompleteorder.label.open" }
        /// The order is created
        internal static var orderIsCreated: String { Localizable.tr("Waves", "dexcompleteorder.label.orderIsCreated") }
        internal static var orderIsCreatedKey: String { "dexcompleteorder.label.orderIsCreated" }
        /// Price
        internal static var price: String { Localizable.tr("Waves", "dexcompleteorder.label.price") }
        internal static var priceKey: String { "dexcompleteorder.label.price" }
        /// Status
        internal static var status: String { Localizable.tr("Waves", "dexcompleteorder.label.status") }
        internal static var statusKey: String { "dexcompleteorder.label.status" }
        /// Time
        internal static var time: String { Localizable.tr("Waves", "dexcompleteorder.label.time") }
        internal static var timeKey: String { "dexcompleteorder.label.time" }
      }
    }

    internal enum Dexcreateorder {

      internal enum Alert {
        /// Limit
        internal static var limitOrder: String { Localizable.tr("Waves", "dexcreateorder.alert.limitOrder") }
        internal static var limitOrderKey: String { "dexcreateorder.alert.limitOrder" }
        /// Market
        internal static var marketOrder: String { Localizable.tr("Waves", "dexcreateorder.alert.marketOrder") }
        internal static var marketOrderKey: String { "dexcreateorder.alert.marketOrder" }
        /// Order Type
        internal static var orderType: String { Localizable.tr("Waves", "dexcreateorder.alert.orderType") }
        internal static var orderTypeKey: String { "dexcreateorder.alert.orderType" }
      }

      internal enum Button {
        /// Ask
        internal static var ask: String { Localizable.tr("Waves", "dexcreateorder.button.ask") }
        internal static var askKey: String { "dexcreateorder.button.ask" }
        /// Bid
        internal static var bid: String { Localizable.tr("Waves", "dexcreateorder.button.bid") }
        internal static var bidKey: String { "dexcreateorder.button.bid" }
        /// Buy
        internal static var buy: String { Localizable.tr("Waves", "dexcreateorder.button.buy") }
        internal static var buyKey: String { "dexcreateorder.button.buy" }
        /// Cancel
        internal static var cancel: String { Localizable.tr("Waves", "dexcreateorder.button.cancel") }
        internal static var cancelKey: String { "dexcreateorder.button.cancel" }
        /// day
        internal static var day: String { Localizable.tr("Waves", "dexcreateorder.button.day") }
        internal static var dayKey: String { "dexcreateorder.button.day" }
        /// days
        internal static var days: String { Localizable.tr("Waves", "dexcreateorder.button.days") }
        internal static var daysKey: String { "dexcreateorder.button.days" }
        /// hour
        internal static var hour: String { Localizable.tr("Waves", "dexcreateorder.button.hour") }
        internal static var hourKey: String { "dexcreateorder.button.hour" }
        /// Last
        internal static var last: String { Localizable.tr("Waves", "dexcreateorder.button.last") }
        internal static var lastKey: String { "dexcreateorder.button.last" }
        /// minutes
        internal static var minutes: String { Localizable.tr("Waves", "dexcreateorder.button.minutes") }
        internal static var minutesKey: String { "dexcreateorder.button.minutes" }
        /// Sell
        internal static var sell: String { Localizable.tr("Waves", "dexcreateorder.button.sell") }
        internal static var sellKey: String { "dexcreateorder.button.sell" }
        /// Use total balance
        internal static var useTotalBalanace: String { Localizable.tr("Waves", "dexcreateorder.button.useTotalBalanace") }
        internal static var useTotalBalanaceKey: String { "dexcreateorder.button.useTotalBalanace" }
        /// week
        internal static var week: String { Localizable.tr("Waves", "dexcreateorder.button.week") }
        internal static var weekKey: String { "dexcreateorder.button.week" }
      }

      internal enum Invalidpricepopup {
        /// Do you want to proceed?
        internal static var subtitle: String { Localizable.tr("Waves", "dexcreateorder.invalidPricePopup.subtitle") }
        internal static var subtitleKey: String { "dexcreateorder.invalidPricePopup.subtitle" }

        internal enum Button {
          /// Cancel
          internal static var cancel: String { Localizable.tr("Waves", "dexcreateorder.invalidPricePopup.button.cancel") }
          internal static var cancelKey: String { "dexcreateorder.invalidPricePopup.button.cancel" }
          /// Place Order
          internal static var placeOrder: String { Localizable.tr("Waves", "dexcreateorder.invalidPricePopup.button.placeOrder") }
          internal static var placeOrderKey: String { "dexcreateorder.invalidPricePopup.button.placeOrder" }
        }

        internal enum Title {
          /// You order price is %d%% higher than the latest market price
          internal static func higherPrice(_ p1: Int) -> String {
            Localizable.tr("Waves", "dexcreateorder.invalidPricePopup.title.higherPrice", p1)
          }
          /// Your order price is %d%% lower than the latest market price
          internal static func loverPrice(_ p1: Int) -> String {
            Localizable.tr("Waves", "dexcreateorder.invalidPricePopup.title.loverPrice", p1)
          }
        }
      }

      internal enum Label {
        /// Amount in
        internal static var amountIn: String { Localizable.tr("Waves", "dexcreateorder.label.amountIn") }
        internal static var amountInKey: String { "dexcreateorder.label.amountIn" }
        /// Value is too big
        internal static var bigValue: String { Localizable.tr("Waves", "dexcreateorder.label.bigValue") }
        internal static var bigValueKey: String { "dexcreateorder.label.bigValue" }
        /// days
        internal static var days: String { Localizable.tr("Waves", "dexcreateorder.label.days") }
        internal static var daysKey: String { "dexcreateorder.label.days" }
        /// Expiration
        internal static var expiration: String { Localizable.tr("Waves", "dexcreateorder.label.Expiration") }
        internal static var expirationKey: String { "dexcreateorder.label.Expiration" }
        /// Fee
        internal static var fee: String { Localizable.tr("Waves", "dexcreateorder.label.fee") }
        internal static var feeKey: String { "dexcreateorder.label.fee" }
        /// Limit Order
        internal static var limitOrder: String { Localizable.tr("Waves", "dexcreateorder.label.limitOrder") }
        internal static var limitOrderKey: String { "dexcreateorder.label.limitOrder" }
        /// Limit Price in
        internal static var limitPriceIn: String { Localizable.tr("Waves", "dexcreateorder.label.limitPriceIn") }
        internal static var limitPriceInKey: String { "dexcreateorder.label.limitPriceIn" }
        /// Market Order
        internal static var marketOrder: String { Localizable.tr("Waves", "dexcreateorder.label.marketOrder") }
        internal static var marketOrderKey: String { "dexcreateorder.label.marketOrder" }
        /// Not enough
        internal static var notEnough: String { Localizable.tr("Waves", "dexcreateorder.label.notEnough") }
        internal static var notEnoughKey: String { "dexcreateorder.label.notEnough" }
        /// Value is too small
        internal static var smallValue: String { Localizable.tr("Waves", "dexcreateorder.label.smallValue") }
        internal static var smallValueKey: String { "dexcreateorder.label.smallValue" }
        /// Total in
        internal static var totalIn: String { Localizable.tr("Waves", "dexcreateorder.label.totalIn") }
        internal static var totalInKey: String { "dexcreateorder.label.totalIn" }

        internal enum Error {
          /// You don't have enough funds to pay the required fees.
          internal static var notFundsFee: String { Localizable.tr("Waves", "dexcreateorder.label.error.notFundsFee") }
          internal static var notFundsFeeKey: String { "dexcreateorder.label.error.notFundsFee" }
        }
      }
    }

    internal enum Dexcreateorderinfo {

      internal enum Button {
        /// Got it
        internal static var gotIt: String { Localizable.tr("Waves", "dexcreateorderinfo.button.gotIt") }
        internal static var gotItKey: String { "dexcreateorderinfo.button.gotIt" }
      }

      internal enum Label {
        /// Limit
        internal static var limit: String { Localizable.tr("Waves", "dexcreateorderinfo.label.limit") }
        internal static var limitKey: String { "dexcreateorderinfo.label.limit" }
        /// It is an order placed in the order book at a specific (limit) price.
        internal static var limitDescription: String { Localizable.tr("Waves", "dexcreateorderinfo.label.limitDescription") }
        internal static var limitDescriptionKey: String { "dexcreateorderinfo.label.limitDescription" }
        /// Market
        internal static var market: String { Localizable.tr("Waves", "dexcreateorderinfo.label.market") }
        internal static var marketKey: String { "dexcreateorderinfo.label.market" }
        /// It is an order to buy or sell instantly, at the best available price.
        internal static var marketDescription: String { Localizable.tr("Waves", "dexcreateorderinfo.label.marketDescription") }
        internal static var marketDescriptionKey: String { "dexcreateorderinfo.label.marketDescription" }
        /// Order Types
        internal static var orderTypes: String { Localizable.tr("Waves", "dexcreateorderinfo.label.orderTypes") }
        internal static var orderTypesKey: String { "dexcreateorderinfo.label.orderTypes" }
      }
    }

    internal enum Dexinfo {

      internal enum Label {
        /// Amount Token
        internal static var amountAsset: String { Localizable.tr("Waves", "dexinfo.label.amountAsset") }
        internal static var amountAssetKey: String { "dexinfo.label.amountAsset" }
        /// Popular
        internal static var popular: String { Localizable.tr("Waves", "dexinfo.label.popular") }
        internal static var popularKey: String { "dexinfo.label.popular" }
        /// Price Token
        internal static var priceAsset: String { Localizable.tr("Waves", "dexinfo.label.priceAsset") }
        internal static var priceAssetKey: String { "dexinfo.label.priceAsset" }
      }
    }

    internal enum Dexlasttrades {

      internal enum Button {
        /// BUY
        internal static var buy: String { Localizable.tr("Waves", "dexlasttrades.button.buy") }
        internal static var buyKey: String { "dexlasttrades.button.buy" }
        /// SELL
        internal static var sell: String { Localizable.tr("Waves", "dexlasttrades.button.sell") }
        internal static var sellKey: String { "dexlasttrades.button.sell" }
      }

      internal enum Label {
        /// Amount
        internal static var amount: String { Localizable.tr("Waves", "dexlasttrades.label.amount") }
        internal static var amountKey: String { "dexlasttrades.label.amount" }
        /// Nothing Here…\nThe trading history is empty
        internal static var emptyData: String { Localizable.tr("Waves", "dexlasttrades.label.emptyData") }
        internal static var emptyDataKey: String { "dexlasttrades.label.emptyData" }
        /// Loading last trades…
        internal static var loadingLastTrades: String { Localizable.tr("Waves", "dexlasttrades.label.loadingLastTrades") }
        internal static var loadingLastTradesKey: String { "dexlasttrades.label.loadingLastTrades" }
        /// Price
        internal static var price: String { Localizable.tr("Waves", "dexlasttrades.label.price") }
        internal static var priceKey: String { "dexlasttrades.label.price" }
        /// Sum
        internal static var sum: String { Localizable.tr("Waves", "dexlasttrades.label.sum") }
        internal static var sumKey: String { "dexlasttrades.label.sum" }
        /// Time
        internal static var time: String { Localizable.tr("Waves", "dexlasttrades.label.time") }
        internal static var timeKey: String { "dexlasttrades.label.time" }
      }
    }

    internal enum Dexlist {

      internal enum Button {
        /// Add Markets
        internal static var addMarkets: String { Localizable.tr("Waves", "dexlist.button.addMarkets") }
        internal static var addMarketsKey: String { "dexlist.button.addMarkets" }
      }

      internal enum Label {
        /// Decentralised Exchange
        internal static var decentralisedExchange: String { Localizable.tr("Waves", "dexlist.label.decentralisedExchange") }
        internal static var decentralisedExchangeKey: String { "dexlist.label.decentralisedExchange" }
        /// Trade quickly and securely. You retain complete control over your funds when trading them on our decentralised exchange.
        internal static var description: String { Localizable.tr("Waves", "dexlist.label.description") }
        internal static var descriptionKey: String { "dexlist.label.description" }
        /// Last update
        internal static var lastUpdate: String { Localizable.tr("Waves", "dexlist.label.lastUpdate") }
        internal static var lastUpdateKey: String { "dexlist.label.lastUpdate" }
        /// Price
        internal static var price: String { Localizable.tr("Waves", "dexlist.label.price") }
        internal static var priceKey: String { "dexlist.label.price" }
        /// Today
        internal static var today: String { Localizable.tr("Waves", "dexlist.label.today") }
        internal static var todayKey: String { "dexlist.label.today" }
        /// Yesterday
        internal static var yesterday: String { Localizable.tr("Waves", "dexlist.label.yesterday") }
        internal static var yesterdayKey: String { "dexlist.label.yesterday" }
      }

      internal enum Navigationbar {
        /// Exchange
        internal static var title: String { Localizable.tr("Waves", "dexlist.navigationBar.title") }
        internal static var titleKey: String { "dexlist.navigationBar.title" }
      }
    }

    internal enum Dexmarket {

      internal enum Label {
        /// Loading markets…
        internal static var loadingMarkets: String { Localizable.tr("Waves", "dexmarket.label.loadingMarkets") }
        internal static var loadingMarketsKey: String { "dexmarket.label.loadingMarkets" }
      }

      internal enum Navigationbar {
        /// Markets
        internal static var title: String { Localizable.tr("Waves", "dexmarket.navigationBar.title") }
        internal static var titleKey: String { "dexmarket.navigationBar.title" }
        /// Search pairs to
        internal static var titleAsset: String { Localizable.tr("Waves", "dexmarket.navigationBar.titleAsset") }
        internal static var titleAssetKey: String { "dexmarket.navigationBar.titleAsset" }
      }

      internal enum Searchbar {
        /// Search
        internal static var placeholder: String { Localizable.tr("Waves", "dexmarket.searchBar.placeholder") }
        internal static var placeholderKey: String { "dexmarket.searchBar.placeholder" }
      }
    }

    internal enum Dexmyorders {

      internal enum Label {
        /// Active
        internal static var active: String { Localizable.tr("Waves", "dexmyorders.label.active") }
        internal static var activeKey: String { "dexmyorders.label.active" }
        /// All
        internal static var all: String { Localizable.tr("Waves", "dexmyorders.label.all") }
        internal static var allKey: String { "dexmyorders.label.all" }
        /// Amount
        internal static var amount: String { Localizable.tr("Waves", "dexmyorders.label.amount") }
        internal static var amountKey: String { "dexmyorders.label.amount" }
        /// Buy
        internal static var buy: String { Localizable.tr("Waves", "dexmyorders.label.buy") }
        internal static var buyKey: String { "dexmyorders.label.buy" }
        /// Cancelled
        internal static var cancelled: String { Localizable.tr("Waves", "dexmyorders.label.cancelled") }
        internal static var cancelledKey: String { "dexmyorders.label.cancelled" }
        /// Closed
        internal static var closed: String { Localizable.tr("Waves", "dexmyorders.label.closed") }
        internal static var closedKey: String { "dexmyorders.label.closed" }
        /// Nothing Here…\nYou do not have any orders
        internal static var emptyData: String { Localizable.tr("Waves", "dexmyorders.label.emptyData") }
        internal static var emptyDataKey: String { "dexmyorders.label.emptyData" }
        /// Loading orders…
        internal static var loadingLastTrades: String { Localizable.tr("Waves", "dexmyorders.label.loadingLastTrades") }
        internal static var loadingLastTradesKey: String { "dexmyorders.label.loadingLastTrades" }
        /// Price
        internal static var price: String { Localizable.tr("Waves", "dexmyorders.label.price") }
        internal static var priceKey: String { "dexmyorders.label.price" }
        /// Sell
        internal static var sell: String { Localizable.tr("Waves", "dexmyorders.label.sell") }
        internal static var sellKey: String { "dexmyorders.label.sell" }
        /// Status
        internal static var status: String { Localizable.tr("Waves", "dexmyorders.label.status") }
        internal static var statusKey: String { "dexmyorders.label.status" }
        /// Sum
        internal static var sum: String { Localizable.tr("Waves", "dexmyorders.label.sum") }
        internal static var sumKey: String { "dexmyorders.label.sum" }
        /// Time
        internal static var time: String { Localizable.tr("Waves", "dexmyorders.label.time") }
        internal static var timeKey: String { "dexmyorders.label.time" }
        /// Type
        internal static var type: String { Localizable.tr("Waves", "dexmyorders.label.type") }
        internal static var typeKey: String { "dexmyorders.label.type" }

        internal enum Status {
          /// Open
          internal static var accepted: String { Localizable.tr("Waves", "dexmyorders.label.status.accepted") }
          internal static var acceptedKey: String { "dexmyorders.label.status.accepted" }
          /// Cancelled
          internal static var cancelled: String { Localizable.tr("Waves", "dexmyorders.label.status.cancelled") }
          internal static var cancelledKey: String { "dexmyorders.label.status.cancelled" }
          /// Filled
          internal static var filled: String { Localizable.tr("Waves", "dexmyorders.label.status.filled") }
          internal static var filledKey: String { "dexmyorders.label.status.filled" }
          /// Partial
          internal static var partiallyFilled: String { Localizable.tr("Waves", "dexmyorders.label.status.partiallyFilled") }
          internal static var partiallyFilledKey: String { "dexmyorders.label.status.partiallyFilled" }
        }
      }
    }

    internal enum Dexorderbook {

      internal enum Button {
        /// BUY
        internal static var buy: String { Localizable.tr("Waves", "dexorderbook.button.buy") }
        internal static var buyKey: String { "dexorderbook.button.buy" }
        /// SELL
        internal static var sell: String { Localizable.tr("Waves", "dexorderbook.button.sell") }
        internal static var sellKey: String { "dexorderbook.button.sell" }
      }

      internal enum Label {
        /// Amount
        internal static var amount: String { Localizable.tr("Waves", "dexorderbook.label.amount") }
        internal static var amountKey: String { "dexorderbook.label.amount" }
        /// Nothing Here…\nThe order book is empty
        internal static var emptyData: String { Localizable.tr("Waves", "dexorderbook.label.emptyData") }
        internal static var emptyDataKey: String { "dexorderbook.label.emptyData" }
        /// LAST PRICE
        internal static var lastPrice: String { Localizable.tr("Waves", "dexorderbook.label.lastPrice") }
        internal static var lastPriceKey: String { "dexorderbook.label.lastPrice" }
        /// Loading orderbook…
        internal static var loadingOrderbook: String { Localizable.tr("Waves", "dexorderbook.label.loadingOrderbook") }
        internal static var loadingOrderbookKey: String { "dexorderbook.label.loadingOrderbook" }
        /// Price
        internal static var price: String { Localizable.tr("Waves", "dexorderbook.label.price") }
        internal static var priceKey: String { "dexorderbook.label.price" }
        /// SPREAD
        internal static var spread: String { Localizable.tr("Waves", "dexorderbook.label.spread") }
        internal static var spreadKey: String { "dexorderbook.label.spread" }
        /// Sum
        internal static var sum: String { Localizable.tr("Waves", "dexorderbook.label.sum") }
        internal static var sumKey: String { "dexorderbook.label.sum" }
      }
    }

    internal enum Dexscriptassetmessage {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { Localizable.tr("Waves", "dexScriptAssetMessage.button.cancel") }
        internal static var cancelKey: String { "dexScriptAssetMessage.button.cancel" }
        /// Continue
        internal static var `continue`: String { Localizable.tr("Waves", "dexScriptAssetMessage.button.continue") }
        internal static var continueKey: String { "dexScriptAssetMessage.button.continue" }
        /// Do not show again
        internal static var doNotShowAgain: String { Localizable.tr("Waves", "dexScriptAssetMessage.button.doNotShowAgain") }
        internal static var doNotShowAgainKey: String { "dexScriptAssetMessage.button.doNotShowAgain" }
      }

      internal enum Label {
        /// Smart assets are assets that include a script that sets the conditions for the circulation of the token.\n\nWe do not recommend you perform operations with smart assets if you are an inexperienced user. Before making a transaction, please read the information about the asset and its script carefully.
        internal static var description: String { Localizable.tr("Waves", "dexScriptAssetMessage.label.description") }
        internal static var descriptionKey: String { "dexScriptAssetMessage.label.description" }
        /// Order placement for a pair that includes a Smart Asset
        internal static var title: String { Localizable.tr("Waves", "dexScriptAssetMessage.label.title") }
        internal static var titleKey: String { "dexScriptAssetMessage.label.title" }
      }
    }

    internal enum Dexsort {

      internal enum Navigationbar {
        /// Sorting
        internal static var title: String { Localizable.tr("Waves", "dexsort.navigationBar.title") }
        internal static var titleKey: String { "dexsort.navigationBar.title" }
      }
    }

    internal enum Dextradercontainer {

      internal enum Button {
        /// Chart
        internal static var chart: String { Localizable.tr("Waves", "dextradercontainer.button.chart") }
        internal static var chartKey: String { "dextradercontainer.button.chart" }
        /// Last trades
        internal static var lastTrades: String { Localizable.tr("Waves", "dextradercontainer.button.lastTrades") }
        internal static var lastTradesKey: String { "dextradercontainer.button.lastTrades" }
        /// My orders
        internal static var myOrders: String { Localizable.tr("Waves", "dextradercontainer.button.myOrders") }
        internal static var myOrdersKey: String { "dextradercontainer.button.myOrders" }
        /// Orderbook
        internal static var orderbook: String { Localizable.tr("Waves", "dextradercontainer.button.orderbook") }
        internal static var orderbookKey: String { "dextradercontainer.button.orderbook" }
      }
    }

    internal enum Editaccountname {

      internal enum Button {
        /// Save
        internal static var save: String { Localizable.tr("Waves", "editaccountname.button.save") }
        internal static var saveKey: String { "editaccountname.button.save" }
      }

      internal enum Label {
        /// New account name
        internal static var newName: String { Localizable.tr("Waves", "editaccountname.label.newName") }
        internal static var newNameKey: String { "editaccountname.label.newName" }
      }

      internal enum Navigation {
        /// Edit name
        internal static var title: String { Localizable.tr("Waves", "editaccountname.navigation.title") }
        internal static var titleKey: String { "editaccountname.navigation.title" }
      }
    }

    internal enum Enter {

      internal enum Block {

        internal enum Blockchain {
          /// Become part of a fast-growing area of the crypto world. You are the only person who can access your crypto assets.
          internal static var text: String { Localizable.tr("Waves", "enter.block.blockchain.text") }
          internal static var textKey: String { "enter.block.blockchain.text" }
          /// Get Started with Blockchain
          internal static var title: String { Localizable.tr("Waves", "enter.block.blockchain.title") }
          internal static var titleKey: String { "enter.block.blockchain.title" }
        }

        internal enum Exchange {
          /// Trade quickly and securely. You retain complete control over your funds when trading them on our decentralised exchange.
          internal static var text: String { Localizable.tr("Waves", "enter.block.exchange.text") }
          internal static var textKey: String { "enter.block.exchange.text" }
          /// Decentralised Exchange
          internal static var title: String { Localizable.tr("Waves", "enter.block.exchange.title") }
          internal static var titleKey: String { "enter.block.exchange.title" }
        }

        internal enum Token {
          /// Issue your own tokens. These can be integrated into your business not only as an internal currency but also as a token for decentralised voting, as a rating system, or loyalty program.
          internal static var text: String { Localizable.tr("Waves", "enter.block.token.text") }
          internal static var textKey: String { "enter.block.token.text" }
          /// Token Launcher
          internal static var title: String { Localizable.tr("Waves", "enter.block.token.title") }
          internal static var titleKey: String { "enter.block.token.title" }
        }

        internal enum Wallet {
          /// Store, manage and receive interest on your digital tokens balance, easily and securely.
          internal static var text: String { Localizable.tr("Waves", "enter.block.wallet.text") }
          internal static var textKey: String { "enter.block.wallet.text" }
          /// Wallet
          internal static var title: String { Localizable.tr("Waves", "enter.block.wallet.title") }
          internal static var titleKey: String { "enter.block.wallet.title" }
        }
      }

      internal enum Button {

        internal enum Confirm {
          /// Confirm
          internal static var title: String { Localizable.tr("Waves", "enter.button.confirm.title") }
          internal static var titleKey: String { "enter.button.confirm.title" }
        }

        internal enum Createnewaccount {
          /// Create a new account
          internal static var title: String { Localizable.tr("Waves", "enter.button.createNewAccount.title") }
          internal static var titleKey: String { "enter.button.createNewAccount.title" }
        }

        internal enum Importaccount {
          /// via pairing code or manually
          internal static var detail: String { Localizable.tr("Waves", "enter.button.importAccount.detail") }
          internal static var detailKey: String { "enter.button.importAccount.detail" }
          /// Import account
          internal static var title: String { Localizable.tr("Waves", "enter.button.importAccount.title") }
          internal static var titleKey: String { "enter.button.importAccount.title" }

          internal enum Error {
            /// Insecure SEED
            internal static var insecureSeed: String { Localizable.tr("Waves", "enter.button.importAccount.error.insecureSeed") }
            internal static var insecureSeedKey: String { "enter.button.importAccount.error.insecureSeed" }
          }
        }

        internal enum Signin {
          /// to a saved account
          internal static var detail: String { Localizable.tr("Waves", "enter.button.signIn.detail") }
          internal static var detailKey: String { "enter.button.signIn.detail" }
          /// Sign in
          internal static var title: String { Localizable.tr("Waves", "enter.button.signIn.title") }
          internal static var titleKey: String { "enter.button.signIn.title" }
        }
      }

      internal enum Label {
        /// or
        internal static var or: String { Localizable.tr("Waves", "enter.label.or") }
        internal static var orKey: String { "enter.label.or" }
      }

      internal enum Language {

        internal enum Navigation {
          /// Change language
          internal static var title: String { Localizable.tr("Waves", "enter.language.navigation.title") }
          internal static var titleKey: String { "enter.language.navigation.title" }
        }
      }
    }

    internal enum Forceupdate {

      internal enum Button {
        /// Update
        internal static var update: String { Localizable.tr("Waves", "forceupdate.button.update") }
        internal static var updateKey: String { "forceupdate.button.update" }
      }

      internal enum Label {
        /// To continue using the app, please update it to the %@ version.
        internal static func subtitle(_ p1: String) -> String {
          Localizable.tr("Waves", "forceupdate.label.subtitle", p1)
        }
        /// It is time to update your app!
        internal static var title: String { Localizable.tr("Waves", "forceupdate.label.title") }
        internal static var titleKey: String { "forceupdate.label.title" }
      }
    }

    internal enum General {

      internal enum Biometric {

        internal enum Faceid {
          /// Face ID
          internal static var title: String { Localizable.tr("Waves", "general.biometric.faceID.title") }
          internal static var titleKey: String { "general.biometric.faceID.title" }
        }

        internal enum Touchid {
          /// Touch ID
          internal static var title: String { Localizable.tr("Waves", "general.biometric.touchID.title") }
          internal static var titleKey: String { "general.biometric.touchID.title" }
        }
      }

      internal enum Error {

        internal enum Subtitle {
          /// Do not worry, we are already fixing this problem.\nSoon everything will work!
          internal static var notfound: String { Localizable.tr("Waves", "general.error.subtitle.notfound") }
          internal static var notfoundKey: String { "general.error.subtitle.notfound" }
        }

        internal enum Title {
          /// No connection to the Internet
          internal static var noconnectiontotheinternet: String { Localizable.tr("Waves", "general.error.title.noconnectiontotheinternet") }
          internal static var noconnectiontotheinternetKey: String { "general.error.title.noconnectiontotheinternet" }
          /// Oh… It's all broken!
          internal static var notfound: String { Localizable.tr("Waves", "general.error.title.notfound") }
          internal static var notfoundKey: String { "general.error.title.notfound" }
        }
      }

      internal enum Label {

        internal enum Title {
          /// / My token
          internal static var myasset: String { Localizable.tr("Waves", "general.label.title.myasset") }
          internal static var myassetKey: String { "general.label.title.myasset" }
        }
      }

      internal enum Tabbar {

        internal enum Title {
          /// Exchange
          internal static var dex: String { Localizable.tr("Waves", "general.tabbar.title.dex") }
          internal static var dexKey: String { "general.tabbar.title.dex" }
          /// History
          internal static var history: String { Localizable.tr("Waves", "general.tabbar.title.history") }
          internal static var historyKey: String { "general.tabbar.title.history" }
          /// Profile
          internal static var profile: String { Localizable.tr("Waves", "general.tabbar.title.profile") }
          internal static var profileKey: String { "general.tabbar.title.profile" }
          /// Wallet
          internal static var wallet: String { Localizable.tr("Waves", "general.tabbar.title.wallet") }
          internal static var walletKey: String { "general.tabbar.title.wallet" }
        }
      }

      internal enum Ticker {

        internal enum Title {
          /// Cryptocurrency
          internal static var cryptocurrency: String { Localizable.tr("Waves", "general.ticker.title.cryptocurrency") }
          internal static var cryptocurrencyKey: String { "general.ticker.title.cryptocurrency" }
          /// Fiat Money
          internal static var fiatmoney: String { Localizable.tr("Waves", "general.ticker.title.fiatmoney") }
          internal static var fiatmoneyKey: String { "general.ticker.title.fiatmoney" }
          /// SUSPICIOUS
          internal static var spam: String { Localizable.tr("Waves", "general.ticker.title.spam") }
          internal static var spamKey: String { "general.ticker.title.spam" }
          /// Waves Token
          internal static var wavestoken: String { Localizable.tr("Waves", "general.ticker.title.wavestoken") }
          internal static var wavestokenKey: String { "general.ticker.title.wavestoken" }
        }
      }

      internal enum Tost {

        internal enum Savebackup {
          /// Store your SEED safely, it is the only way to restore your wallet
          internal static var subtitle: String { Localizable.tr("Waves", "general.tost.saveBackup.subtitle") }
          internal static var subtitleKey: String { "general.tost.saveBackup.subtitle" }
          /// Save your backup phrase (SEED)
          internal static var title: String { Localizable.tr("Waves", "general.tost.saveBackup.title") }
          internal static var titleKey: String { "general.tost.saveBackup.title" }
        }
      }
    }

    internal enum Hello {

      internal enum Button {
        /// Begin
        internal static var begin: String { Localizable.tr("Waves", "hello.button.begin") }
        internal static var beginKey: String { "hello.button.begin" }
        /// Continue
        internal static var `continue`: String { Localizable.tr("Waves", "hello.button.continue") }
        internal static var continueKey: String { "hello.button.continue" }
        /// Next
        internal static var next: String { Localizable.tr("Waves", "hello.button.next") }
        internal static var nextKey: String { "hello.button.next" }
      }

      internal enum Page {

        internal enum Confirm {
          /// I understand that my funds are held securely on this device, not by a company. If this app is moved to another device or deleted, my Waves can only be recovered with the backup phrase.
          internal static var description1: String { Localizable.tr("Waves", "hello.page.confirm.description1") }
          internal static var description1Key: String { "hello.page.confirm.description1" }
          /// I have read and agree with the Privacy Policy
          internal static var description2: String { Localizable.tr("Waves", "hello.page.confirm.description2") }
          internal static var description2Key: String { "hello.page.confirm.description2" }
          /// I have read and agree with the Terms and Conditions
          internal static var description3: String { Localizable.tr("Waves", "hello.page.confirm.description3") }
          internal static var description3Key: String { "hello.page.confirm.description3" }
          /// All the data on your Waves Wallet is encrypted and stored only on your device
          internal static var subtitle: String { Localizable.tr("Waves", "hello.page.confirm.subtitle") }
          internal static var subtitleKey: String { "hello.page.confirm.subtitle" }
          /// Confirm and begin
          internal static var title: String { Localizable.tr("Waves", "hello.page.confirm.title") }
          internal static var titleKey: String { "hello.page.confirm.title" }

          internal enum Button {
            /// Privacy policy
            internal static var privacyPolicy: String { Localizable.tr("Waves", "hello.page.confirm.button.privacyPolicy") }
            internal static var privacyPolicyKey: String { "hello.page.confirm.button.privacyPolicy" }
            /// Terms and conditions
            internal static var termsAndConditions: String { Localizable.tr("Waves", "hello.page.confirm.button.termsAndConditions") }
            internal static var termsAndConditionsKey: String { "hello.page.confirm.button.termsAndConditions" }
          }

          internal enum Subtitle {
            /// All the data on your Waves.Exchange is encrypted and stored only on your device.
            internal static var migration: String { Localizable.tr("Waves", "hello.page.confirm.subtitle.migration") }
            internal static var migrationKey: String { "hello.page.confirm.subtitle.migration" }
          }
        }

        internal enum Info {

          internal enum Fifth {
            /// How To Protect Yourself from Phishers
            internal static var title: String { Localizable.tr("Waves", "hello.page.info.fifth.title") }
            internal static var titleKey: String { "hello.page.info.fifth.title" }

            internal enum Detail {
              /// Do not open emails or links from unknown senders.
              internal static var first: String { Localizable.tr("Waves", "hello.page.info.fifth.detail.first") }
              internal static var firstKey: String { "hello.page.info.fifth.detail.first" }
              /// Do not access your wallet when using public Wi-Fi or someone else’s device.
              internal static var fourth: String { Localizable.tr("Waves", "hello.page.info.fifth.detail.fourth") }
              internal static var fourthKey: String { "hello.page.info.fifth.detail.fourth" }
              /// Regularly update your operating system.
              internal static var second: String { Localizable.tr("Waves", "hello.page.info.fifth.detail.second") }
              internal static var secondKey: String { "hello.page.info.fifth.detail.second" }
              /// Use official security software. Do not install unknown software which could be hacked.
              internal static var third: String { Localizable.tr("Waves", "hello.page.info.fifth.detail.third") }
              internal static var thirdKey: String { "hello.page.info.fifth.detail.third" }
            }
          }

          internal enum First {
            /// Please take some time to understand some important things for your own safety.\n\nWe cannot recover your funds or freeze your account if you visit a phishing site or lose your backup phrase (aka SEED phrase).\n\nBy continuing to use our platform, you agree to accept all risks associated with the loss of your SEED, including but not limited to the inability to obtain your funds and dispose of them. In case you lose your SEED, you agree and acknowledge that the Waves.Exchange would not be responsible for the negative consequences of this.
            internal static var detail: String { Localizable.tr("Waves", "hello.page.info.first.detail") }
            internal static var detailKey: String { "hello.page.info.first.detail" }
            /// Welcome to the Waves.Exchange!
            internal static var title: String { Localizable.tr("Waves", "hello.page.info.first.title") }
            internal static var titleKey: String { "hello.page.info.first.title" }
          }

          internal enum Fourth {
            /// One of the most common forms of scamming is phishing, which is when scammers create fake communities on Facebook or other websites that look similar to the authentic ones.
            internal static var detail: String { Localizable.tr("Waves", "hello.page.info.fourth.detail") }
            internal static var detailKey: String { "hello.page.info.fourth.detail" }
            /// How To Protect Yourself from Phishers
            internal static var title: String { Localizable.tr("Waves", "hello.page.info.fourth.title") }
            internal static var titleKey: String { "hello.page.info.fourth.title" }
          }

          internal enum Second {
            /// When registering your account, you will be asked to save your secret phrase (Seed) and to protect your account with a password. On normal centralized servers, special attention is paid to the password, which can be changed and reset via email, if the need arises. However, on decentralized platforms such as Waves, everything is arranged differently.
            internal static var detail: String { Localizable.tr("Waves", "hello.page.info.second.detail") }
            internal static var detailKey: String { "hello.page.info.second.detail" }
            /// What you need to know about your SEED
            internal static var title: String { Localizable.tr("Waves", "hello.page.info.second.title") }
            internal static var titleKey: String { "hello.page.info.second.title" }
          }

          internal enum Third {
            /// What you need to know about your SEED
            internal static var title: String { Localizable.tr("Waves", "hello.page.info.third.title") }
            internal static var titleKey: String { "hello.page.info.third.title" }

            internal enum Detail {
              /// You use your wallet anonymously, meaning your account is not connected to an email account or any other identifying data.
              internal static var first: String { Localizable.tr("Waves", "hello.page.info.third.detail.first") }
              internal static var firstKey: String { "hello.page.info.third.detail.first" }
              /// You cannot change your secret phrase. If you accidentally sent it to someone or suspect that scammers have taken it over, then create a new Waves wallet immediately and transfer your funds to it.
              internal static var fourth: String { Localizable.tr("Waves", "hello.page.info.third.detail.fourth") }
              internal static var fourthKey: String { "hello.page.info.third.detail.fourth" }
              /// Your password protects your account when working on a certain device or browser. It is needed in order to ensure that your secret phrase is not saved in storage.
              internal static var second: String { Localizable.tr("Waves", "hello.page.info.third.detail.second") }
              internal static var secondKey: String { "hello.page.info.third.detail.second" }
              /// If you forget your password, you can easily create a new one by using the account recovery form via your secret phrase. If you lose your secret phrase, however, you will have no way to access your account.
              internal static var third: String { Localizable.tr("Waves", "hello.page.info.third.detail.third") }
              internal static var thirdKey: String { "hello.page.info.third.detail.third" }
            }
          }
        }
      }
    }

    internal enum History {

      internal enum Navigationbar {
        /// History
        internal static var title: String { Localizable.tr("Waves", "history.navigationBar.title") }
        internal static var titleKey: String { "history.navigationBar.title" }
      }

      internal enum Segmentedcontrol {
        /// Active Now
        internal static var activeNow: String { Localizable.tr("Waves", "history.segmentedControl.activeNow") }
        internal static var activeNowKey: String { "history.segmentedControl.activeNow" }
        /// All
        internal static var all: String { Localizable.tr("Waves", "history.segmentedControl.all") }
        internal static var allKey: String { "history.segmentedControl.all" }
        /// Canceled
        internal static var canceled: String { Localizable.tr("Waves", "history.segmentedControl.canceled") }
        internal static var canceledKey: String { "history.segmentedControl.canceled" }
        /// Exchanged
        internal static var exchanged: String { Localizable.tr("Waves", "history.segmentedControl.exchanged") }
        internal static var exchangedKey: String { "history.segmentedControl.exchanged" }
        /// Issued
        internal static var issued: String { Localizable.tr("Waves", "history.segmentedControl.issued") }
        internal static var issuedKey: String { "history.segmentedControl.issued" }
        /// Leased
        internal static var leased: String { Localizable.tr("Waves", "history.segmentedControl.leased") }
        internal static var leasedKey: String { "history.segmentedControl.leased" }
        /// Received
        internal static var received: String { Localizable.tr("Waves", "history.segmentedControl.received") }
        internal static var receivedKey: String { "history.segmentedControl.received" }
        /// Sent
        internal static var sent: String { Localizable.tr("Waves", "history.segmentedControl.sent") }
        internal static var sentKey: String { "history.segmentedControl.sent" }
      }

      internal enum Transaction {

        internal enum Cell {

          internal enum Exchange {
            /// Buy: %@/%@
            internal static func buy(_ p1: String, _ p2: String) -> String {
              Localizable.tr("Waves", "history.transaction.cell.exchange.buy", p1, p2)
            }
            /// Sell: %@/%@
            internal static func sell(_ p1: String, _ p2: String) -> String {
              Localizable.tr("Waves", "history.transaction.cell.exchange.sell", p1, p2)
            }
          }
        }

        internal enum Title {
          /// Create Alias
          internal static var alias: String { Localizable.tr("Waves", "history.transaction.title.alias") }
          internal static var aliasKey: String { "history.transaction.title.alias" }
          /// Canceled Leasing
          internal static var canceledLeasing: String { Localizable.tr("Waves", "history.transaction.title.canceledLeasing") }
          internal static var canceledLeasingKey: String { "history.transaction.title.canceledLeasing" }
          /// Data transaction
          internal static var data: String { Localizable.tr("Waves", "history.transaction.title.data") }
          internal static var dataKey: String { "history.transaction.title.data" }
          /// Entry in blockchain
          internal static var entryInBlockchain: String { Localizable.tr("Waves", "history.transaction.title.entryInBlockchain") }
          internal static var entryInBlockchainKey: String { "history.transaction.title.entryInBlockchain" }
          /// Exchange
          internal static var exchange: String { Localizable.tr("Waves", "history.transaction.title.exchange") }
          internal static var exchangeKey: String { "history.transaction.title.exchange" }
          /// Incoming Leasing
          internal static var incomingLeasing: String { Localizable.tr("Waves", "history.transaction.title.incomingLeasing") }
          internal static var incomingLeasingKey: String { "history.transaction.title.incomingLeasing" }
          /// Mass Received
          internal static var massreceived: String { Localizable.tr("Waves", "history.transaction.title.massreceived") }
          internal static var massreceivedKey: String { "history.transaction.title.massreceived" }
          /// Mass Sent
          internal static var masssent: String { Localizable.tr("Waves", "history.transaction.title.masssent") }
          internal static var masssentKey: String { "history.transaction.title.masssent" }
          /// Received
          internal static var received: String { Localizable.tr("Waves", "history.transaction.title.received") }
          internal static var receivedKey: String { "history.transaction.title.received" }
          /// Received Sponsorship
          internal static var receivedSponsorship: String { Localizable.tr("Waves", "history.transaction.title.receivedSponsorship") }
          internal static var receivedSponsorshipKey: String { "history.transaction.title.receivedSponsorship" }
          /// Self-transfer
          internal static var selfTransfer: String { Localizable.tr("Waves", "history.transaction.title.selfTransfer") }
          internal static var selfTransferKey: String { "history.transaction.title.selfTransfer" }
          /// Sent
          internal static var sent: String { Localizable.tr("Waves", "history.transaction.title.sent") }
          internal static var sentKey: String { "history.transaction.title.sent" }
          /// Entry in blockchain
          internal static var setAssetScript: String { Localizable.tr("Waves", "history.transaction.title.setAssetScript") }
          internal static var setAssetScriptKey: String { "history.transaction.title.setAssetScript" }
          /// Entry in blockchain
          internal static var setScript: String { Localizable.tr("Waves", "history.transaction.title.setScript") }
          internal static var setScriptKey: String { "history.transaction.title.setScript" }
          /// Started Leasing
          internal static var startedLeasing: String { Localizable.tr("Waves", "history.transaction.title.startedLeasing") }
          internal static var startedLeasingKey: String { "history.transaction.title.startedLeasing" }
          /// Token Burn
          internal static var tokenBurn: String { Localizable.tr("Waves", "history.transaction.title.tokenBurn") }
          internal static var tokenBurnKey: String { "history.transaction.title.tokenBurn" }
          /// Token Generation
          internal static var tokenGeneration: String { Localizable.tr("Waves", "history.transaction.title.tokenGeneration") }
          internal static var tokenGenerationKey: String { "history.transaction.title.tokenGeneration" }
          /// Token Reissue
          internal static var tokenReissue: String { Localizable.tr("Waves", "history.transaction.title.tokenReissue") }
          internal static var tokenReissueKey: String { "history.transaction.title.tokenReissue" }
          /// Unrecognised Transaction
          internal static var unrecognisedTransaction: String { Localizable.tr("Waves", "history.transaction.title.unrecognisedTransaction") }
          internal static var unrecognisedTransactionKey: String { "history.transaction.title.unrecognisedTransaction" }
        }

        internal enum Value {
          /// Entry in blockchain
          internal static var data: String { Localizable.tr("Waves", "history.transaction.value.data") }
          internal static var dataKey: String { "history.transaction.value.data" }
          /// Script Invocation
          internal static var scriptInvocation: String { Localizable.tr("Waves", "history.transaction.value.scriptInvocation") }
          internal static var scriptInvocationKey: String { "history.transaction.value.scriptInvocation" }
          /// Update Script
          internal static var setAssetScript: String { Localizable.tr("Waves", "history.transaction.value.setAssetScript") }
          internal static var setAssetScriptKey: String { "history.transaction.value.setAssetScript" }

          internal enum Setscript {
            /// Cancel Script
            internal static var cancel: String { Localizable.tr("Waves", "history.transaction.value.setScript.cancel") }
            internal static var cancelKey: String { "history.transaction.value.setScript.cancel" }
            /// Set Script
            internal static var `set`: String { Localizable.tr("Waves", "history.transaction.value.setScript.set") }
            internal static var setKey: String { "history.transaction.value.setScript.set" }
          }

          internal enum Setsponsorship {
            /// Disable Sponsorship
            internal static var cancel: String { Localizable.tr("Waves", "history.transaction.value.setSponsorship.cancel") }
            internal static var cancelKey: String { "history.transaction.value.setSponsorship.cancel" }
            /// Set Sponsorship
            internal static var `set`: String { Localizable.tr("Waves", "history.transaction.value.setSponsorship.set") }
            internal static var setKey: String { "history.transaction.value.setSponsorship.set" }
          }
        }
      }
    }

    internal enum Import {

      internal enum Account {

        internal enum Button {

          internal enum Enter {
            /// Enter SEED manually
            internal static var title: String { Localizable.tr("Waves", "import.account.button.enter.title") }
            internal static var titleKey: String { "import.account.button.enter.title" }
          }

          internal enum Scan {
            /// Scan pairing code
            internal static var title: String { Localizable.tr("Waves", "import.account.button.scan.title") }
            internal static var titleKey: String { "import.account.button.scan.title" }
          }
        }

        internal enum Label {

          internal enum Info {

            internal enum Step {

              internal enum One {
                /// Settings — General — Export account
                internal static var detail: String { Localizable.tr("Waves", "import.account.label.info.step.one.detail") }
                internal static var detailKey: String { "import.account.label.info.step.one.detail" }
                /// Log in to your Waves Client via your PC or Mac at https://waves.exchange
                internal static var title: String { Localizable.tr("Waves", "import.account.label.info.step.one.title") }
                internal static var titleKey: String { "import.account.label.info.step.one.title" }
              }

              internal enum Two {
                /// Click «Show Pairing Code» to reveal a QR Code. Scan the code with your camera.
                internal static var title: String { Localizable.tr("Waves", "import.account.label.info.step.two.title") }
                internal static var titleKey: String { "import.account.label.info.step.two.title" }
              }
            }
          }
        }

        internal enum Navigation {
          /// Import account
          internal static var title: String { Localizable.tr("Waves", "import.account.navigation.title") }
          internal static var titleKey: String { "import.account.navigation.title" }
        }

        internal enum Warning {

          internal enum Seed {
            /// The SEED phrase you entered is too short. Make sure you do not confuse the phrase with a wallet address. Using an address as a SEED phrase can result in loss of funds.
            internal static var subtitle: String { Localizable.tr("Waves", "import.account.warning.seed.subtitle") }
            internal static var subtitleKey: String { "import.account.warning.seed.subtitle" }
            /// The SEED phrase must consist of 15 words with spaces between each word
            internal static var title: String { Localizable.tr("Waves", "import.account.warning.seed.title") }
            internal static var titleKey: String { "import.account.warning.seed.title" }
          }
        }
      }

      internal enum General {

        internal enum Error {
          /// Already in use
          internal static var alreadyinuse: String { Localizable.tr("Waves", "import.general.error.alreadyinuse") }
          internal static var alreadyinuseKey: String { "import.general.error.alreadyinuse" }
        }

        internal enum Navigation {
          /// Import account
          internal static var title: String { Localizable.tr("Waves", "import.general.navigation.title") }
          internal static var titleKey: String { "import.general.navigation.title" }
        }

        internal enum Segmentedcontrol {
          /// Manually
          internal static var manually: String { Localizable.tr("Waves", "import.general.segmentedControl.manually") }
          internal static var manuallyKey: String { "import.general.segmentedControl.manually" }
          /// Scan
          internal static var scan: String { Localizable.tr("Waves", "import.general.segmentedControl.scan") }
          internal static var scanKey: String { "import.general.segmentedControl.scan" }
        }
      }

      internal enum Manually {

        internal enum Button {
          /// Continue
          internal static var `continue`: String { Localizable.tr("Waves", "import.manually.button.continue") }
          internal static var continueKey: String { "import.manually.button.continue" }
        }

        internal enum Label {

          internal enum Address {
            /// Your SEED is the 15 words you saved when creating your account
            internal static var placeholder: String { Localizable.tr("Waves", "import.manually.label.address.placeholder") }
            internal static var placeholderKey: String { "import.manually.label.address.placeholder" }
            /// Your account SEED
            internal static var title: String { Localizable.tr("Waves", "import.manually.label.address.title") }
            internal static var titleKey: String { "import.manually.label.address.title" }
          }
        }
      }

      internal enum Password {

        internal enum Button {
          /// Continue
          internal static var `continue`: String { Localizable.tr("Waves", "import.password.button.continue") }
          internal static var continueKey: String { "import.password.button.continue" }
        }
      }

      internal enum Scan {

        internal enum Button {
          /// Scan pairing code
          internal static var title: String { Localizable.tr("Waves", "import.scan.button.title") }
          internal static var titleKey: String { "import.scan.button.title" }
        }

        internal enum Label {

          internal enum Step {

            internal enum One {
              /// Log in to your Waves Client via web or Mac, PC
              internal static var title: String { Localizable.tr("Waves", "import.scan.label.step.one.title") }
              internal static var titleKey: String { "import.scan.label.step.one.title" }
            }

            internal enum Three {
              /// Scan the code with your camera
              internal static var title: String { Localizable.tr("Waves", "import.scan.label.step.three.title") }
              internal static var titleKey: String { "import.scan.label.step.three.title" }
            }

            internal enum Two {
              /// Settings — General — Export account
              internal static var detail: String { Localizable.tr("Waves", "import.scan.label.step.two.detail") }
              internal static var detailKey: String { "import.scan.label.step.two.detail" }
              /// Click «Show Pairing Code» to reveal a QR Code
              internal static var title: String { Localizable.tr("Waves", "import.scan.label.step.two.title") }
              internal static var titleKey: String { "import.scan.label.step.two.title" }
            }
          }
        }
      }

      internal enum Welcome {

        internal enum Button {
          /// Continue
          internal static var `continue`: String { Localizable.tr("Waves", "import.welcome.button.continue") }
          internal static var continueKey: String { "import.welcome.button.continue" }
        }

        internal enum Label {

          internal enum Address {
            /// Your SEED is the 15 words you saved when creating your account
            internal static var placeholder: String { Localizable.tr("Waves", "import.welcome.label.address.placeholder") }
            internal static var placeholderKey: String { "import.welcome.label.address.placeholder" }
            /// Your account SEED
            internal static var title: String { Localizable.tr("Waves", "import.welcome.label.address.title") }
            internal static var titleKey: String { "import.welcome.label.address.title" }
          }
        }

        internal enum Navigation {
          /// Welcome back
          internal static var title: String { Localizable.tr("Waves", "import.welcome.navigation.title") }
          internal static var titleKey: String { "import.welcome.navigation.title" }
        }
      }
    }

    internal enum Keeper {

      internal enum Button {
        /// Approve
        internal static var approve: String { Localizable.tr("Waves", "keeper.button.approve") }
        internal static var approveKey: String { "keeper.button.approve" }
        /// Reject
        internal static var reject: String { Localizable.tr("Waves", "keeper.button.reject") }
        internal static var rejectKey: String { "keeper.button.reject" }
      }

      internal enum Label {
        /// Confirm request
        internal static var confirmRequest: String { Localizable.tr("Waves", "keeper.label.confirmRequest") }
        internal static var confirmRequestKey: String { "keeper.label.confirmRequest" }
        /// Function
        internal static var function: String { Localizable.tr("Waves", "keeper.label.function") }
        internal static var functionKey: String { "keeper.label.function" }
        /// To
        internal static var to: String { Localizable.tr("Waves", "keeper.label.to") }
        internal static var toKey: String { "keeper.label.to" }
        /// TX time
        internal static var txTime: String { Localizable.tr("Waves", "keeper.label.txTime") }
        internal static var txTimeKey: String { "keeper.label.txTime" }
      }

      internal enum Transaction {
        /// Your transaction is confirmed!
        internal static var confirmed: String { Localizable.tr("Waves", "keeper.transaction.confirmed") }
        internal static var confirmedKey: String { "keeper.transaction.confirmed" }
        /// Your transaction failed
        internal static var failed: String { Localizable.tr("Waves", "keeper.transaction.failed") }
        internal static var failedKey: String { "keeper.transaction.failed" }
      }
    }

    internal enum Menu {

      internal enum Button {
        /// FAQ
        internal static var faq: String { Localizable.tr("Waves", "menu.button.faq") }
        internal static var faqKey: String { "menu.button.faq" }
        /// Support
        internal static var supportwavesplatform: String { Localizable.tr("Waves", "menu.button.supportwavesplatform") }
        internal static var supportwavesplatformKey: String { "menu.button.supportwavesplatform" }
        /// Terms and conditions
        internal static var termsandconditions: String { Localizable.tr("Waves", "menu.button.termsandconditions") }
        internal static var termsandconditionsKey: String { "menu.button.termsandconditions" }
        /// Whitepaper
        internal static var whitepaper: String { Localizable.tr("Waves", "menu.button.whitepaper") }
        internal static var whitepaperKey: String { "menu.button.whitepaper" }
      }

      internal enum Label {
        /// Our Social Media
        internal static var communities: String { Localizable.tr("Waves", "menu.label.communities") }
        internal static var communitiesKey: String { "menu.label.communities" }
        /// Keep up with the latest news and articles, and find out all about events happening on the Waves.Exchange
        internal static var description: String { Localizable.tr("Waves", "menu.label.description") }
        internal static var descriptionKey: String { "menu.label.description" }
      }
    }

    internal enum Migration {

      internal enum Wavesexchange {

        internal enum View {
          /// To offer users a better experience and wider range of tools, the exchange is moved from Waves DEX to Waves.Exchange.\n\nDon’t worry! All of your tokens, seed phrases and passwords are safe.
          internal static var description: String { Localizable.tr("Waves", "migration.wavesexchange.view.description") }
          internal static var descriptionKey: String { "migration.wavesexchange.view.description" }
          /// We moved!
          internal static var title: String { Localizable.tr("Waves", "migration.wavesexchange.view.title") }
          internal static var titleKey: String { "migration.wavesexchange.view.title" }
        }
      }
    }

    internal enum Myaddress {

      internal enum Button {

        internal enum Copy {
          /// Copy
          internal static var title: String { Localizable.tr("Waves", "myaddress.button.copy.title") }
          internal static var titleKey: String { "myaddress.button.copy.title" }
        }

        internal enum Share {
          /// Share
          internal static var title: String { Localizable.tr("Waves", "myaddress.button.share.title") }
          internal static var titleKey: String { "myaddress.button.share.title" }
        }
      }

      internal enum Cell {

        internal enum Aliases {
          /// Aliases
          internal static var title: String { Localizable.tr("Waves", "myaddress.cell.aliases.title") }
          internal static var titleKey: String { "myaddress.cell.aliases.title" }

          internal enum Subtitle {
            /// You have %d
            internal static func withaliaces(_ p1: Int) -> String {
              Localizable.tr("Waves", "myaddress.cell.aliases.subtitle.withaliaces", p1)
            }
            /// You do not have
            internal static var withoutaliaces: String { Localizable.tr("Waves", "myaddress.cell.aliases.subtitle.withoutaliaces") }
            internal static var withoutaliacesKey: String { "myaddress.cell.aliases.subtitle.withoutaliaces" }
          }
        }

        internal enum Info {
          /// Your address
          internal static var title: String { Localizable.tr("Waves", "myaddress.cell.info.title") }
          internal static var titleKey: String { "myaddress.cell.info.title" }
        }

        internal enum Qrcode {
          /// Your QR Code
          internal static var title: String { Localizable.tr("Waves", "myaddress.cell.qrcode.title") }
          internal static var titleKey: String { "myaddress.cell.qrcode.title" }
        }
      }
    }

    internal enum Myorders {

      internal enum Alert {

        internal enum Button {
          /// No
          internal static var no: String { Localizable.tr("Waves", "myorders.alert.button.no") }
          internal static var noKey: String { "myorders.alert.button.no" }
          /// Yes
          internal static var yes: String { Localizable.tr("Waves", "myorders.alert.button.yes") }
          internal static var yesKey: String { "myorders.alert.button.yes" }
        }

        internal enum Cancelallorders {
          /// Are you sure you want to cancel all active orders?
          internal static var subtitle: String { Localizable.tr("Waves", "myorders.alert.cancelAllOrders.subtitle") }
          internal static var subtitleKey: String { "myorders.alert.cancelAllOrders.subtitle" }
          /// Cancel All Orders
          internal static var title: String { Localizable.tr("Waves", "myorders.alert.cancelAllOrders.title") }
          internal static var titleKey: String { "myorders.alert.cancelAllOrders.title" }
        }

        internal enum Cancelorder {
          /// Are you sure you want to cancel order %@?
          internal static func subTitle(_ p1: String) -> String {
            Localizable.tr("Waves", "myorders.alert.cancelOrder.subTitle", p1)
          }
          /// Cancel Order
          internal static var title: String { Localizable.tr("Waves", "myorders.alert.cancelOrder.title") }
          internal static var titleKey: String { "myorders.alert.cancelOrder.title" }
        }
      }

      internal enum Message {
        /// Orders cancelled
        internal static var success: String { Localizable.tr("Waves", "myorders.message.success") }
        internal static var successKey: String { "myorders.message.success" }

        internal enum Cancelorder {
          /// Order cancelled
          internal static var success: String { Localizable.tr("Waves", "myorders.message.cancelOrder.success") }
          internal static var successKey: String { "myorders.message.cancelOrder.success" }
        }

        internal enum Cancelorders {
          /// Orders cancelled
          internal static var success: String { Localizable.tr("Waves", "myorders.message.cancelOrders.success") }
          internal static var successKey: String { "myorders.message.cancelOrders.success" }
        }
      }
    }

    internal enum Networksettings {

      internal enum Button {

        internal enum Save {
          /// Save
          internal static var title: String { Localizable.tr("Waves", "networksettings.button.save.title") }
          internal static var titleKey: String { "networksettings.button.save.title" }
        }

        internal enum Setdefault {
          /// Set default
          internal static var title: String { Localizable.tr("Waves", "networksettings.button.setdefault.title") }
          internal static var titleKey: String { "networksettings.button.setdefault.title" }
        }
      }

      internal enum Label {

        internal enum Switchspam {
          /// Spam filtering
          internal static var title: String { Localizable.tr("Waves", "networksettings.label.switchspam.title") }
          internal static var titleKey: String { "networksettings.label.switchspam.title" }
        }
      }

      internal enum Navigation {
        /// Network
        internal static var title: String { Localizable.tr("Waves", "networksettings.navigation.title") }
        internal static var titleKey: String { "networksettings.navigation.title" }
      }

      internal enum Textfield {

        internal enum Spamfilter {
          /// Spam filter
          internal static var title: String { Localizable.tr("Waves", "networksettings.textfield.spamfilter.title") }
          internal static var titleKey: String { "networksettings.textfield.spamfilter.title" }
        }
      }
    }

    internal enum Newaccount {

      internal enum Avatar {
        /// You cannot change it later
        internal static var detail: String { Localizable.tr("Waves", "newaccount.avatar.detail") }
        internal static var detailKey: String { "newaccount.avatar.detail" }
        /// Choose your unique address avatar
        internal static var title: String { Localizable.tr("Waves", "newaccount.avatar.title") }
        internal static var titleKey: String { "newaccount.avatar.title" }
      }

      internal enum Backup {

        internal enum Navigation {
          /// New Account
          internal static var title: String { Localizable.tr("Waves", "newaccount.backup.navigation.title") }
          internal static var titleKey: String { "newaccount.backup.navigation.title" }
        }
      }

      internal enum Error {
        /// No avatar selected
        internal static var noavatarselected: String { Localizable.tr("Waves", "newaccount.error.noavatarselected") }
        internal static var noavatarselectedKey: String { "newaccount.error.noavatarselected" }
      }

      internal enum Main {

        internal enum Navigation {
          /// New Account
          internal static var title: String { Localizable.tr("Waves", "newaccount.main.navigation.title") }
          internal static var titleKey: String { "newaccount.main.navigation.title" }
        }
      }

      internal enum Secret {

        internal enum Navigation {
          /// New Account
          internal static var title: String { Localizable.tr("Waves", "newaccount.secret.navigation.title") }
          internal static var titleKey: String { "newaccount.secret.navigation.title" }
        }
      }

      internal enum Textfield {

        internal enum Accountname {
          /// Account name
          internal static var title: String { Localizable.tr("Waves", "newaccount.textfield.accountName.title") }
          internal static var titleKey: String { "newaccount.textfield.accountName.title" }
        }

        internal enum Confirmpassword {
          /// Confirm password
          internal static var title: String { Localizable.tr("Waves", "newaccount.textfield.confirmpassword.title") }
          internal static var titleKey: String { "newaccount.textfield.confirmpassword.title" }
        }

        internal enum Createpassword {
          /// Create a password
          internal static var title: String { Localizable.tr("Waves", "newaccount.textfield.createpassword.title") }
          internal static var titleKey: String { "newaccount.textfield.createpassword.title" }
        }

        internal enum Error {
          /// Minimum %d characters
          internal static func atleastcharacters(_ p1: Int) -> String {
            Localizable.tr("Waves", "newaccount.textfield.error.atleastcharacters", p1)
          }
          /// %d characters maximum
          internal static func charactersmaximum(_ p1: Int) -> String {
            Localizable.tr("Waves", "newaccount.textfield.error.charactersmaximum", p1)
          }
          /// Does not match
          internal static var doesnotmatch: String { Localizable.tr("Waves", "newaccount.textfield.error.doesnotmatch") }
          internal static var doesnotmatchKey: String { "newaccount.textfield.error.doesnotmatch" }
          /// %d characters maximum
          internal static func maximumcharacters(_ p1: Int) -> String {
            Localizable.tr("Waves", "newaccount.textfield.error.maximumcharacters", p1)
          }
          /// Minimum %d characters
          internal static func minimumcharacters(_ p1: Int) -> String {
            Localizable.tr("Waves", "newaccount.textfield.error.minimumcharacters", p1)
          }
          /// password not match
          internal static var passwordnotmatch: String { Localizable.tr("Waves", "newaccount.textfield.error.passwordnotmatch") }
          internal static var passwordnotmatchKey: String { "newaccount.textfield.error.passwordnotmatch" }
          /// Wrong order, try again
          internal static var wrongordertryagain: String { Localizable.tr("Waves", "newaccount.textfield.error.wrongordertryagain") }
          internal static var wrongordertryagainKey: String { "newaccount.textfield.error.wrongordertryagain" }
        }
      }
    }

    internal enum Passcode {

      internal enum Alert {

        internal enum Attempsended {
          /// To unlock, sign in with your account password
          internal static var subtitle: String { Localizable.tr("Waves", "passcode.alert.attempsended.subtitle") }
          internal static var subtitleKey: String { "passcode.alert.attempsended.subtitle" }
          /// Too many attempts
          internal static var title: String { Localizable.tr("Waves", "passcode.alert.attempsended.title") }
          internal static var titleKey: String { "passcode.alert.attempsended.title" }

          internal enum Button {
            /// Cancel
            internal static var cancel: String { Localizable.tr("Waves", "passcode.alert.attempsended.button.cancel") }
            internal static var cancelKey: String { "passcode.alert.attempsended.button.cancel" }
            /// Use Password
            internal static var enterpassword: String { Localizable.tr("Waves", "passcode.alert.attempsended.button.enterpassword") }
            internal static var enterpasswordKey: String { "passcode.alert.attempsended.button.enterpassword" }
            /// Ok
            internal static var ok: String { Localizable.tr("Waves", "passcode.alert.attempsended.button.ok") }
            internal static var okKey: String { "passcode.alert.attempsended.button.ok" }
          }
        }
      }

      internal enum Button {

        internal enum Forgotpasscode {
          /// Use account password
          internal static var title: String { Localizable.tr("Waves", "passcode.button.forgotPasscode.title") }
          internal static var titleKey: String { "passcode.button.forgotPasscode.title" }
        }
      }

      internal enum Label {

        internal enum Forgotpasscode {
          /// Forgot passcode?
          internal static var title: String { Localizable.tr("Waves", "passcode.label.forgotPasscode.title") }
          internal static var titleKey: String { "passcode.label.forgotPasscode.title" }
        }

        internal enum Passcode {
          /// Create a passcode
          internal static var create: String { Localizable.tr("Waves", "passcode.label.passcode.create") }
          internal static var createKey: String { "passcode.label.passcode.create" }
          /// Enter Passcode
          internal static var enter: String { Localizable.tr("Waves", "passcode.label.passcode.enter") }
          internal static var enterKey: String { "passcode.label.passcode.enter" }
          /// Enter old Passcode
          internal static var old: String { Localizable.tr("Waves", "passcode.label.passcode.old") }
          internal static var oldKey: String { "passcode.label.passcode.old" }
          /// Verify your passcode
          internal static var verify: String { Localizable.tr("Waves", "passcode.label.passcode.verify") }
          internal static var verifyKey: String { "passcode.label.passcode.verify" }
        }
      }
    }

    internal enum Payoutshistory {
      /// Profit
      internal static var profit: String { Localizable.tr("Waves", "payoutsHistory.profit") }
      internal static var profitKey: String { "payoutsHistory.profit" }
      /// Payouts History
      internal static var title: String { Localizable.tr("Waves", "payoutsHistory.title") }
      internal static var titleKey: String { "payoutsHistory.title" }
    }

    internal enum Profile {

      internal enum Alert {

        internal enum Deleteaccount {
          /// Are you sure you want to delete this account from device?
          internal static var message: String { Localizable.tr("Waves", "profile.alert.deleteAccount.message") }
          internal static var messageKey: String { "profile.alert.deleteAccount.message" }
          /// You did not save your SEED
          internal static var notSaveSeed: String { Localizable.tr("Waves", "profile.alert.deleteAccount.notSaveSeed") }
          internal static var notSaveSeedKey: String { "profile.alert.deleteAccount.notSaveSeed" }
          /// Delete account
          internal static var title: String { Localizable.tr("Waves", "profile.alert.deleteAccount.title") }
          internal static var titleKey: String { "profile.alert.deleteAccount.title" }

          internal enum Button {
            /// Cancel
            internal static var cancel: String { Localizable.tr("Waves", "profile.alert.deleteAccount.button.cancel") }
            internal static var cancelKey: String { "profile.alert.deleteAccount.button.cancel" }
            /// Delete
            internal static var delete: String { Localizable.tr("Waves", "profile.alert.deleteAccount.button.delete") }
            internal static var deleteKey: String { "profile.alert.deleteAccount.button.delete" }
          }

          internal enum Withoutbackup {
            /// Deleting an account will lead to its irretrievable loss!
            internal static var message: String { Localizable.tr("Waves", "profile.alert.deleteAccount.withoutbackup.message") }
            internal static var messageKey: String { "profile.alert.deleteAccount.withoutbackup.message" }
          }
        }

        internal enum Setupbiometric {
          /// To use fast and secure login, go to settings to enable biometrics
          internal static var message: String { Localizable.tr("Waves", "profile.alert.setupbiometric.message") }
          internal static var messageKey: String { "profile.alert.setupbiometric.message" }
          /// Biometrics is disabled
          internal static var title: String { Localizable.tr("Waves", "profile.alert.setupbiometric.title") }
          internal static var titleKey: String { "profile.alert.setupbiometric.title" }

          internal enum Button {
            /// Cancel
            internal static var cancel: String { Localizable.tr("Waves", "profile.alert.setupbiometric.button.cancel") }
            internal static var cancelKey: String { "profile.alert.setupbiometric.button.cancel" }
            /// Settings
            internal static var settings: String { Localizable.tr("Waves", "profile.alert.setupbiometric.button.settings") }
            internal static var settingsKey: String { "profile.alert.setupbiometric.button.settings" }
          }
        }
      }

      internal enum Button {

        internal enum Delete {
          /// Delete account from device
          internal static var title: String { Localizable.tr("Waves", "profile.button.delete.title") }
          internal static var titleKey: String { "profile.button.delete.title" }
        }

        internal enum Logout {
          /// Logout of account
          internal static var title: String { Localizable.tr("Waves", "profile.button.logout.title") }
          internal static var titleKey: String { "profile.button.logout.title" }
        }
      }

      internal enum Cell {

        internal enum Addressbook {
          /// Address book
          internal static var title: String { Localizable.tr("Waves", "profile.cell.addressbook.title") }
          internal static var titleKey: String { "profile.cell.addressbook.title" }
        }

        internal enum Addresses {
          /// Addresses, keys
          internal static var title: String { Localizable.tr("Waves", "profile.cell.addresses.title") }
          internal static var titleKey: String { "profile.cell.addresses.title" }
        }

        internal enum Backupphrase {
          /// Backup phrase
          internal static var title: String { Localizable.tr("Waves", "profile.cell.backupphrase.title") }
          internal static var titleKey: String { "profile.cell.backupphrase.title" }
        }

        internal enum Changepasscode {
          /// Change passcode
          internal static var title: String { Localizable.tr("Waves", "profile.cell.changepasscode.title") }
          internal static var titleKey: String { "profile.cell.changepasscode.title" }
        }

        internal enum Changepassword {
          /// Change password
          internal static var title: String { Localizable.tr("Waves", "profile.cell.changepassword.title") }
          internal static var titleKey: String { "profile.cell.changepassword.title" }
        }

        internal enum Currentheight {
          /// Current height
          internal static var title: String { Localizable.tr("Waves", "profile.cell.currentheight.title") }
          internal static var titleKey: String { "profile.cell.currentheight.title" }
        }

        internal enum Feedback {
          /// Feedback
          internal static var title: String { Localizable.tr("Waves", "profile.cell.feedback.title") }
          internal static var titleKey: String { "profile.cell.feedback.title" }
        }

        internal enum Info {

          internal enum Currentheight {
            /// Current height
            internal static var title: String { Localizable.tr("Waves", "profile.cell.info.currentheight.title") }
            internal static var titleKey: String { "profile.cell.info.currentheight.title" }
          }

          internal enum Version {
            /// Version
            internal static var title: String { Localizable.tr("Waves", "profile.cell.info.version.title") }
            internal static var titleKey: String { "profile.cell.info.version.title" }
          }
        }

        internal enum Language {
          /// Language
          internal static var title: String { Localizable.tr("Waves", "profile.cell.language.title") }
          internal static var titleKey: String { "profile.cell.language.title" }
        }

        internal enum Network {
          /// Network
          internal static var title: String { Localizable.tr("Waves", "profile.cell.network.title") }
          internal static var titleKey: String { "profile.cell.network.title" }
        }

        internal enum Pushnotifications {
          /// Push Notifications
          internal static var title: String { Localizable.tr("Waves", "profile.cell.pushnotifications.title") }
          internal static var titleKey: String { "profile.cell.pushnotifications.title" }
        }

        internal enum Rateapp {
          /// Rate app
          internal static var title: String { Localizable.tr("Waves", "profile.cell.rateApp.title") }
          internal static var titleKey: String { "profile.cell.rateApp.title" }
        }

        internal enum Supportwavesplatform {
          /// Support
          internal static var title: String { Localizable.tr("Waves", "profile.cell.supportwavesplatform.title") }
          internal static var titleKey: String { "profile.cell.supportwavesplatform.title" }
        }
      }

      internal enum Header {

        internal enum General {
          /// General settings
          internal static var title: String { Localizable.tr("Waves", "profile.header.general.title") }
          internal static var titleKey: String { "profile.header.general.title" }
        }

        internal enum Other {
          /// Other
          internal static var title: String { Localizable.tr("Waves", "profile.header.other.title") }
          internal static var titleKey: String { "profile.header.other.title" }
        }

        internal enum Security {
          /// Security
          internal static var title: String { Localizable.tr("Waves", "profile.header.security.title") }
          internal static var titleKey: String { "profile.header.security.title" }
        }
      }

      internal enum Language {

        internal enum Navigation {
          /// Language
          internal static var title: String { Localizable.tr("Waves", "profile.language.navigation.title") }
          internal static var titleKey: String { "profile.language.navigation.title" }
        }
      }

      internal enum Navigation {
        /// Profile
        internal static var title: String { Localizable.tr("Waves", "profile.navigation.title") }
        internal static var titleKey: String { "profile.navigation.title" }
      }
    }

    internal enum Pushnotificationsalert {

      internal enum Button {
        /// Yes, notify me
        internal static var activatePush: String { Localizable.tr("Waves", "pushNotificationsAlert.button.activatePush") }
        internal static var activatePushKey: String { "pushNotificationsAlert.button.activatePush" }
        /// Maybe later
        internal static var later: String { Localizable.tr("Waves", "pushNotificationsAlert.button.later") }
        internal static var laterKey: String { "pushNotificationsAlert.button.later" }
      }

      internal enum Label {
        /// We'd like to show you notifications for the latest news and updates.
        internal static var subtitle: String { Localizable.tr("Waves", "pushNotificationsAlert.label.subtitle") }
        internal static var subtitleKey: String { "pushNotificationsAlert.label.subtitle" }
        /// Get important notifications
        internal static var title: String { Localizable.tr("Waves", "pushNotificationsAlert.label.title") }
        internal static var titleKey: String { "pushNotificationsAlert.label.title" }
      }
    }

    internal enum Receive {

      internal enum Button {
        /// Card
        internal static var card: String { Localizable.tr("Waves", "receive.button.card") }
        internal static var cardKey: String { "receive.button.card" }
        /// Continue
        internal static var `continue`: String { Localizable.tr("Waves", "receive.button.continue") }
        internal static var continueKey: String { "receive.button.continue" }
        /// External Source
        internal static var cryptocurrency: String { Localizable.tr("Waves", "receive.button.cryptocurrency") }
        internal static var cryptocurrencyKey: String { "receive.button.cryptocurrency" }
        /// Waves Account
        internal static var invoice: String { Localizable.tr("Waves", "receive.button.invoice") }
        internal static var invoiceKey: String { "receive.button.invoice" }
        /// Use total balance
        internal static var useTotalBalance: String { Localizable.tr("Waves", "receive.button.useTotalBalance") }
        internal static var useTotalBalanceKey: String { "receive.button.useTotalBalance" }
      }

      internal enum Error {
        /// Service is temporarily unavailable
        internal static var serviceUnavailable: String { Localizable.tr("Waves", "receive.error.serviceUnavailable") }
        internal static var serviceUnavailableKey: String { "receive.error.serviceUnavailable" }
      }

      internal enum Label {
        /// Amount
        internal static var amount: String { Localizable.tr("Waves", "receive.label.amount") }
        internal static var amountKey: String { "receive.label.amount" }
        /// Amount in
        internal static var amountIn: String { Localizable.tr("Waves", "receive.label.amountIn") }
        internal static var amountInKey: String { "receive.label.amountIn" }
        /// Token
        internal static var asset: String { Localizable.tr("Waves", "receive.label.asset") }
        internal static var assetKey: String { "receive.label.asset" }
        /// Receive
        internal static var receive: String { Localizable.tr("Waves", "receive.label.receive") }
        internal static var receiveKey: String { "receive.label.receive" }
        /// Select your token
        internal static var selectYourAsset: String { Localizable.tr("Waves", "receive.label.selectYourAsset") }
        internal static var selectYourAssetKey: String { "receive.label.selectYourAsset" }
      }

      internal enum Tootltip {

        internal enum Addressoptions {
          /// Address Options
          internal static var title: String { Localizable.tr("Waves", "receive.tootltip.addressOptions.title") }
          internal static var titleKey: String { "receive.tootltip.addressOptions.title" }

          internal enum Externalsource {
            /// Use this option for receiving funds from other exchanges and crypto-wallets.
            internal static var subtitle: String { Localizable.tr("Waves", "receive.tootltip.addressOptions.externalsource.subtitle") }
            internal static var subtitleKey: String { "receive.tootltip.addressOptions.externalsource.subtitle" }
            /// External Source
            internal static var title: String { Localizable.tr("Waves", "receive.tootltip.addressOptions.externalsource.title") }
            internal static var titleKey: String { "receive.tootltip.addressOptions.externalsource.title" }
          }

          internal enum Wavesaccount {
            /// Use this option to receive WAVES and Waves-based assets from another account in the Waves blockchain.
            internal static var subtitle: String { Localizable.tr("Waves", "receive.tootltip.addressOptions.wavesaccount.subtitle") }
            internal static var subtitleKey: String { "receive.tootltip.addressOptions.wavesaccount.subtitle" }
            /// Waves Account
            internal static var title: String { Localizable.tr("Waves", "receive.tootltip.addressOptions.wavesaccount.title") }
            internal static var titleKey: String { "receive.tootltip.addressOptions.wavesaccount.title" }
          }
        }
      }
    }

    internal enum Receiveaddress {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { Localizable.tr("Waves", "receiveaddress.button.cancel") }
        internal static var cancelKey: String { "receiveaddress.button.cancel" }
        /// Close
        internal static var close: String { Localizable.tr("Waves", "receiveaddress.button.close") }
        internal static var closeKey: String { "receiveaddress.button.close" }
        /// Сopied!
        internal static var copied: String { Localizable.tr("Waves", "receiveaddress.button.copied") }
        internal static var copiedKey: String { "receiveaddress.button.copied" }
        /// Copy
        internal static var copy: String { Localizable.tr("Waves", "receiveaddress.button.copy") }
        internal static var copyKey: String { "receiveaddress.button.copy" }
        /// Share
        internal static var share: String { Localizable.tr("Waves", "receiveaddress.button.share") }
        internal static var shareKey: String { "receiveaddress.button.share" }
      }

      internal enum Label {
        /// Link to an Invoice
        internal static var linkToInvoice: String { Localizable.tr("Waves", "receiveaddress.label.linkToInvoice") }
        internal static var linkToInvoiceKey: String { "receiveaddress.label.linkToInvoice" }
        /// Your %@ address
        internal static func yourAddress(_ p1: String) -> String {
          Localizable.tr("Waves", "receiveaddress.label.yourAddress", p1)
        }
        /// Your QR Code
        internal static var yourQRCode: String { Localizable.tr("Waves", "receiveaddress.label.yourQRCode") }
        internal static var yourQRCodeKey: String { "receiveaddress.label.yourQRCode" }
      }

      internal enum Tootltip {
        /// Help
        internal static var title: String { Localizable.tr("Waves", "receiveAddress.tootltip.title") }
        internal static var titleKey: String { "receiveAddress.tootltip.title" }

        internal enum Btc {
          /// SegWit Addresses beginning with "bc1" reduce transaction fees, but may not work everywhere. Regular Addresses beginning with "1" work everywhere. Both are safe to use.
          internal static var subtitle: String { Localizable.tr("Waves", "receiveAddress.tootltip.btc.subtitle") }
          internal static var subtitleKey: String { "receiveAddress.tootltip.btc.subtitle" }
          /// Bitcoin Address Options
          internal static var title: String { Localizable.tr("Waves", "receiveAddress.tootltip.btc.title") }
          internal static var titleKey: String { "receiveAddress.tootltip.btc.title" }
        }

        internal enum General {
          /// Once the transaction is confirmed, the gateway will process the transfer of %@ token to your Waves account. Please note that the gateway doesn't apply any fees to this operation.
          internal static func subtitle(_ p1: String) -> String {
            Localizable.tr("Waves", "receiveAddress.tootltip.general.subtitle", p1)
          }
          /// Enter this address into %@ client or wallet
          internal static func title(_ p1: String) -> String {
            Localizable.tr("Waves", "receiveAddress.tootltip.general.title", p1)
          }
        }
      }
    }

    internal enum Receivecard {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { Localizable.tr("Waves", "receivecard.button.cancel") }
        internal static var cancelKey: String { "receivecard.button.cancel" }
      }

      internal enum Label {
        /// Change currency
        internal static var changeCurrency: String { Localizable.tr("Waves", "receivecard.label.changeCurrency") }
        internal static var changeCurrencyKey: String { "receivecard.label.changeCurrency" }
        /// The minimum is %@, the maximum is %@
        internal static func minimunAmountInfo(_ p1: String, _ p2: String) -> String {
          Localizable.tr("Waves", "Receivecard.Label.minimunAmountInfo", p1, p2)
        }
        /// For making a payment from your card you will be redirected to the merchant's website
        internal static var warningInfo: String { Localizable.tr("Waves", "receivecard.label.warningInfo") }
        internal static var warningInfoKey: String { "receivecard.label.warningInfo" }
      }
    }

    internal enum Receivecardcomplete {

      internal enum Button {
        /// Okay
        internal static var okay: String { Localizable.tr("Waves", "receivecardcomplete.button.okay") }
        internal static var okayKey: String { "receivecardcomplete.button.okay" }
      }

      internal enum Label {
        /// After payment has been made your balance will be updated
        internal static var afterPaymentUpdateBalance: String { Localizable.tr("Waves", "receivecardcomplete.label.afterPaymentUpdateBalance") }
        internal static var afterPaymentUpdateBalanceKey: String { "receivecardcomplete.label.afterPaymentUpdateBalance" }
        /// You have been redirected to «Indacoin»
        internal static var redirectToIndacoin: String { Localizable.tr("Waves", "receivecardcomplete.label.redirectToIndacoin") }
        internal static var redirectToIndacoinKey: String { "receivecardcomplete.label.redirectToIndacoin" }
      }
    }

    internal enum Receivecryptocurrency {

      internal enum Address {

        internal enum Default {
          /// Address %@
          internal static func name(_ p1: String) -> String {
            Localizable.tr("Waves", "receiveCryptocurrency.address.default.name", p1)
          }
        }
      }

      internal enum Label {
        /// The minimum amount of deposit is %@
        internal static func minumumAmountOfDeposit(_ p1: String) -> String {
          Localizable.tr("Waves", "receivecryptocurrency.label.minumumAmountOfDeposit", p1)
        }
        /// Send only %@ to this deposit address
        internal static func sendOnlyOnThisDeposit(_ p1: String) -> String {
          Localizable.tr("Waves", "receivecryptocurrency.label.sendOnlyOnThisDeposit", p1)
        }
        /// If you will send less than %@, you will lose that money.
        internal static func warningMinimumAmountOfDeposit(_ p1: String) -> String {
          Localizable.tr("Waves", "receivecryptocurrency.label.warningMinimumAmountOfDeposit", p1)
        }
        /// Sending any other currency to this address may result in the loss of your deposit.
        internal static var warningSendOnlyOnThisDeposit: String { Localizable.tr("Waves", "receivecryptocurrency.label.warningSendOnlyOnThisDeposit") }
        internal static var warningSendOnlyOnThisDepositKey: String { "receivecryptocurrency.label.warningSendOnlyOnThisDeposit" }

        internal enum Warningsmartcontracts {
          /// Check if you wallet or exchange users smart-contracts to withdraw %@. We do not accept such transactions and can’t refund them. You will lose that money.
          internal static func subtitle(_ p1: String) -> String {
            Localizable.tr("Waves", "receivecryptocurrency.label.warningSmartContracts.subtitle", p1)
          }
          /// Please do not deposit %@ form smart contracts! Do not deposit ERC20 tokens! Only %@ is allowed.
          internal static func title(_ p1: String, _ p2: String) -> String {
            Localizable.tr("Waves", "receivecryptocurrency.label.warningSmartContracts.title", p1, p2)
          }
        }
      }
    }

    internal enum Receivegenerate {

      internal enum Label {
        /// Generate…
        internal static var generate: String { Localizable.tr("Waves", "receivegenerate.label.generate") }
        internal static var generateKey: String { "receivegenerate.label.generate" }
        /// Your %@ address
        internal static func yourAddress(_ p1: String) -> String {
          Localizable.tr("Waves", "receivegenerate.label.yourAddress", p1)
        }
      }
    }

    internal enum Receiveinvoice {

      internal enum Label {
        /// US Dollar
        internal static var dollar: String { Localizable.tr("Waves", "receiveinvoice.label.dollar") }
        internal static var dollarKey: String { "receiveinvoice.label.dollar" }
      }
    }

    internal enum Scannerqrcode {

      internal enum Label {
        /// Scan QR
        internal static var scan: String { Localizable.tr("Waves", "scannerqrcode.label.scan") }
        internal static var scanKey: String { "scannerqrcode.label.scan" }
      }
    }

    internal enum Send {

      internal enum Button {
        /// Choose from Address book
        internal static var chooseFromAddressBook: String { Localizable.tr("Waves", "send.button.chooseFromAddressBook") }
        internal static var chooseFromAddressBookKey: String { "send.button.chooseFromAddressBook" }
        /// Continue
        internal static var `continue`: String { Localizable.tr("Waves", "send.button.continue") }
        internal static var continueKey: String { "send.button.continue" }
        /// Use total balance
        internal static var useTotalBalanace: String { Localizable.tr("Waves", "send.button.useTotalBalanace") }
        internal static var useTotalBalanaceKey: String { "send.button.useTotalBalanace" }
      }

      internal enum Label {
        /// The address is not valid
        internal static var addressNotValid: String { Localizable.tr("Waves", "send.label.addressNotValid") }
        internal static var addressNotValidKey: String { "send.label.addressNotValid" }
        /// Amount
        internal static var amount: String { Localizable.tr("Waves", "send.label.amount") }
        internal static var amountKey: String { "send.label.amount" }
        /// US Dollar
        internal static var dollar: String { Localizable.tr("Waves", "send.label.dollar") }
        internal static var dollarKey: String { "send.label.dollar" }
        /// Gateway fee is
        internal static var gatewayFee: String { Localizable.tr("Waves", "send.label.gatewayFee") }
        internal static var gatewayFeeKey: String { "send.label.gatewayFee" }
        /// Monero Payment ID
        internal static var moneroPaymentId: String { Localizable.tr("Waves", "send.label.moneroPaymentId") }
        internal static var moneroPaymentIdKey: String { "send.label.moneroPaymentId" }
        /// Recipient
        internal static var recipient: String { Localizable.tr("Waves", "send.label.recipient") }
        internal static var recipientKey: String { "send.label.recipient" }
        /// Recipient address…
        internal static var recipientAddress: String { Localizable.tr("Waves", "send.label.recipientAddress") }
        internal static var recipientAddressKey: String { "send.label.recipientAddress" }
        /// Send
        internal static var send: String { Localizable.tr("Waves", "send.label.send") }
        internal static var sendKey: String { "send.label.send" }

        internal enum Error {
          /// The token is not valid
          internal static var assetIsNotValid: String { Localizable.tr("Waves", "send.label.error.assetIsNotValid") }
          internal static var assetIsNotValidKey: String { "send.label.error.assetIsNotValid" }
          /// Insufficient funds
          internal static var insufficientFunds: String { Localizable.tr("Waves", "send.label.error.insufficientFunds") }
          internal static var insufficientFundsKey: String { "send.label.error.insufficientFunds" }
          /// invalid ID
          internal static var invalidId: String { Localizable.tr("Waves", "send.label.error.invalidId") }
          internal static var invalidIdKey: String { "send.label.error.invalidId" }
          /// Maximum %@ %@
          internal static func maximum(_ p1: String, _ p2: String) -> String {
            Localizable.tr("Waves", "send.label.error.maximum", p1, p2)
          }
          /// Minimum %@ %@
          internal static func minimun(_ p1: String, _ p2: String) -> String {
            Localizable.tr("Waves", "send.label.error.minimun", p1, p2)
          }
          /// Dear users, with the hardfork in the Monero network payment id option is not supported anymore. More details %@
          internal static func moneroOldAddress(_ p1: String) -> String {
            Localizable.tr("Waves", "send.label.error.moneroOldAddress", p1)
          }
          /// here
          internal static var moneroOldAddressKeyLink: String { Localizable.tr("Waves", "send.label.error.moneroOldAddressKeyLink") }
          internal static var moneroOldAddressKeyLinkKey: String { "send.label.error.moneroOldAddressKeyLink" }
          /// You don't have enough funds to pay the required fees.
          internal static var notFundsFee: String { Localizable.tr("Waves", "send.label.error.notFundsFee") }
          internal static var notFundsFeeKey: String { "send.label.error.notFundsFee" }
          /// You don't have enough funds to pay the required fees. You must pay %@ transaction fee and %@ gateway fee.
          internal static func notFundsFeeGateway(_ p1: String, _ p2: String) -> String {
            Localizable.tr("Waves", "Send.Label.Error.notFundsFeeGateway", p1, p2)
          }
          /// Sending funds to suspicious token is not possible
          internal static var sendingToSpamAsset: String { Localizable.tr("Waves", "send.label.error.sendingToSpamAsset") }
          internal static var sendingToSpamAssetKey: String { "send.label.error.sendingToSpamAsset" }
        }

        internal enum Warning {
          /// Do not withdraw %@ to an ICO. We will not credit your account with tokens from that sale.
          internal static func description(_ p1: String) -> String {
            Localizable.tr("Waves", "Send.Label.Warning.description", p1)
          }
          /// We detected %@ address and will send your money through gateway to that address. Minimum amount is %@, maximum amount is %@.
          internal static func subtitle(_ p1: String, _ p2: String, _ p3: String) -> String {
            Localizable.tr("Waves", "Send.Label.Warning.subtitle", p1, p2, p3)
          }
        }
      }

      internal enum Textfield {
        /// Paste or type your Payment ID
        internal static var placeholderPaymentId: String { Localizable.tr("Waves", "send.textField.placeholderPaymentId") }
        internal static var placeholderPaymentIdKey: String { "send.textField.placeholderPaymentId" }
      }
    }

    internal enum Sendcomplete {

      internal enum Button {
        /// Okay
        internal static var okey: String { Localizable.tr("Waves", "sendcomplete.button.okey") }
        internal static var okeyKey: String { "sendcomplete.button.okey" }
      }

      internal enum Label {
        /// Do you want to save this address?
        internal static var saveThisAddress: String { Localizable.tr("Waves", "sendcomplete.label.saveThisAddress") }
        internal static var saveThisAddressKey: String { "sendcomplete.label.saveThisAddress" }
        /// Your transaction is on the way!
        internal static var transactionIsOnWay: String { Localizable.tr("Waves", "sendcomplete.label.transactionIsOnWay") }
        internal static var transactionIsOnWayKey: String { "sendcomplete.label.transactionIsOnWay" }
        /// You have sent
        internal static var youHaveSent: String { Localizable.tr("Waves", "sendcomplete.label.youHaveSent") }
        internal static var youHaveSentKey: String { "sendcomplete.label.youHaveSent" }
      }
    }

    internal enum Sendconfirmation {

      internal enum Button {
        /// Confirm
        internal static var confim: String { Localizable.tr("Waves", "sendconfirmation.button.confim") }
        internal static var confimKey: String { "sendconfirmation.button.confim" }
      }

      internal enum Label {
        /// Confirmation
        internal static var confirmation: String { Localizable.tr("Waves", "sendconfirmation.label.confirmation") }
        internal static var confirmationKey: String { "sendconfirmation.label.confirmation" }
        /// Description
        internal static var description: String { Localizable.tr("Waves", "sendconfirmation.label.description") }
        internal static var descriptionKey: String { "sendconfirmation.label.description" }
        /// The description is too long
        internal static var descriptionIsTooLong: String { Localizable.tr("Waves", "sendconfirmation.label.descriptionIsTooLong") }
        internal static var descriptionIsTooLongKey: String { "sendconfirmation.label.descriptionIsTooLong" }
        /// US Dollar
        internal static var dollar: String { Localizable.tr("Waves", "sendconfirmation.label.dollar") }
        internal static var dollarKey: String { "sendconfirmation.label.dollar" }
        /// Fee
        internal static var fee: String { Localizable.tr("Waves", "sendconfirmation.label.fee") }
        internal static var feeKey: String { "sendconfirmation.label.fee" }
        /// Gateway Fee
        internal static var gatewayFee: String { Localizable.tr("Waves", "sendconfirmation.label.gatewayFee") }
        internal static var gatewayFeeKey: String { "sendconfirmation.label.gatewayFee" }
        /// Write an optional message
        internal static var optionalMessage: String { Localizable.tr("Waves", "sendconfirmation.label.optionalMessage") }
        internal static var optionalMessageKey: String { "sendconfirmation.label.optionalMessage" }
        /// Sent to
        internal static var sentTo: String { Localizable.tr("Waves", "sendconfirmation.label.sentTo") }
        internal static var sentToKey: String { "sendconfirmation.label.sentTo" }
      }
    }

    internal enum Sendfee {

      internal enum Label {
        /// Not available
        internal static var notAvailable: String { Localizable.tr("Waves", "sendfee.label.notAvailable") }
        internal static var notAvailableKey: String { "sendfee.label.notAvailable" }
        /// Transaction Fee
        internal static var transactionFee: String { Localizable.tr("Waves", "sendfee.label.transactionFee") }
        internal static var transactionFeeKey: String { "sendfee.label.transactionFee" }
      }
    }

    internal enum Sendloading {

      internal enum Label {
        /// Sending…
        internal static var sending: String { Localizable.tr("Waves", "sendloading.label.sending") }
        internal static var sendingKey: String { "sendloading.label.sending" }
      }
    }

    internal enum Serverdisconnect {

      internal enum Label {
        /// Check your connection to the mobile Internet or Wi-Fi network
        internal static var subtitle: String { Localizable.tr("Waves", "serverDisconnect.label.subtitle") }
        internal static var subtitleKey: String { "serverDisconnect.label.subtitle" }
        /// No connection to the Internet
        internal static var title: String { Localizable.tr("Waves", "serverDisconnect.label.title") }
        internal static var titleKey: String { "serverDisconnect.label.title" }
      }
    }

    internal enum Serverengineering {

      internal enum Label {
        /// Hi, at the moment we are doing a very important job of improving the application
        internal static var subtitle: String { Localizable.tr("Waves", "serverEngineering.label.subtitle") }
        internal static var subtitleKey: String { "serverEngineering.label.subtitle" }
        /// Engineering works
        internal static var title: String { Localizable.tr("Waves", "serverEngineering.label.title") }
        internal static var titleKey: String { "serverEngineering.label.title" }
      }
    }

    internal enum Servererror {

      internal enum Button {
        /// Retry
        internal static var retry: String { Localizable.tr("Waves", "serverError.button.retry") }
        internal static var retryKey: String { "serverError.button.retry" }
        /// Send a report
        internal static var sendReport: String { Localizable.tr("Waves", "serverError.button.sendReport") }
        internal static var sendReportKey: String { "serverError.button.sendReport" }
      }

      internal enum Label {
        /// Oh… It's all broken!
        internal static var allBroken: String { Localizable.tr("Waves", "serverError.label.allBroken") }
        internal static var allBrokenKey: String { "serverError.label.allBroken" }
        /// Do not worry, we are already fixing this problem.\nSoon everything will work!
        internal static var allBrokenDescription: String { Localizable.tr("Waves", "serverError.label.allBrokenDescription") }
        internal static var allBrokenDescriptionKey: String { "serverError.label.allBrokenDescription" }
        /// No connection to the Internet
        internal static var noInternetConnection: String { Localizable.tr("Waves", "serverError.label.noInternetConnection") }
        internal static var noInternetConnectionKey: String { "serverError.label.noInternetConnection" }
        /// Check your connection to the mobile Internet or Wi-Fi network
        internal static var noInternetConnectionDescription: String { Localizable.tr("Waves", "serverError.label.noInternetConnectionDescription") }
        internal static var noInternetConnectionDescriptionKey: String { "serverError.label.noInternetConnectionDescription" }
        /// Do not worry, we are already fixing this problem.\nSoon everything will work!
        internal static var subtitle: String { Localizable.tr("Waves", "serverError.label.subtitle") }
        internal static var subtitleKey: String { "serverError.label.subtitle" }
        /// Oh… It's all broken!
        internal static var title: String { Localizable.tr("Waves", "serverError.label.title") }
        internal static var titleKey: String { "serverError.label.title" }
      }
    }

    internal enum Servermaintenance {

      internal enum Button {
        /// Retry
        internal static var retry: String { Localizable.tr("Waves", "serverMaintenance.button.retry") }
        internal static var retryKey: String { "serverMaintenance.button.retry" }
      }

      internal enum Label {
        /// We're moving to Waves.Exchange. Please try again later.
        internal static var subtitle: String { Localizable.tr("Waves", "serverMaintenance.label.subtitle") }
        internal static var subtitleKey: String { "serverMaintenance.label.subtitle" }
        /// Server is temporarily unavailable
        internal static var title: String { Localizable.tr("Waves", "serverMaintenance.label.title") }
        internal static var titleKey: String { "serverMaintenance.label.title" }
      }
    }

    internal enum Staking {
      /// I earned %@USDN passive income, with an average annual yield of %@%%, lying on the couch! #Neutrino #WavesBlockchain
      internal static func sharingText(_ p1: String, _ p2: String) -> String {
        Localizable.tr("Waves", "staking.sharingText", p1, p2)
      }

      internal enum Landing {
        /// Annual Interest by doing NOTHING.
        internal static var annualInterest: String { Localizable.tr("Waves", "staking.landing.annualInterest") }
        internal static var annualInterestKey: String { "staking.landing.annualInterest" }
        /// Earn %@
        internal static func earn(_ p1: String) -> String {
          Localizable.tr("Waves", "staking.landing.earn", p1)
        }
        /// How it works?
        internal static var howItWorks: String { Localizable.tr("Waves", "staking.landing.howItWorks") }
        internal static var howItWorksKey: String { "staking.landing.howItWorks" }
        /// Next
        internal static var next: String { Localizable.tr("Waves", "staking.landing.next") }
        internal static var nextKey: String { "staking.landing.next" }
        /// the profit you earn when you start staking %@
        internal static func profitWhenStaking(_ p1: String) -> String {
          Localizable.tr("Waves", "staking.landing.profitWhenStaking", p1)
        }
        /// Start Staking
        internal static var startStaking: String { Localizable.tr("Waves", "staking.landing.startStaking") }
        internal static var startStakingKey: String { "staking.landing.startStaking" }

        internal enum Faq {

          internal enum Part {
            /// Still have questions? Please visit %@
            internal static func one(_ p1: String) -> String {
              Localizable.tr("Waves", "staking.landing.faq.part.one", p1)
            }
            /// FAQ
            internal static var two: String { Localizable.tr("Waves", "staking.landing.faq.part.two") }
            internal static var twoKey: String { "staking.landing.faq.part.two" }
          }
        }

        internal enum Slide {

          internal enum Buyusdn {
            /// with fiat or crypto
            internal static var subtitle: String { Localizable.tr("Waves", "staking.landing.slide.buyusdn.subtitle") }
            internal static var subtitleKey: String { "staking.landing.slide.buyusdn.subtitle" }
            /// Buy USD-N
            internal static var title: String { Localizable.tr("Waves", "staking.landing.slide.buyusdn.title") }
            internal static var titleKey: String { "staking.landing.slide.buyusdn.title" }
          }

          internal enum Depositusdn {
            /// to smart contract
            internal static var subtitle: String { Localizable.tr("Waves", "staking.landing.slide.depositusdn.subtitle") }
            internal static var subtitleKey: String { "staking.landing.slide.depositusdn.subtitle" }
            /// Deposit USD-N
            internal static var title: String { Localizable.tr("Waves", "staking.landing.slide.depositusdn.title") }
            internal static var titleKey: String { "staking.landing.slide.depositusdn.title" }
          }

          internal enum Passiveincome {
            /// every day
            internal static var subtitle: String { Localizable.tr("Waves", "staking.landing.slide.passiveincome.subtitle") }
            internal static var subtitleKey: String { "staking.landing.slide.passiveincome.subtitle" }
            /// Enjoy your passive income
            internal static var title: String { Localizable.tr("Waves", "staking.landing.slide.passiveincome.title") }
            internal static var titleKey: String { "staking.landing.slide.passiveincome.title" }
          }
        }
      }

      internal enum Transfer {

        internal enum Card {
          /// Buy with Card
          internal static var title: String { Localizable.tr("Waves", "staking.transfer.card.title") }
          internal static var titleKey: String { "staking.transfer.card.title" }

          internal enum Cell {

            internal enum Description {

              internal enum Title {
                /// • The fee is 0. For 100 USD, you'll get exaсtly 100 USDN.
                internal static var part1: String { Localizable.tr("Waves", "staking.transfer.card.cell.description.title.part1") }
                internal static var part1Key: String { "staking.transfer.card.cell.description.title.part1" }
                /// • After a successful payment on the partners' website, USDN will be credited to your account within a few minutes.
                internal static var part2: String { Localizable.tr("Waves", "staking.transfer.card.cell.description.title.part2") }
                internal static var part2Key: String { "staking.transfer.card.cell.description.title.part2" }
                /// • The minimum amount is %@. The maximum amount is %@.
                internal static func part3(_ p1: String, _ p2: String) -> String {
                  Localizable.tr("Waves", "staking.transfer.card.cell.description.title.part3", p1, p2)
                }
                /// • If you have problems with your payment, please create a ticket on the %@ website.
                internal static func part4(_ p1: String) -> String {
                  Localizable.tr("Waves", "staking.transfer.card.cell.description.title.part4", p1)
                }

                internal enum Part4 {
                  /// support
                  internal static var url: String { Localizable.tr("Waves", "staking.transfer.card.cell.description.title.part4.url") }
                  internal static var urlKey: String { "staking.transfer.card.cell.description.title.part4.url" }
                }
              }
            }

            internal enum Input {
              /// Amount
              internal static var title: String { Localizable.tr("Waves", "staking.transfer.card.cell.input.title") }
              internal static var titleKey: String { "staking.transfer.card.cell.input.title" }
            }
          }
        }

        internal enum Cell {

          internal enum Transactionfee {
            /// Transaction Fee:
            internal static var title: String { Localizable.tr("Waves", "staking.transfer.cell.transactionfee.title") }
            internal static var titleKey: String { "staking.transfer.cell.transactionfee.title" }
          }
        }

        internal enum Deposit {
          /// Deposit
          internal static var title: String { Localizable.tr("Waves", "staking.transfer.deposit.title") }
          internal static var titleKey: String { "staking.transfer.deposit.title" }

          internal enum Button {
            /// Deposit
            internal static var title: String { Localizable.tr("Waves", "staking.transfer.deposit.button.title") }
            internal static var titleKey: String { "staking.transfer.deposit.button.title" }
          }

          internal enum Cell {

            internal enum Input {
              /// Deposit to Smart Contract
              internal static var title: String { Localizable.tr("Waves", "staking.transfer.deposit.cell.input.title") }
              internal static var titleKey: String { "staking.transfer.deposit.cell.input.title" }
            }
          }
        }

        internal enum Error {
          /// Max amount is %@.
          internal static func maxamount(_ p1: String) -> String {
            Localizable.tr("Waves", "staking.transfer.error.maxamount", p1)
          }
          /// Min amount is %@.
          internal static func minamount(_ p1: String) -> String {
            Localizable.tr("Waves", "staking.transfer.error.minamount", p1)
          }
        }

        internal enum Withdraw {
          /// Withdraw
          internal static var title: String { Localizable.tr("Waves", "staking.transfer.withdraw.title") }
          internal static var titleKey: String { "staking.transfer.withdraw.title" }

          internal enum Button {
            /// Withdraw
            internal static var title: String { Localizable.tr("Waves", "staking.transfer.withdraw.button.title") }
            internal static var titleKey: String { "staking.transfer.withdraw.button.title" }
          }

          internal enum Cell {

            internal enum Input {
              /// Withdraw from Smart Contract
              internal static var title: String { Localizable.tr("Waves", "staking.transfer.withdraw.cell.input.title") }
              internal static var titleKey: String { "staking.transfer.withdraw.cell.input.title" }
            }
          }
        }
      }
    }

    internal enum Startleasing {

      internal enum Button {
        /// Choose from Address book
        internal static var chooseFromAddressBook: String { Localizable.tr("Waves", "startleasing.button.chooseFromAddressBook") }
        internal static var chooseFromAddressBookKey: String { "startleasing.button.chooseFromAddressBook" }
        /// Start Lease
        internal static var startLease: String { Localizable.tr("Waves", "startleasing.button.startLease") }
        internal static var startLeaseKey: String { "startleasing.button.startLease" }
        /// Use total balance
        internal static var useTotalBalanace: String { Localizable.tr("Waves", "startleasing.button.useTotalBalanace") }
        internal static var useTotalBalanaceKey: String { "startleasing.button.useTotalBalanace" }
        /// Use total balance
        internal static var useTotalBalance: String { Localizable.tr("Waves", "startleasing.button.useTotalBalance") }
        internal static var useTotalBalanceKey: String { "startleasing.button.useTotalBalance" }
      }

      internal enum Label {
        /// Address is not valid
        internal static var addressIsNotValid: String { Localizable.tr("Waves", "startleasing.label.addressIsNotValid") }
        internal static var addressIsNotValidKey: String { "startleasing.label.addressIsNotValid" }
        /// Amount
        internal static var amount: String { Localizable.tr("Waves", "startleasing.label.amount") }
        internal static var amountKey: String { "startleasing.label.amount" }
        /// Balance
        internal static var balance: String { Localizable.tr("Waves", "startleasing.label.balance") }
        internal static var balanceKey: String { "startleasing.label.balance" }
        /// Generator
        internal static var generator: String { Localizable.tr("Waves", "startleasing.label.generator") }
        internal static var generatorKey: String { "startleasing.label.generator" }
        /// Insufficient funds
        internal static var insufficientFunds: String { Localizable.tr("Waves", "startleasing.label.insufficientFunds") }
        internal static var insufficientFundsKey: String { "startleasing.label.insufficientFunds" }
        /// Node address…
        internal static var nodeAddress: String { Localizable.tr("Waves", "startleasing.label.nodeAddress") }
        internal static var nodeAddressKey: String { "startleasing.label.nodeAddress" }
        /// Not enough
        internal static var notEnough: String { Localizable.tr("Waves", "startleasing.label.notEnough") }
        internal static var notEnoughKey: String { "startleasing.label.notEnough" }
        /// Start leasing
        internal static var startLeasing: String { Localizable.tr("Waves", "startleasing.label.startLeasing") }
        internal static var startLeasingKey: String { "startleasing.label.startLeasing" }
      }
    }

    internal enum Startleasingcomplete {

      internal enum Button {
        /// Okay
        internal static var okey: String { Localizable.tr("Waves", "startleasingcomplete.button.okey") }
        internal static var okeyKey: String { "startleasingcomplete.button.okey" }
      }

      internal enum Label {
        /// You have canceled a leasing transaction
        internal static var youHaveCanceledTransaction: String { Localizable.tr("Waves", "startleasingcomplete.label.youHaveCanceledTransaction") }
        internal static var youHaveCanceledTransactionKey: String { "startleasingcomplete.label.youHaveCanceledTransaction" }
        /// You have leased %@ %@
        internal static func youHaveLeased(_ p1: String, _ p2: String) -> String {
          Localizable.tr("Waves", "startleasingcomplete.label.youHaveLeased", p1, p2)
        }
        /// Your transaction is on the way!
        internal static var yourTransactionIsOnWay: String { Localizable.tr("Waves", "startleasingcomplete.label.yourTransactionIsOnWay") }
        internal static var yourTransactionIsOnWayKey: String { "startleasingcomplete.label.yourTransactionIsOnWay" }
      }
    }

    internal enum Startleasingconfirmation {

      internal enum Button {
        /// Cancel leasing
        internal static var cancelLeasing: String { Localizable.tr("Waves", "startleasingconfirmation.button.cancelLeasing") }
        internal static var cancelLeasingKey: String { "startleasingconfirmation.button.cancelLeasing" }
        /// Confirm
        internal static var confirm: String { Localizable.tr("Waves", "startleasingconfirmation.button.confirm") }
        internal static var confirmKey: String { "startleasingconfirmation.button.confirm" }
      }

      internal enum Label {
        /// Confirmation
        internal static var confirmation: String { Localizable.tr("Waves", "startleasingconfirmation.label.confirmation") }
        internal static var confirmationKey: String { "startleasingconfirmation.label.confirmation" }
        /// Fee
        internal static var fee: String { Localizable.tr("Waves", "startleasingconfirmation.label.fee") }
        internal static var feeKey: String { "startleasingconfirmation.label.fee" }
        /// Leasing TX
        internal static var leasingTX: String { Localizable.tr("Waves", "startleasingconfirmation.label.leasingTX") }
        internal static var leasingTXKey: String { "startleasingconfirmation.label.leasingTX" }
        /// Node address
        internal static var nodeAddress: String { Localizable.tr("Waves", "startleasingconfirmation.label.nodeAddress") }
        internal static var nodeAddressKey: String { "startleasingconfirmation.label.nodeAddress" }
        /// TXID
        internal static var txid: String { Localizable.tr("Waves", "startleasingconfirmation.label.TXID") }
        internal static var txidKey: String { "startleasingconfirmation.label.TXID" }
      }
    }

    internal enum Startleasingloading {

      internal enum Label {
        /// Cancel leasing…
        internal static var cancelLeasing: String { Localizable.tr("Waves", "startleasingloading.label.cancelLeasing") }
        internal static var cancelLeasingKey: String { "startleasingloading.label.cancelLeasing" }
        /// Start leasing…
        internal static var startLeasing: String { Localizable.tr("Waves", "startleasingloading.label.startLeasing") }
        internal static var startLeasingKey: String { "startleasingloading.label.startLeasing" }
      }
    }

    internal enum Tokenburn {

      internal enum Button {
        /// Burn
        internal static var burn: String { Localizable.tr("Waves", "tokenBurn.button.burn") }
        internal static var burnKey: String { "tokenBurn.button.burn" }
        /// Continue
        internal static var `continue`: String { Localizable.tr("Waves", "tokenBurn.button.continue") }
        internal static var continueKey: String { "tokenBurn.button.continue" }
        /// Okay
        internal static var okey: String { Localizable.tr("Waves", "tokenBurn.button.okey") }
        internal static var okeyKey: String { "tokenBurn.button.okey" }
        /// Use total balance
        internal static var useTotalBalanace: String { Localizable.tr("Waves", "tokenBurn.button.useTotalBalanace") }
        internal static var useTotalBalanaceKey: String { "tokenBurn.button.useTotalBalanace" }
      }

      internal enum Label {
        /// Confirmation
        internal static var confirmation: String { Localizable.tr("Waves", "tokenBurn.label.confirmation") }
        internal static var confirmationKey: String { "tokenBurn.label.confirmation" }
        /// Fee
        internal static var fee: String { Localizable.tr("Waves", "tokenBurn.label.fee") }
        internal static var feeKey: String { "tokenBurn.label.fee" }
        /// ID
        internal static var id: String { Localizable.tr("Waves", "tokenBurn.label.id") }
        internal static var idKey: String { "tokenBurn.label.id" }
        /// Burn…
        internal static var loading: String { Localizable.tr("Waves", "tokenBurn.label.loading") }
        internal static var loadingKey: String { "tokenBurn.label.loading" }
        /// Not reissuable
        internal static var notReissuable: String { Localizable.tr("Waves", "tokenBurn.label.notReissuable") }
        internal static var notReissuableKey: String { "tokenBurn.label.notReissuable" }
        /// Quantity of tokens to be burned
        internal static var quantityTokensBurned: String { Localizable.tr("Waves", "tokenBurn.label.quantityTokensBurned") }
        internal static var quantityTokensBurnedKey: String { "tokenBurn.label.quantityTokensBurned" }
        /// Reissuable
        internal static var reissuable: String { Localizable.tr("Waves", "tokenBurn.label.reissuable") }
        internal static var reissuableKey: String { "tokenBurn.label.reissuable" }
        /// Token Burn
        internal static var tokenBurn: String { Localizable.tr("Waves", "tokenBurn.label.tokenBurn") }
        internal static var tokenBurnKey: String { "tokenBurn.label.tokenBurn" }
        /// Your transaction is on the way!
        internal static var transactionIsOnWay: String { Localizable.tr("Waves", "tokenBurn.label.transactionIsOnWay") }
        internal static var transactionIsOnWayKey: String { "tokenBurn.label.transactionIsOnWay" }
        /// Type
        internal static var type: String { Localizable.tr("Waves", "tokenBurn.label.type") }
        internal static var typeKey: String { "tokenBurn.label.type" }
        /// You have burned
        internal static var youHaveBurned: String { Localizable.tr("Waves", "tokenBurn.label.youHaveBurned") }
        internal static var youHaveBurnedKey: String { "tokenBurn.label.youHaveBurned" }

        internal enum Error {
          /// Insufficient funds
          internal static var insufficientFunds: String { Localizable.tr("Waves", "tokenBurn.label.error.insufficientFunds") }
          internal static var insufficientFundsKey: String { "tokenBurn.label.error.insufficientFunds" }
          /// You don't have enough funds to pay the required fees.
          internal static var notFundsFee: String { Localizable.tr("Waves", "tokenBurn.label.error.notFundsFee") }
          internal static var notFundsFeeKey: String { "tokenBurn.label.error.notFundsFee" }
        }
      }
    }

    internal enum Trade {
      /// Trade
      internal static var title: String { Localizable.tr("Waves", "trade.title") }
      internal static var titleKey: String { "trade.title" }
    }

    internal enum Transaction {

      internal enum Error {

        internal enum Commission {
          /// Commission receiving error
          internal static var receiving: String { Localizable.tr("Waves", "transaction.error.commission.receiving") }
          internal static var receivingKey: String { "transaction.error.commission.receiving" }
        }
      }
    }

    internal enum Transactioncard {

      internal enum Timestamp {
        /// dd.MM.yyyy HH:mm
        internal static var format: String { Localizable.tr("Waves", "transactioncard.timestamp.format") }
        internal static var formatKey: String { "transactioncard.timestamp.format" }
      }

      internal enum Title {
        /// Active Now
        internal static var activeNow: String { Localizable.tr("Waves", "transactioncard.title.activeNow") }
        internal static var activeNowKey: String { "transactioncard.title.activeNow" }
        /// Amount
        internal static var amount: String { Localizable.tr("Waves", "transactioncard.title.amount") }
        internal static var amountKey: String { "transactioncard.title.amount" }
        /// Amount per transaction
        internal static var amountPerTransaction: String { Localizable.tr("Waves", "transactioncard.title.amountPerTransaction") }
        internal static var amountPerTransactionKey: String { "transactioncard.title.amountPerTransaction" }
        /// Token
        internal static var asset: String { Localizable.tr("Waves", "transactioncard.title.asset") }
        internal static var assetKey: String { "transactioncard.title.asset" }
        /// Token ID
        internal static var assetId: String { Localizable.tr("Waves", "transactioncard.title.assetId") }
        internal static var assetIdKey: String { "transactioncard.title.assetId" }
        /// Block
        internal static var block: String { Localizable.tr("Waves", "transactioncard.title.block") }
        internal static var blockKey: String { "transactioncard.title.block" }
        /// Canceled Leasing
        internal static var canceledLeasing: String { Localizable.tr("Waves", "transactioncard.title.canceledLeasing") }
        internal static var canceledLeasingKey: String { "transactioncard.title.canceledLeasing" }
        /// Cancel Leasing
        internal static var cancelLeasing: String { Localizable.tr("Waves", "transactioncard.title.cancelLeasing") }
        internal static var cancelLeasingKey: String { "transactioncard.title.cancelLeasing" }
        /// (Cancelled)
        internal static var cancelled: String { Localizable.tr("Waves", "transactioncard.title.cancelled") }
        internal static var cancelledKey: String { "transactioncard.title.cancelled" }
        /// Cancel order
        internal static var cancelOrder: String { Localizable.tr("Waves", "transactioncard.title.cancelOrder") }
        internal static var cancelOrderKey: String { "transactioncard.title.cancelOrder" }
        /// Cancel Script
        internal static var cancelScriptTransaction: String { Localizable.tr("Waves", "transactioncard.title.cancelScriptTransaction") }
        internal static var cancelScriptTransactionKey: String { "transactioncard.title.cancelScriptTransaction" }
        /// COMPLETED
        internal static var completed: String { Localizable.tr("Waves", "transactioncard.title.completed") }
        internal static var completedKey: String { "transactioncard.title.completed" }
        /// Confirmations
        internal static var confirmations: String { Localizable.tr("Waves", "transactioncard.title.confirmations") }
        internal static var confirmationsKey: String { "transactioncard.title.confirmations" }
        /// Copied
        internal static var copied: String { Localizable.tr("Waves", "transactioncard.title.copied") }
        internal static var copiedKey: String { "transactioncard.title.copied" }
        /// Copy all data
        internal static var copyAllData: String { Localizable.tr("Waves", "transactioncard.title.copyAllData") }
        internal static var copyAllDataKey: String { "transactioncard.title.copyAllData" }
        /// Copy TX ID
        internal static var copyTXID: String { Localizable.tr("Waves", "transactioncard.title.copyTXID") }
        internal static var copyTXIDKey: String { "transactioncard.title.copyTXID" }
        /// Create Alias
        internal static var createAlias: String { Localizable.tr("Waves", "transactioncard.title.createAlias") }
        internal static var createAliasKey: String { "transactioncard.title.createAlias" }
        /// Data Transaction
        internal static var dataTransaction: String { Localizable.tr("Waves", "transactioncard.title.dataTransaction") }
        internal static var dataTransactionKey: String { "transactioncard.title.dataTransaction" }
        /// Description
        internal static var description: String { Localizable.tr("Waves", "transactioncard.title.description") }
        internal static var descriptionKey: String { "transactioncard.title.description" }
        /// Disable Sponsorship
        internal static var disableSponsorship: String { Localizable.tr("Waves", "transactioncard.title.disableSponsorship") }
        internal static var disableSponsorshipKey: String { "transactioncard.title.disableSponsorship" }
        /// Entry in blockchain
        internal static var entryInBlockchain: String { Localizable.tr("Waves", "transactioncard.title.entryInBlockchain") }
        internal static var entryInBlockchainKey: String { "transactioncard.title.entryInBlockchain" }
        /// Fee
        internal static var fee: String { Localizable.tr("Waves", "transactioncard.title.fee") }
        internal static var feeKey: String { "transactioncard.title.fee" }
        /// Filled
        internal static var filled: String { Localizable.tr("Waves", "transactioncard.title.filled") }
        internal static var filledKey: String { "transactioncard.title.filled" }
        /// From
        internal static var from: String { Localizable.tr("Waves", "transactioncard.title.from") }
        internal static var fromKey: String { "transactioncard.title.from" }
        /// Incoming Leasing
        internal static var incomingLeasing: String { Localizable.tr("Waves", "transactioncard.title.incomingLeasing") }
        internal static var incomingLeasingKey: String { "transactioncard.title.incomingLeasing" }
        /// Leasing from
        internal static var leasingFrom: String { Localizable.tr("Waves", "transactioncard.title.leasingFrom") }
        internal static var leasingFromKey: String { "transactioncard.title.leasingFrom" }
        /// Mass Received
        internal static var massReceived: String { Localizable.tr("Waves", "transactioncard.title.massReceived") }
        internal static var massReceivedKey: String { "transactioncard.title.massReceived" }
        /// Mass Sent
        internal static var massSent: String { Localizable.tr("Waves", "transactioncard.title.massSent") }
        internal static var massSentKey: String { "transactioncard.title.massSent" }
        /// Node address
        internal static var nodeAddress: String { Localizable.tr("Waves", "transactioncard.title.nodeAddress") }
        internal static var nodeAddressKey: String { "transactioncard.title.nodeAddress" }
        /// Not Reissuable
        internal static var notReissuable: String { Localizable.tr("Waves", "transactioncard.title.notReissuable") }
        internal static var notReissuableKey: String { "transactioncard.title.notReissuable" }
        /// Payment
        internal static var payment: String { Localizable.tr("Waves", "transactioncard.title.payment") }
        internal static var paymentKey: String { "transactioncard.title.payment" }
        /// Price
        internal static var price: String { Localizable.tr("Waves", "transactioncard.title.price") }
        internal static var priceKey: String { "transactioncard.title.price" }
        /// Received
        internal static var received: String { Localizable.tr("Waves", "transactioncard.title.received") }
        internal static var receivedKey: String { "transactioncard.title.received" }
        /// Received from
        internal static var receivedFrom: String { Localizable.tr("Waves", "transactioncard.title.receivedFrom") }
        internal static var receivedFromKey: String { "transactioncard.title.receivedFrom" }
        /// Received Sponsorship
        internal static var receivedSponsorship: String { Localizable.tr("Waves", "transactioncard.title.receivedSponsorship") }
        internal static var receivedSponsorshipKey: String { "transactioncard.title.receivedSponsorship" }
        /// #%@ Recipient
        internal static func recipient(_ p1: String) -> String {
          Localizable.tr("Waves", "transactioncard.title.recipient", p1)
        }
        /// Reissuable
        internal static var reissuable: String { Localizable.tr("Waves", "transactioncard.title.reissuable") }
        internal static var reissuableKey: String { "transactioncard.title.reissuable" }
        /// Script address
        internal static var scriptAddress: String { Localizable.tr("Waves", "transactioncard.title.scriptAddress") }
        internal static var scriptAddressKey: String { "transactioncard.title.scriptAddress" }
        /// Script Invocation
        internal static var scriptInvocation: String { Localizable.tr("Waves", "transactioncard.title.scriptInvocation") }
        internal static var scriptInvocationKey: String { "transactioncard.title.scriptInvocation" }
        /// Self-transfer
        internal static var selfTransfer: String { Localizable.tr("Waves", "transactioncard.title.selfTransfer") }
        internal static var selfTransferKey: String { "transactioncard.title.selfTransfer" }
        /// Send again
        internal static var sendAgain: String { Localizable.tr("Waves", "transactioncard.title.sendAgain") }
        internal static var sendAgainKey: String { "transactioncard.title.sendAgain" }
        /// Sent
        internal static var sent: String { Localizable.tr("Waves", "transactioncard.title.sent") }
        internal static var sentKey: String { "transactioncard.title.sent" }
        /// Sent to
        internal static var sentTo: String { Localizable.tr("Waves", "transactioncard.title.sentTo") }
        internal static var sentToKey: String { "transactioncard.title.sentTo" }
        /// Update Script
        internal static var setAssetScript: String { Localizable.tr("Waves", "transactioncard.title.setAssetScript") }
        internal static var setAssetScriptKey: String { "transactioncard.title.setAssetScript" }
        /// Set Script
        internal static var setScriptTransaction: String { Localizable.tr("Waves", "transactioncard.title.setScriptTransaction") }
        internal static var setScriptTransactionKey: String { "transactioncard.title.setScriptTransaction" }
        /// Set Sponsorship
        internal static var setSponsorship: String { Localizable.tr("Waves", "transactioncard.title.setSponsorship") }
        internal static var setSponsorshipKey: String { "transactioncard.title.setSponsorship" }
        /// Show all (%@)
        internal static func showAll(_ p1: String) -> String {
          Localizable.tr("Waves", "transactioncard.title.showAll", p1)
        }
        /// Suspicious received
        internal static var spamReceived: String { Localizable.tr("Waves", "transactioncard.title.spamReceived") }
        internal static var spamReceivedKey: String { "transactioncard.title.spamReceived" }
        /// Started Leasing
        internal static var startedLeasing: String { Localizable.tr("Waves", "transactioncard.title.startedLeasing") }
        internal static var startedLeasingKey: String { "transactioncard.title.startedLeasing" }
        /// Status
        internal static var status: String { Localizable.tr("Waves", "transactioncard.title.status") }
        internal static var statusKey: String { "transactioncard.title.status" }
        /// Timestamp
        internal static var timestamp: String { Localizable.tr("Waves", "transactioncard.title.timestamp") }
        internal static var timestampKey: String { "transactioncard.title.timestamp" }
        /// Token Burn
        internal static var tokenBurn: String { Localizable.tr("Waves", "transactioncard.title.tokenBurn") }
        internal static var tokenBurnKey: String { "transactioncard.title.tokenBurn" }
        /// Token Generation
        internal static var tokenGeneration: String { Localizable.tr("Waves", "transactioncard.title.tokenGeneration") }
        internal static var tokenGenerationKey: String { "transactioncard.title.tokenGeneration" }
        /// Token Reissue
        internal static var tokenReissue: String { Localizable.tr("Waves", "transactioncard.title.tokenReissue") }
        internal static var tokenReissueKey: String { "transactioncard.title.tokenReissue" }
        /// Total
        internal static var total: String { Localizable.tr("Waves", "transactioncard.title.total") }
        internal static var totalKey: String { "transactioncard.title.total" }
        /// Unconfirmed
        internal static var unconfirmed: String { Localizable.tr("Waves", "transactioncard.title.unconfirmed") }
        internal static var unconfirmedKey: String { "transactioncard.title.unconfirmed" }
        /// Unrecognised Transaction
        internal static var unrecognisedTransaction: String { Localizable.tr("Waves", "transactioncard.title.unrecognisedTransaction") }
        internal static var unrecognisedTransactionKey: String { "transactioncard.title.unrecognisedTransaction" }
        /// View on Explorer
        internal static var viewOnExplorer: String { Localizable.tr("Waves", "transactioncard.title.viewOnExplorer") }
        internal static var viewOnExplorerKey: String { "transactioncard.title.viewOnExplorer" }

        internal enum Exchange {
          /// Buy
          internal static var buy: String { Localizable.tr("Waves", "transactioncard.title.exchange.buy") }
          internal static var buyKey: String { "transactioncard.title.exchange.buy" }
          /// Buy: %@/%@
          internal static func buyPair(_ p1: String, _ p2: String) -> String {
            Localizable.tr("Waves", "transactioncard.title.exchange.buyPair", p1, p2)
          }
          /// Sell
          internal static var sell: String { Localizable.tr("Waves", "transactioncard.title.exchange.sell") }
          internal static var sellKey: String { "transactioncard.title.exchange.sell" }
          /// Sell: %@/%@
          internal static func sellPair(_ p1: String, _ p2: String) -> String {
            Localizable.tr("Waves", "transactioncard.title.exchange.sellPair", p1, p2)
          }
        }
      }
    }

    internal enum Transactioncompleted {
      /// Your transaction is on the way!
      internal static var title: String { Localizable.tr("Waves", "transactioncompleted.title") }
      internal static var titleKey: String { "transactioncompleted.title" }

      internal enum Button {

        internal enum Success {
          /// Ok
          internal static var title: String { Localizable.tr("Waves", "transactioncompleted.button.success.title") }
          internal static var titleKey: String { "transactioncompleted.button.success.title" }
        }

        internal enum Viewdetails {
          /// View Details
          internal static var title: String { Localizable.tr("Waves", "transactioncompleted.button.viewdetails.title") }
          internal static var titleKey: String { "transactioncompleted.button.viewdetails.title" }
        }
      }

      internal enum Card {
        /// Note that you have to go through all the necessary procedures on the %@ website.\nOnce you are done, USDN will be credited to your account within a few minutes.
        internal static func subtitle(_ p1: String) -> String {
          Localizable.tr("Waves", "transactioncompleted.card.subtitle", p1)
        }
        /// Purchase completed!
        internal static var title: String { Localizable.tr("Waves", "transactioncompleted.card.title") }
        internal static var titleKey: String { "transactioncompleted.card.title" }

        internal enum Subtitle {
          /// Advanced Cash
          internal static var url: String { Localizable.tr("Waves", "transactioncompleted.card.subtitle.url") }
          internal static var urlKey: String { "transactioncompleted.card.subtitle.url" }
        }
      }

      internal enum Deposit {
        /// You have deposited %@
        internal static func subtitle(_ p1: String) -> String {
          Localizable.tr("Waves", "transactioncompleted.deposit.subtitle", p1)
        }
      }

      internal enum Withdraw {
        /// You have withdrawn %@
        internal static func subtitle(_ p1: String) -> String {
          Localizable.tr("Waves", "transactioncompleted.withdraw.subtitle", p1)
        }
      }
    }

    internal enum Transactionfee {

      internal enum Label {
        /// Transaction Fee
        internal static var transactionFee: String { Localizable.tr("Waves", "transactionFee.label.transactionFee") }
        internal static var transactionFeeKey: String { "transactionFee.label.transactionFee" }
      }
    }

    internal enum Transactionhistory {

      internal enum Cell {
        /// Block
        internal static var block: String { Localizable.tr("Waves", "transactionhistory.cell.block") }
        internal static var blockKey: String { "transactionhistory.cell.block" }
        /// Data Transaction
        internal static var dataTransaction: String { Localizable.tr("Waves", "transactionhistory.cell.dataTransaction") }
        internal static var dataTransactionKey: String { "transactionhistory.cell.dataTransaction" }
        /// Fee
        internal static var fee: String { Localizable.tr("Waves", "transactionhistory.cell.fee") }
        internal static var feeKey: String { "transactionhistory.cell.fee" }
        /// ID
        internal static var id: String { Localizable.tr("Waves", "transactionhistory.cell.id") }
        internal static var idKey: String { "transactionhistory.cell.id" }
        /// Leasing to
        internal static var leasingTo: String { Localizable.tr("Waves", "transactionhistory.cell.leasingTo") }
        internal static var leasingToKey: String { "transactionhistory.cell.leasingTo" }
        /// Price
        internal static var price: String { Localizable.tr("Waves", "transactionhistory.cell.price") }
        internal static var priceKey: String { "transactionhistory.cell.price" }
        /// Recipient
        internal static var recipient: String { Localizable.tr("Waves", "transactionhistory.cell.recipient") }
        internal static var recipientKey: String { "transactionhistory.cell.recipient" }
        /// Recipients
        internal static var recipients: String { Localizable.tr("Waves", "transactionhistory.cell.recipients") }
        internal static var recipientsKey: String { "transactionhistory.cell.recipients" }
        /// Type
        internal static var type: String { Localizable.tr("Waves", "transactionhistory.cell.type") }
        internal static var typeKey: String { "transactionhistory.cell.type" }

        internal enum Status {
          /// at
          internal static var at: String { Localizable.tr("Waves", "transactionhistory.cell.status.at") }
          internal static var atKey: String { "transactionhistory.cell.status.at" }
        }
      }

      internal enum Copy {
        /// Date
        internal static var date: String { Localizable.tr("Waves", "transactionhistory.copy.date") }
        internal static var dateKey: String { "transactionhistory.copy.date" }
        /// Recipient
        internal static var recipient: String { Localizable.tr("Waves", "transactionhistory.copy.recipient") }
        internal static var recipientKey: String { "transactionhistory.copy.recipient" }
        /// Sender
        internal static var sender: String { Localizable.tr("Waves", "transactionhistory.copy.sender") }
        internal static var senderKey: String { "transactionhistory.copy.sender" }
        /// Transaction ID
        internal static var transactionId: String { Localizable.tr("Waves", "transactionhistory.copy.transactionId") }
        internal static var transactionIdKey: String { "transactionhistory.copy.transactionId" }
        /// Type
        internal static var type: String { Localizable.tr("Waves", "transactionhistory.copy.type") }
        internal static var typeKey: String { "transactionhistory.copy.type" }
      }
    }

    internal enum Transactionscript {

      internal enum Button {
        /// Okay
        internal static var okey: String { Localizable.tr("Waves", "transactionScript.button.okey") }
        internal static var okeyKey: String { "transactionScript.button.okey" }
      }

      internal enum Label {
        /// To work with a scripted account/token, use the Waves Client
        internal static var subtitle: String { Localizable.tr("Waves", "transactionScript.label.subtitle") }
        internal static var subtitleKey: String { "transactionScript.label.subtitle" }
        /// A script is installed on your account or token
        internal static var title: String { Localizable.tr("Waves", "transactionScript.label.title") }
        internal static var titleKey: String { "transactionScript.label.title" }
      }
    }

    internal enum Usetouchid {

      internal enum Button {

        internal enum Notnow {
          /// Not now
          internal static var text: String { Localizable.tr("Waves", "usetouchid.button.notNow.text") }
          internal static var textKey: String { "usetouchid.button.notNow.text" }
        }

        internal enum Usebiometric {
          /// Use %@
          internal static func text(_ p1: String) -> String {
            Localizable.tr("Waves", "usetouchid.button.useBiometric.text", p1)
          }
        }
      }

      internal enum Label {

        internal enum Detail {
          /// Use your %@ for faster, easier access to your account
          internal static func text(_ p1: String) -> String {
            Localizable.tr("Waves", "usetouchid.label.detail.text", p1)
          }
        }

        internal enum Title {
          /// Use %@ to sign in?
          internal static func text(_ p1: String) -> String {
            Localizable.tr("Waves", "usetouchid.label.title.text", p1)
          }
        }
      }
    }

    internal enum Wallet {
      /// I earned %@ USDN passive income, with an average annual yield of %@, lying on the couch!
      internal static func sharedTitle(_ p1: String, _ p2: String) -> String {
        Localizable.tr("Waves", "wallet.sharedTitle", p1, p2)
      }

      internal enum Button {
        /// Start Lease
        internal static var startLease: String { Localizable.tr("Waves", "wallet.button.startLease") }
        internal static var startLeaseKey: String { "wallet.button.startLease" }
      }

      internal enum Clearassets {

        internal enum Label {
          /// We have redesigned the display of assets to allow you to keep your wallet clean and tidy. You can customise your asset list however you want!
          internal static var subtitle: String { Localizable.tr("Waves", "wallet.clearAssets.label.subtitle") }
          internal static var subtitleKey: String { "wallet.clearAssets.label.subtitle" }
          /// No more mess!
          internal static var title: String { Localizable.tr("Waves", "wallet.clearAssets.label.title") }
          internal static var titleKey: String { "wallet.clearAssets.label.title" }
        }
      }

      internal enum Label {
        /// Available
        internal static var available: String { Localizable.tr("Waves", "wallet.label.available") }
        internal static var availableKey: String { "wallet.label.available" }
        /// Leased
        internal static var leased: String { Localizable.tr("Waves", "wallet.label.leased") }
        internal static var leasedKey: String { "wallet.label.leased" }
        /// Leased in
        internal static var leasedIn: String { Localizable.tr("Waves", "wallet.label.leasedIn") }
        internal static var leasedInKey: String { "wallet.label.leasedIn" }
        /// My token
        internal static var myAssets: String { Localizable.tr("Waves", "wallet.label.myAssets") }
        internal static var myAssetsKey: String { "wallet.label.myAssets" }
        /// Search
        internal static var search: String { Localizable.tr("Waves", "wallet.label.search") }
        internal static var searchKey: String { "wallet.label.search" }
        /// Started Leasing
        internal static var startedLeasing: String { Localizable.tr("Waves", "wallet.label.startedLeasing") }
        internal static var startedLeasingKey: String { "wallet.label.startedLeasing" }
        /// Total balance
        internal static var totalBalance: String { Localizable.tr("Waves", "wallet.label.totalBalance") }
        internal static var totalBalanceKey: String { "wallet.label.totalBalance" }
        /// Transaction history
        internal static var viewHistory: String { Localizable.tr("Waves", "wallet.label.viewHistory") }
        internal static var viewHistoryKey: String { "wallet.label.viewHistory" }

        internal enum Quicknote {

          internal enum Description {
            /// You can only transfer or trade WAVES that aren’t leased. The leased amount cannot be transferred or traded by you or anyone else.
            internal static var first: String { Localizable.tr("Waves", "wallet.label.quickNote.description.first") }
            internal static var firstKey: String { "wallet.label.quickNote.description.first" }
            /// You can cancel a leasing transaction as soon as it appears in the blockchain which usually occurs in a minute or less.
            internal static var second: String { Localizable.tr("Waves", "wallet.label.quickNote.description.second") }
            internal static var secondKey: String { "wallet.label.quickNote.description.second" }
            /// The generating balance will be updated after 1000 blocks.
            internal static var third: String { Localizable.tr("Waves", "wallet.label.quickNote.description.third") }
            internal static var thirdKey: String { "wallet.label.quickNote.description.third" }
          }
        }
      }

      internal enum Navigationbar {
        /// Wallet
        internal static var title: String { Localizable.tr("Waves", "wallet.navigationBar.title") }
        internal static var titleKey: String { "wallet.navigationBar.title" }
      }

      internal enum Section {
        /// Active now (%d)
        internal static func activeNow(_ p1: Int) -> String {
          Localizable.tr("Waves", "wallet.section.activeNow", p1)
        }
        /// Hidden tokens (%d)
        internal static func hiddenAssets(_ p1: Int) -> String {
          Localizable.tr("Waves", "wallet.section.hiddenAssets", p1)
        }
        /// Quick note
        internal static var quickNote: String { Localizable.tr("Waves", "wallet.section.quickNote") }
        internal static var quickNoteKey: String { "wallet.section.quickNote" }
        /// Suspicious tokens (%d)
        internal static func spamAssets(_ p1: Int) -> String {
          Localizable.tr("Waves", "wallet.section.spamAssets", p1)
        }
      }

      internal enum Segmentedcontrol {
        /// Tokens
        internal static var assets: String { Localizable.tr("Waves", "wallet.segmentedControl.assets") }
        internal static var assetsKey: String { "wallet.segmentedControl.assets" }
        /// Leasing
        internal static var leasing: String { Localizable.tr("Waves", "wallet.segmentedControl.leasing") }
        internal static var leasingKey: String { "wallet.segmentedControl.leasing" }
        /// new
        internal static var new: String { Localizable.tr("Waves", "wallet.segmentedControl.new") }
        internal static var newKey: String { "wallet.segmentedControl.new" }
        /// Staking
        internal static var staking: String { Localizable.tr("Waves", "wallet.segmentedControl.staking") }
        internal static var stakingKey: String { "wallet.segmentedControl.staking" }
      }

      internal enum Stakingbalance {

        internal enum Button {
          /// Buy
          internal static var buy: String { Localizable.tr("Waves", "wallet.stakingbalance.button.buy") }
          internal static var buyKey: String { "wallet.stakingbalance.button.buy" }
          /// Deposit
          internal static var deposit: String { Localizable.tr("Waves", "wallet.stakingbalance.button.deposit") }
          internal static var depositKey: String { "wallet.stakingbalance.button.deposit" }
          /// Trade
          internal static var trade: String { Localizable.tr("Waves", "wallet.stakingbalance.button.trade") }
          internal static var tradeKey: String { "wallet.stakingbalance.button.trade" }
          /// Withdraw
          internal static var withdraw: String { Localizable.tr("Waves", "wallet.stakingbalance.button.withdraw") }
          internal static var withdrawKey: String { "wallet.stakingbalance.button.withdraw" }
        }

        internal enum Label {
          /// Available
          internal static var available: String { Localizable.tr("Waves", "wallet.stakingbalance.label.available") }
          internal static var availableKey: String { "wallet.stakingbalance.label.available" }
          /// Staking
          internal static var staking: String { Localizable.tr("Waves", "wallet.stakingbalance.label.staking") }
          internal static var stakingKey: String { "wallet.stakingbalance.label.staking" }
          /// Total balance
          internal static var totalBalance: String { Localizable.tr("Waves", "wallet.stakingbalance.label.totalBalance") }
          internal static var totalBalanceKey: String { "wallet.stakingbalance.label.totalBalance" }
        }
      }

      internal enum Stakingheader {
        /// Estimated Interest
        internal static var estimatedInterest: String { Localizable.tr("Waves", "wallet.stakingheader.estimatedInterest") }
        internal static var estimatedInterestKey: String { "wallet.stakingheader.estimatedInterest" }
        /// How it works?
        internal static var howItWorks: String { Localizable.tr("Waves", "wallet.stakingheader.howItWorks") }
        internal static var howItWorksKey: String { "wallet.stakingheader.howItWorks" }
        /// %% per year
        internal static var perYear: String { Localizable.tr("Waves", "wallet.stakingheader.perYear") }
        internal static var perYearKey: String { "wallet.stakingheader.perYear" }
        /// Share
        internal static var share: String { Localizable.tr("Waves", "wallet.stakingheader.share") }
        internal static var shareKey: String { "wallet.stakingheader.share" }
        /// Total Profit
        internal static var totalProfit: String { Localizable.tr("Waves", "wallet.stakingheader.totalProfit") }
        internal static var totalProfitKey: String { "wallet.stakingheader.totalProfit" }
      }

      internal enum Stakingpayouts {
        /// Last Payouts
        internal static var lastPayouts: String { Localizable.tr("Waves", "wallet.stakingPayouts.lastPayouts") }
        internal static var lastPayoutsKey: String { "wallet.stakingPayouts.lastPayouts" }
        /// Payouts History
        internal static var payoutsHistory: String { Localizable.tr("Waves", "wallet.stakingPayouts.payoutsHistory") }
        internal static var payoutsHistoryKey: String { "wallet.stakingPayouts.payoutsHistory" }
        /// Profit
        internal static var profit: String { Localizable.tr("Waves", "wallet.stakingPayouts.profit") }
        internal static var profitKey: String { "wallet.stakingPayouts.profit" }
        /// You don't have any payouts yet
        internal static var youDontHavePayouts: String { Localizable.tr("Waves", "wallet.stakingPayouts.youDontHavePayouts") }
        internal static var youDontHavePayoutsKey: String { "wallet.stakingPayouts.youDontHavePayouts" }
      }

      internal enum Updateapp {

        internal enum Label {
          /// We are constantly working to make Waves Wallet better and more useful. Please update your app to gain access to new features.
          internal static var subtitle: String { Localizable.tr("Waves", "wallet.updateApp.label.subtitle") }
          internal static var subtitleKey: String { "wallet.updateApp.label.subtitle" }
          /// It's time to update your app!
          internal static var title: String { Localizable.tr("Waves", "wallet.updateApp.label.title") }
          internal static var titleKey: String { "wallet.updateApp.label.title" }
        }
      }
    }

    internal enum Walletsearch {

      internal enum Button {
        /// Cancel
        internal static var cancel: String { Localizable.tr("Waves", "walletsearch.button.cancel") }
        internal static var cancelKey: String { "walletsearch.button.cancel" }
      }

      internal enum Label {
        /// Hidden tokens
        internal static var hiddenTokens: String { Localizable.tr("Waves", "walletsearch.label.hiddenTokens") }
        internal static var hiddenTokensKey: String { "walletsearch.label.hiddenTokens" }
        /// Suspicious tokens
        internal static var suspiciousTokens: String { Localizable.tr("Waves", "walletsearch.label.suspiciousTokens") }
        internal static var suspiciousTokensKey: String { "walletsearch.label.suspiciousTokens" }
      }
    }

    internal enum Walletsort {

      internal enum Button {
        /// Position
        internal static var position: String { Localizable.tr("Waves", "walletsort.button.position") }
        internal static var positionKey: String { "walletsort.button.position" }
        /// Visibility
        internal static var visibility: String { Localizable.tr("Waves", "walletsort.button.visibility") }
        internal static var visibilityKey: String { "walletsort.button.visibility" }
      }

      internal enum Label {
        /// Hidden tokens
        internal static var hiddenAssets: String { Localizable.tr("Waves", "walletsort.label.hiddenAssets") }
        internal static var hiddenAssetsKey: String { "walletsort.label.hiddenAssets" }
        /// The list of tokens is empty
        internal static var listOfAssetsEmpty: String { Localizable.tr("Waves", "walletsort.label.listOfAssetsEmpty") }
        internal static var listOfAssetsEmptyKey: String { "walletsort.label.listOfAssetsEmpty" }
        /// You didn't add tokens in favorite
        internal static var notAddedAssetsInFavorites: String { Localizable.tr("Waves", "walletsort.label.notAddedAssetsInFavorites") }
        internal static var notAddedAssetsInFavoritesKey: String { "walletsort.label.notAddedAssetsInFavorites" }
        /// You didn't add tokens in hidden
        internal static var notAddedAssetsInHidden: String { Localizable.tr("Waves", "walletsort.label.notAddedAssetsInHidden") }
        internal static var notAddedAssetsInHiddenKey: String { "walletsort.label.notAddedAssetsInHidden" }
      }

      internal enum Navigationbar {
        /// Sorting
        internal static var title: String { Localizable.tr("Waves", "walletsort.navigationBar.title") }
        internal static var titleKey: String { "walletsort.navigationBar.title" }
      }
    }

    internal enum Wavespopup {

      internal enum Button {
        /// Exchange
        internal static var exchange: String { Localizable.tr("Waves", "wavespopup.button.exchange") }
        internal static var exchangeKey: String { "wavespopup.button.exchange" }
        /// Receive
        internal static var receive: String { Localizable.tr("Waves", "wavespopup.button.receive") }
        internal static var receiveKey: String { "wavespopup.button.receive" }
        /// Send
        internal static var send: String { Localizable.tr("Waves", "wavespopup.button.send") }
        internal static var sendKey: String { "wavespopup.button.send" }
      }

      internal enum Label {
        /// Coming soon
        internal static var comingsoon: String { Localizable.tr("Waves", "wavespopup.label.comingsoon") }
        internal static var comingsoonKey: String { "wavespopup.label.comingsoon" }
      }
    }

    internal enum Widgetsettings {

      internal enum Actionsheet {

        internal enum Changeinterval {
          /// Update interval
          internal static var title: String { Localizable.tr("Waves", "widgetsettings.actionsheet.changeinterval.title") }
          internal static var titleKey: String { "widgetsettings.actionsheet.changeinterval.title" }

          internal enum Element {
            /// 1 minute
            internal static var m1: String { Localizable.tr("Waves", "widgetsettings.actionsheet.changeinterval.element.m1") }
            internal static var m1Key: String { "widgetsettings.actionsheet.changeinterval.element.m1" }
            /// 10 minute
            internal static var m10: String { Localizable.tr("Waves", "widgetsettings.actionsheet.changeinterval.element.m10") }
            internal static var m10Key: String { "widgetsettings.actionsheet.changeinterval.element.m10" }
            /// 5 minute
            internal static var m5: String { Localizable.tr("Waves", "widgetsettings.actionsheet.changeinterval.element.m5") }
            internal static var m5Key: String { "widgetsettings.actionsheet.changeinterval.element.m5" }
            /// Update manually
            internal static var manually: String { Localizable.tr("Waves", "widgetsettings.actionsheet.changeinterval.element.manually") }
            internal static var manuallyKey: String { "widgetsettings.actionsheet.changeinterval.element.manually" }
          }
        }

        internal enum Changestyle {
          /// Widget style
          internal static var title: String { Localizable.tr("Waves", "widgetsettings.actionsheet.changestyle.title") }
          internal static var titleKey: String { "widgetsettings.actionsheet.changestyle.title" }

          internal enum Element {
            /// Classic
            internal static var classic: String { Localizable.tr("Waves", "widgetsettings.actionsheet.changestyle.element.classic") }
            internal static var classicKey: String { "widgetsettings.actionsheet.changestyle.element.classic" }
            /// Dark
            internal static var dark: String { Localizable.tr("Waves", "widgetsettings.actionsheet.changestyle.element.dark") }
            internal static var darkKey: String { "widgetsettings.actionsheet.changestyle.element.dark" }
          }
        }
      }

      internal enum Button {
        /// Add token
        internal static var addToken: String { Localizable.tr("Waves", "widgetsettings.button.addToken") }
        internal static var addTokenKey: String { "widgetsettings.button.addToken" }
      }

      internal enum Changeinterval {

        internal enum Button {
          /// 1 minute
          internal static var m1: String { Localizable.tr("Waves", "widgetsettings.changeinterval.button.m1") }
          internal static var m1Key: String { "widgetsettings.changeinterval.button.m1" }
          /// 10 minute
          internal static var m10: String { Localizable.tr("Waves", "widgetsettings.changeinterval.button.m10") }
          internal static var m10Key: String { "widgetsettings.changeinterval.button.m10" }
          /// 5 minute
          internal static var m5: String { Localizable.tr("Waves", "widgetsettings.changeinterval.button.m5") }
          internal static var m5Key: String { "widgetsettings.changeinterval.button.m5" }
          /// Update manually
          internal static var manually: String { Localizable.tr("Waves", "widgetsettings.changeinterval.button.manually") }
          internal static var manuallyKey: String { "widgetsettings.changeinterval.button.manually" }
        }
      }

      internal enum Label {
        /// Added
        internal static var added: String { Localizable.tr("Waves", "widgetsettings.label.added") }
        internal static var addedKey: String { "widgetsettings.label.added" }
      }

      internal enum Navigation {
        /// Waves.Exchange Pulse
        internal static var title: String { Localizable.tr("Waves", "widgetsettings.navigation.title") }
        internal static var titleKey: String { "widgetsettings.navigation.title" }
      }

      internal enum Tableview {

        internal enum Editmode {
          /// Delete
          internal static var delete: String { Localizable.tr("Waves", "widgetsettings.tableview.editmode.delete") }
          internal static var deleteKey: String { "widgetsettings.tableview.editmode.delete" }
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension Localizable: LocalizableProtocol {

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
