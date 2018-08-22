// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: Any> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: Any> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal protocol SegueType: RawRepresentable { }

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Asset: StoryboardType {
    internal static let storyboardName = "Asset"

    internal static let assetViewController = SceneType<WavesWallet_iOS.AssetViewController>(storyboard: Asset.self, identifier: "AssetViewController")
  }
  internal enum Dex: StoryboardType {
    internal static let storyboardName = "Dex"

    internal static let assetPairDetailsViewController = SceneType<WavesWallet_iOS.HalfNavController>(storyboard: Dex.self, identifier: "AssetPairDetailsViewController")

    internal static let chartViewController = SceneType<WavesWallet_iOS.ChartViewController>(storyboard: Dex.self, identifier: "ChartViewController")

    internal static let createOrderViewController = SceneType<WavesWallet_iOS.CreateOrderViewController>(storyboard: Dex.self, identifier: "CreateOrderViewController")

    internal static let createOrderViewController1 = SceneType<UIViewController>(storyboard: Dex.self, identifier: "CreateOrderViewController1")

    internal static let dexContainerViewController = SceneType<WavesWallet_iOS.DexContainerViewController>(storyboard: Dex.self, identifier: "DexContainerViewController")

    internal static let dexInfoViewController = SceneType<WavesWallet_iOS.DexInfoViewController>(storyboard: Dex.self, identifier: "DexInfoViewController")

    internal static let dexListViewController = SceneType<WavesWallet_iOS.DexListViewController>(storyboard: Dex.self, identifier: "DexListViewController")

    internal static let dexMarketViewController = SceneType<WavesWallet_iOS.DexMarketViewController>(storyboard: Dex.self, identifier: "DexMarketViewController")

    internal static let dexNewPairViewController = SceneType<WavesWallet_iOS.DexNewPairViewController>(storyboard: Dex.self, identifier: "DexNewPairViewController")

    internal static let dexSearchViewController = SceneType<WavesWallet_iOS.DexSearchViewController>(storyboard: Dex.self, identifier: "DexSearchViewController")

    internal static let dexSortViewController = SceneType<WavesWallet_iOS.DexSortViewController>(storyboard: Dex.self, identifier: "DexSortViewController")

    internal static let dexViewController = SceneType<WavesWallet_iOS.DexViewController>(storyboard: Dex.self, identifier: "DexViewController")

    internal static let lastTradersViewController = SceneType<WavesWallet_iOS.LastTradersViewController>(storyboard: Dex.self, identifier: "LastTradersViewController")

    internal static let myOrdersViewController = SceneType<WavesWallet_iOS.MyOrdersViewController>(storyboard: Dex.self, identifier: "MyOrdersViewController")

    internal static let orderBookViewController = SceneType<WavesWallet_iOS.OrderBookViewController>(storyboard: Dex.self, identifier: "OrderBookViewController")
  }
  internal enum Enter: StoryboardType {
    internal static let storyboardName = "Enter"

    internal static let confirmBackupViewController = SceneType<WavesWallet_iOS.ConfirmBackupViewController>(storyboard: Enter.self, identifier: "ConfirmBackupViewController")

    internal static let editAccountNameViewController = SceneType<WavesWallet_iOS.EditAccountNameViewController>(storyboard: Enter.self, identifier: "EditAccountNameViewController")

    internal static let enterLanguageViewController = SceneType<WavesWallet_iOS.EnterLanguageViewController>(storyboard: Enter.self, identifier: "EnterLanguageViewController")

    internal static let enterSelectAccountViewController = SceneType<WavesWallet_iOS.EnterSelectAccountViewController>(storyboard: Enter.self, identifier: "EnterSelectAccountViewController")

    internal static let enterStartViewController = SceneType<WavesWallet_iOS.EnterStartViewController>(storyboard: Enter.self, identifier: "EnterStartViewController")

    internal static let importAccountPasswordViewController = SceneType<WavesWallet_iOS.ImportAccountPasswordViewController>(storyboard: Enter.self, identifier: "ImportAccountPasswordViewController")

    internal static let importAccountViewController = SceneType<WavesWallet_iOS.ImportAccountViewController>(storyboard: Enter.self, identifier: "ImportAccountViewController")

    internal static let importWelcomeBackViewController = SceneType<WavesWallet_iOS.ImportWelcomeBackViewController>(storyboard: Enter.self, identifier: "ImportWelcomeBackViewController")

    internal static let newAccountBackupInfoViewController = SceneType<WavesWallet_iOS.NewAccountBackupInfoViewController>(storyboard: Enter.self, identifier: "NewAccountBackupInfoViewController")

    internal static let newAccountSecretPhraseViewController = SceneType<WavesWallet_iOS.NewAccountSecretPhraseViewController>(storyboard: Enter.self, identifier: "NewAccountSecretPhraseViewController")

    internal static let newAccountViewController = SceneType<WavesWallet_iOS.NewAccountViewController>(storyboard: Enter.self, identifier: "NewAccountViewController")

    internal static let saveBackupPhraseViewController = SceneType<WavesWallet_iOS.SaveBackupPhraseViewController>(storyboard: Enter.self, identifier: "SaveBackupPhraseViewController")

    internal static let useTouchIDViewController = SceneType<WavesWallet_iOS.UseTouchIDViewController>(storyboard: Enter.self, identifier: "UseTouchIDViewController")
  }
  internal enum Hello: StoryboardType {
    internal static let storyboardName = "Hello"

    internal static let initialScene = InitialSceneType<WavesWallet_iOS.HelloLanguagesViewController>(storyboard: Hello.self)

    internal static let helloLanguagesViewController = SceneType<WavesWallet_iOS.HelloLanguagesViewController>(storyboard: Hello.self, identifier: "HelloLanguagesViewController")

    internal static let infoPagesViewController = SceneType<WavesWallet_iOS.InfoPagesViewController>(storyboard: Hello.self, identifier: "InfoPagesViewController")
  }
  internal enum History: StoryboardType {
    internal static let storyboardName = "History"

    internal static let newHistoryViewController = SceneType<WavesWallet_iOS.HistoryViewController>(storyboard: History.self, identifier: "NewHistoryViewController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Login: StoryboardType {
    internal static let storyboardName = "Login"

    internal static let initialScene = InitialSceneType<WavesWallet_iOS.CustomNavigationController>(storyboard: Login.self)

    internal static let launchViewController = SceneType<WavesWallet_iOS.LaunchViewController>(storyboard: Login.self, identifier: "LaunchViewController")

    internal static let navLaunchViewController = SceneType<WavesWallet_iOS.CustomNavigationController>(storyboard: Login.self, identifier: "NavLaunchViewController")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let assetChartViewController = SceneType<WavesWallet_iOS.AssetChartViewController>(storyboard: Main.self, identifier: "AssetChartViewController")

    internal static let assetViewController = SceneType<WavesWallet_iOS.AssetViewController>(storyboard: Main.self, identifier: "AssetViewController")

    internal static let menuViewController = SceneType<WavesWallet_iOS.MenuViewController>(storyboard: Main.self, identifier: "MenuViewController")

    internal static let myAddressViewController = SceneType<WavesWallet_iOS.MyAddressViewController>(storyboard: Main.self, identifier: "MyAddressViewController")

    internal static let startLeasingViewController = SceneType<WavesWallet_iOS.StartLeasingViewController>(storyboard: Main.self, identifier: "StartLeasingViewController")
  }
  internal enum Profile: StoryboardType {
    internal static let storyboardName = "Profile"

    internal static let accountPasswordViewController = SceneType<WavesWallet_iOS.AccountPasswordViewController>(storyboard: Profile.self, identifier: "AccountPasswordViewController")

    internal static let changePasswordViewController = SceneType<WavesWallet_iOS.ChangePasswordViewController>(storyboard: Profile.self, identifier: "ChangePasswordViewController")

    internal static let createAliasViewController = SceneType<WavesWallet_iOS.CreateAliasViewController>(storyboard: Profile.self, identifier: "CreateAliasViewController")

    internal static let deleteAccountViewController = SceneType<WavesWallet_iOS.DeleteAccountViewController>(storyboard: Profile.self, identifier: "DeleteAccountViewController")

    internal static let languageViewController = SceneType<WavesWallet_iOS.LanguageViewController>(storyboard: Profile.self, identifier: "LanguageViewController")

    internal static let networkViewController = SceneType<WavesWallet_iOS.NetworkViewController>(storyboard: Profile.self, identifier: "NetworkViewController")

    internal static let passcodeViewController = SceneType<WavesWallet_iOS.PasscodeViewController>(storyboard: Profile.self, identifier: "PasscodeViewController")

    internal static let profileAddressKeyViewController = SceneType<WavesWallet_iOS.ProfileAddressKeyViewController>(storyboard: Profile.self, identifier: "ProfileAddressKeyViewController")

    internal static let profileViewController = SceneType<WavesWallet_iOS.ProfileViewController>(storyboard: Profile.self, identifier: "ProfileViewController")
  }
  internal enum Transactions: StoryboardType {
    internal static let storyboardName = "Transactions"

    internal static let addAddressViewController = SceneType<WavesWallet_iOS.AddAddressViewController>(storyboard: Transactions.self, identifier: "AddAddressViewController")

    internal static let transactionHistoryViewController = SceneType<WavesWallet_iOS.TransactionHistoryViewController>(storyboard: Transactions.self, identifier: "TransactionHistoryViewController")
  }
  internal enum Transfer: StoryboardType {
    internal static let storyboardName = "Transfer"

    internal static let initialScene = InitialSceneType<WavesWallet_iOS.CustomNavigationController>(storyboard: Transfer.self)

    internal static let receiveNavViewController = SceneType<WavesWallet_iOS.CustomNavigationController>(storyboard: Transfer.self, identifier: "ReceiveNavViewController")

    internal static let receiveViewController = SceneType<WavesWallet_iOS.ReceiveViewController>(storyboard: Transfer.self, identifier: "ReceiveViewController")

    internal static let selectAccountViewController = SceneType<WavesWallet_iOS.SelectAccountViewController>(storyboard: Transfer.self, identifier: "SelectAccountViewController")

    internal static let sendViewController = SceneType<WavesWallet_iOS.SendViewController>(storyboard: Transfer.self, identifier: "SendViewController")
  }
  internal enum Wallet: StoryboardType {
    internal static let storyboardName = "Wallet"

    internal static let walletSortViewController = SceneType<WavesWallet_iOS.WalletSortViewController>(storyboard: Wallet.self, identifier: "WalletSortViewController")

    internal static let walletViewController = SceneType<WavesWallet_iOS.WalletViewController>(storyboard: Wallet.self, identifier: "WalletViewController")
  }
  internal enum Waves: StoryboardType {
    internal static let storyboardName = "Waves"

    internal static let chooseAddressBookViewController = SceneType<WavesWallet_iOS.ChooseAddressBookViewController>(storyboard: Waves.self, identifier: "ChooseAddressBookViewController")

    internal static let chooseAssetViewController = SceneType<WavesWallet_iOS.ChooseAssetViewController>(storyboard: Waves.self, identifier: "ChooseAssetViewController")

    internal static let wavesPopupViewController = SceneType<WavesWallet_iOS.WavesPopupViewController>(storyboard: Waves.self, identifier: "WavesPopupViewController")

    internal static let wavesReceiveBankViewController = SceneType<WavesWallet_iOS.WavesReceiveBankViewController>(storyboard: Waves.self, identifier: "WavesReceiveBankViewController")

    internal static let wavesReceiveCardViewController = SceneType<WavesWallet_iOS.WavesReceiveCardViewController>(storyboard: Waves.self, identifier: "WavesReceiveCardViewController")

    internal static let wavesReceiveCryptocurrencyViewController = SceneType<WavesWallet_iOS.WavesReceiveCryptocurrencyViewController>(storyboard: Waves.self, identifier: "WavesReceiveCryptocurrencyViewController")

    internal static let wavesReceiveInvoiceViewController = SceneType<WavesWallet_iOS.WavesReceiveInvoiceViewController>(storyboard: Waves.self, identifier: "WavesReceiveInvoiceViewController")

    internal static let wavesReceiveLoadingViewController = SceneType<WavesWallet_iOS.WavesReceiveLoadingViewController>(storyboard: Waves.self, identifier: "WavesReceiveLoadingViewController")

    internal static let wavesReceiveRedirectViewController = SceneType<WavesWallet_iOS.WavesReceiveRedirectViewController>(storyboard: Waves.self, identifier: "WavesReceiveRedirectViewController")

    internal static let wavesReceiveViewController = SceneType<WavesWallet_iOS.WavesReceiveViewController>(storyboard: Waves.self, identifier: "WavesReceiveViewController")

    internal static let wavesSendConfirmationViewController = SceneType<WavesWallet_iOS.WavesSendConfirmationViewController>(storyboard: Waves.self, identifier: "WavesSendConfirmationViewController")

    internal static let wavesSendViewController = SceneType<WavesWallet_iOS.WavesSendViewController>(storyboard: Waves.self, identifier: "WavesSendViewController")
  }
}

internal enum StoryboardSegue {
  internal enum Dex: String, SegueType {
    case dexContainerViewController = "DexContainerViewController"
  }
  internal enum Login: String, SegueType {
    case importWallet = "ImportWallet"
  }
  internal enum Transfer: String, SegueType {
    case chooseAddress = "ChooseAddress"
    case transactionSuccess = "TransactionSuccess"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
