// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
internal typealias ImagesType = ImageAsset

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Images {
  internal enum TabBar {
    internal static let tabBarDex = ImageAsset(name: "tab_bar_dex")
    internal static let tabBarDexActive = ImageAsset(name: "tab_bar_dex_active")
    internal static let tabBarHistory = ImageAsset(name: "tab_bar_history")
    internal static let tabBarHistoryActive = ImageAsset(name: "tab_bar_history_active")
    internal static let tabBarPlus = ImageAsset(name: "tab_bar_plus")
    internal static let tabBarPlusActive = ImageAsset(name: "tab_bar_plus_active")
    internal static let tabBarProfile = ImageAsset(name: "tab_bar_profile")
    internal static let tabBarProfileActive = ImageAsset(name: "tab_bar_profile_active")
    internal static let tabBarWallet = ImageAsset(name: "tab_bar_wallet")
    internal static let tabBarWalletActive = ImageAsset(name: "tab_bar_wallet_active")
  }
  internal enum Wallet {
    internal static let walletArrowGreen = ImageAsset(name: "wallet_arrow_green")
    internal static let walletArrowHeader = ImageAsset(name: "wallet_arrow_header")
    internal static let walletScanner = ImageAsset(name: "wallet_scanner")
    internal static let walletSort = ImageAsset(name: "wallet_sort")
  }
  internal static let addaddress24Submit300 = ImageAsset(name: "addaddress24Submit300")
  internal static let arrowGreen = ImageAsset(name: "arrow_green")
  internal static let arrowRed = ImageAsset(name: "arrow_red")
  internal static let arrowTransfer = ImageAsset(name: "arrow_transfer")
  internal static let arrowleft14Basic200 = ImageAsset(name: "arrowleft14Basic200")
  internal static let arrowright14Basic200 = ImageAsset(name: "arrowright14Basic200")
  internal static let assetChangeArrows = ImageAsset(name: "asset_change_arrows")
  internal static let assetReceive = ImageAsset(name: "asset_receive")
  internal static let assets = ImageAsset(name: "assets")
  internal static let backChevron = ImageAsset(name: "back-chevron")
  internal static let backspace48Disabled900 = ImageAsset(name: "backspace48Disabled900")
  internal static let bgIphone5Top = ImageAsset(name: "bg-iphone5-top")
  internal static let bgIphone5 = ImageAsset(name: "bg-iphone5")
  internal static let bgIphone8Top = ImageAsset(name: "bg-iphone8-top")
  internal static let bgIphone8 = ImageAsset(name: "bg-iphone8")
  internal static let bgIphone8plusTop = ImageAsset(name: "bg-iphone8plus-top")
  internal static let bgIphone8plus = ImageAsset(name: "bg-iphone8plus")
  internal static let bgIphonexTop = ImageAsset(name: "bg-iphonex-top")
  internal static let bgIphonex = ImageAsset(name: "bg-iphonex")
  internal static let btnBack = ImageAsset(name: "btn_back")
  internal static let btnBars = ImageAsset(name: "btn_bars")
  internal static let btnOrder = ImageAsset(name: "btn_order")
  internal static let changearrows14Basic500 = ImageAsset(name: "changearrows14Basic500")
  internal static let chartArrowGreen = ImageAsset(name: "chart_arrow_green")
  internal static let chartArrowRed = ImageAsset(name: "chart_arrow_red")
  internal static let chartEmpty = ImageAsset(name: "chart_empty")
  internal static let chartarrow22Accent100 = ImageAsset(name: "chartarrow22Accent100")
  internal static let chartarrow22Error500 = ImageAsset(name: "chartarrow22Error500")
  internal static let chartarrow22Success400 = ImageAsset(name: "chartarrow22Success400")
  internal static let checkMark = ImageAsset(name: "check_mark")
  internal static let checkSuccess = ImageAsset(name: "check_success")
  internal static let checkmarkEmpty = ImageAsset(name: "checkmark_empty")
  internal static let checkmarkEmptyGray = ImageAsset(name: "checkmark_empty_gray")
  internal static let checkmarkFill = ImageAsset(name: "checkmark_fill")
  internal static let checkmarkFillGray = ImageAsset(name: "checkmark_fill_gray")
  internal static let close = ImageAsset(name: "close")
  internal static let copyAddress = ImageAsset(name: "copy_address")
  internal static let copyBlack = ImageAsset(name: "copy_black")
  internal static let deladdress24Error400 = ImageAsset(name: "deladdress24Error400")
  internal static let delete = ImageAsset(name: "delete")
  internal static let delete22Error500 = ImageAsset(name: "delete22Error500")
  internal static let dex = ImageAsset(name: "dex")
  internal static let disclosure = ImageAsset(name: "disclosure")
  internal static let doneBtn = ImageAsset(name: "done_btn")
  internal static let downChevron = ImageAsset(name: "down-chevron")
  internal static let down = ImageAsset(name: "down")
  internal static let dragElem = ImageAsset(name: "dragElem")
  internal static let editaddress24Submit300 = ImageAsset(name: "editaddress24Submit300")
  internal static let eyeclsoe24Basic500 = ImageAsset(name: "eyeclsoe24Basic500")
  internal static let eyeopen24Basic500 = ImageAsset(name: "eyeopen24Basic500")
  internal static let faceid48Submit300 = ImageAsset(name: "faceid48Submit300")
  internal static let favorite14Submit300 = ImageAsset(name: "favorite14Submit300")
  internal static let favoriteMini14Submit300 = ImageAsset(name: "favoriteMini14Submit300")
  internal static let flag18Britain = ImageAsset(name: "flag18Britain")
  internal static let flag18China = ImageAsset(name: "flag18China")
  internal static let flag18Danish = ImageAsset(name: "flag18Danish")
  internal static let flag18Hindi = ImageAsset(name: "flag18Hindi")
  internal static let flag18Korea = ImageAsset(name: "flag18Korea")
  internal static let flag18Nederland = ImageAsset(name: "flag18Nederland")
  internal static let flag18Rus = ImageAsset(name: "flag18Rus")
  internal static let flag18Turkey = ImageAsset(name: "flag18Turkey")
  internal static let forwardChevron = ImageAsset(name: "forward-chevron")
  internal static let hide = ImageAsset(name: "hide")
  internal static let history = ImageAsset(name: "history")
  internal static let historyEmpty = ImageAsset(name: "history_empty")
  internal static let iAnonim42Submit400 = ImageAsset(name: "iAnonim42Submit400")
  internal static let iBackup42Submit400 = ImageAsset(name: "iBackup42Submit400")
  internal static let iMailopen42Submit400 = ImageAsset(name: "iMailopen42Submit400")
  internal static let iOs42Submit400 = ImageAsset(name: "iOs42Submit400")
  internal static let iPassbrowser42Submit400 = ImageAsset(name: "iPassbrowser42Submit400")
  internal static let iRefreshbrowser42Submit400 = ImageAsset(name: "iRefreshbrowser42Submit400")
  internal static let iShredder42Submit400 = ImageAsset(name: "iShredder42Submit400")
  internal static let iWifi42Submit400 = ImageAsset(name: "iWifi42Submit400")
  internal static let iconBtc = ImageAsset(name: "icon-btc")
  internal static let iconEth = ImageAsset(name: "icon-eth")
  internal static let iconAction = ImageAsset(name: "icon_action")
  internal static let iconCert = ImageAsset(name: "icon_cert")
  internal static let iconExchange = ImageAsset(name: "icon_exchange")
  internal static let iconFavEmpty = ImageAsset(name: "icon_fav_empty")
  internal static let iconLock = ImageAsset(name: "icon_lock")
  internal static let iconMenu = ImageAsset(name: "icon_menu")
  internal static let iconMenuSort = ImageAsset(name: "icon_menu_sort")
  internal static let iconReceive = ImageAsset(name: "icon_receive")
  internal static let iconSend = ImageAsset(name: "icon_send")
  internal static let iconWaves = ImageAsset(name: "icon_waves")
  internal static let info18Basic300 = ImageAsset(name: "info18Basic300")
  internal static let info18Error500 = ImageAsset(name: "info18Error500")
  internal static let info18Warning600 = ImageAsset(name: "info18Warning600")
  internal static let information22Multy = ImageAsset(name: "information22Multy")
  internal static let logo = ImageAsset(name: "logo")
  internal static let logo3x = ImageAsset(name: "logo3x")
  internal static let logoBitcoin48 = ImageAsset(name: "logoBitcoin48")
  internal static let logoBitcoincash48 = ImageAsset(name: "logoBitcoincash48")
  internal static let logoDash48 = ImageAsset(name: "logoDash48")
  internal static let logoEthereum48 = ImageAsset(name: "logoEthereum48")
  internal static let logoEuro48 = ImageAsset(name: "logoEuro48")
  internal static let logoLira48 = ImageAsset(name: "logoLira48")
  internal static let logoLtc48 = ImageAsset(name: "logoLtc48")
  internal static let logoMonero48 = ImageAsset(name: "logoMonero48")
  internal static let logoUsd48 = ImageAsset(name: "logoUsd48")
  internal static let logoWaves48 = ImageAsset(name: "logoWaves48")
  internal static let menuDiscord = ImageAsset(name: "menu_discord")
  internal static let menuFacebook = ImageAsset(name: "menu_facebook")
  internal static let menuGit = ImageAsset(name: "menu_git")
  internal static let menuTel = ImageAsset(name: "menu_tel")
  internal static let menuTitleLogo = ImageAsset(name: "menu_title_logo")
  internal static let menuTwitter = ImageAsset(name: "menu_twitter")
  internal static let minus18Disabled900 = ImageAsset(name: "minus18Disabled900")
  internal static let notStar = ImageAsset(name: "not_star")
  internal static let notStarBtn = ImageAsset(name: "not_star_btn")
  internal static let off = ImageAsset(name: "off")
  internal static let on = ImageAsset(name: "on")
  internal static let pMastercard28 = ImageAsset(name: "pMastercard28")
  internal static let pVisa28 = ImageAsset(name: "pVisa28")
  internal static let pairNotSelected = ImageAsset(name: "pair-not-selected")
  internal static let pairSelected = ImageAsset(name: "pair-selected")
  internal static let plus18Disabled900 = ImageAsset(name: "plus18Disabled900")
  internal static let qrcode = ImageAsset(name: "qrcode")
  internal static let qrcode24Basic500 = ImageAsset(name: "qrcode24Basic500")
  internal static let rBank14Basic500 = ImageAsset(name: "rBank14Basic500")
  internal static let rBank14White = ImageAsset(name: "rBank14White")
  internal static let rCard14Basic500 = ImageAsset(name: "rCard14Basic500")
  internal static let rCard14White = ImageAsset(name: "rCard14White")
  internal static let rGateway14Basic500 = ImageAsset(name: "rGateway14Basic500")
  internal static let rGateway14White = ImageAsset(name: "rGateway14White")
  internal static let rInwaves14Basic500 = ImageAsset(name: "rInwaves14Basic500")
  internal static let rInwaves14White = ImageAsset(name: "rInwaves14White")
  internal static let receive = ImageAsset(name: "receive")
  internal static let receiveBtn = ImageAsset(name: "receive_btn")
  internal static let repeatBtn = ImageAsset(name: "repeat_btn")
  internal static let search = ImageAsset(name: "search")
  internal static let search24Basic500 = ImageAsset(name: "search24Basic500")
  internal static let send = ImageAsset(name: "send")
  internal static let sendBtn = ImageAsset(name: "send_btn")
  internal static let settings = ImageAsset(name: "settings")
  internal static let shareAddress = ImageAsset(name: "share_address")
  internal static let sizefull14Basic500 = ImageAsset(name: "sizefull14Basic500")
  internal static let star = ImageAsset(name: "star")
  internal static let starBtn = ImageAsset(name: "star_btn")
  internal static let swipeLeft = ImageAsset(name: "swipe_left")
  internal static let swipeRight = ImageAsset(name: "swipe_right")
  internal static let tAlias48 = ImageAsset(name: "tAlias48")
  internal static let tCloselease28 = ImageAsset(name: "tCloselease28")
  internal static let tCloselease48 = ImageAsset(name: "tCloselease48")
  internal static let tData48 = ImageAsset(name: "tData48")
  internal static let tExchange48 = ImageAsset(name: "tExchange48")
  internal static let tIncominglease48 = ImageAsset(name: "tIncominglease48")
  internal static let tMassreceived48 = ImageAsset(name: "tMassreceived48")
  internal static let tMasstransfer48 = ImageAsset(name: "tMasstransfer48")
  internal static let tResend28 = ImageAsset(name: "tResend28")
  internal static let tSelftrans48 = ImageAsset(name: "tSelftrans48")
  internal static let tSend48 = ImageAsset(name: "tSend48")
  internal static let tSoonExchange28 = ImageAsset(name: "tSoonExchange28")
  internal static let tSoonExchange48 = ImageAsset(name: "tSoonExchange48")
  internal static let tSpamMassreceived48 = ImageAsset(name: "tSpamMassreceived48")
  internal static let tSpamReceive48 = ImageAsset(name: "tSpamReceive48")
  internal static let tTokenburn48 = ImageAsset(name: "tTokenburn48")
  internal static let tTokengen48 = ImageAsset(name: "tTokengen48")
  internal static let tTokenreis48 = ImageAsset(name: "tTokenreis48")
  internal static let tUndefined48 = ImageAsset(name: "tUndefined48")
  internal static let tabbarWavesActive = ImageAsset(name: "tabbarWavesActive")
  internal static let topbarAddaddress = ImageAsset(name: "topbarAddaddress")
  internal static let topbarAddmarkets = ImageAsset(name: "topbarAddmarkets")
  internal static let topbarBackwhite = ImageAsset(name: "topbarBackwhite")
  internal static let topbarClose = ImageAsset(name: "topbarClose")
  internal static let topbarClosewhite = ImageAsset(name: "topbarClosewhite")
  internal static let topbarFavoriteOff = ImageAsset(name: "topbarFavoriteOff")
  internal static let topbarFavoriteOn = ImageAsset(name: "topbarFavoriteOn")
  internal static let topbarFilter = ImageAsset(name: "topbarFilter")
  internal static let topbarFlashOff = ImageAsset(name: "topbarFlashOff")
  internal static let topbarFlashOn = ImageAsset(name: "topbarFlashOn")
  internal static let topbarInfowhite = ImageAsset(name: "topbarInfowhite")
  internal static let topbarLogout = ImageAsset(name: "topbarLogout")
  internal static let topbarMenuwhite = ImageAsset(name: "topbarMenuwhite")
  internal static let topbarSort = ImageAsset(name: "topbarSort")
  internal static let touchid48Submit300 = ImageAsset(name: "touchid48Submit300")
  internal static let unhide = ImageAsset(name: "unhide")
  internal static let upChevron = ImageAsset(name: "up-chevron@")
  internal static let userimgBackupmoney80Submit400 = ImageAsset(name: "userimgBackupmoney80Submit400")
  internal static let userimgBlockchain80White = ImageAsset(name: "userimgBlockchain80White")
  internal static let userimgDex80Multy = ImageAsset(name: "userimgDex80Multy")
  internal static let userimgDex80White = ImageAsset(name: "userimgDex80White")
  internal static let userimgDone80Success400 = ImageAsset(name: "userimgDone80Success400")
  internal static let userimgEmpty80Multi = ImageAsset(name: "userimgEmpty80Multi")
  internal static let userimgSeed80Submit400 = ImageAsset(name: "userimgSeed80Submit400")
  internal static let userimgToken80White = ImageAsset(name: "userimgToken80White")
  internal static let userimgWallet80White = ImageAsset(name: "userimgWallet80White")
  internal static let verification28Error500 = ImageAsset(name: "verification28Error500")
  internal static let verification28Success400 = ImageAsset(name: "verification28Success400")
  internal static let verified = ImageAsset(name: "verified")
  internal static let walletArrowRight = ImageAsset(name: "wallet_arrow_right")
  internal static let walletIconFav = ImageAsset(name: "wallet_icon_fav")
  internal static let walletInfo = ImageAsset(name: "wallet_info")
  internal static let walletQuickNote = ImageAsset(name: "wallet_quick_note")
  internal static let walletStartLease = ImageAsset(name: "wallet_start_lease")
  internal static let warning18Black = ImageAsset(name: "warning18Black")
  internal static let warningAddress = ImageAsset(name: "warning_address")

  // swiftlint:disable trailing_comma
  internal static let allColors: [ColorAsset] = [
  ]
  internal static let allImages: [ImageAsset] = [
    TabBar.tabBarDex,
    TabBar.tabBarDexActive,
    TabBar.tabBarHistory,
    TabBar.tabBarHistoryActive,
    TabBar.tabBarPlus,
    TabBar.tabBarPlusActive,
    TabBar.tabBarProfile,
    TabBar.tabBarProfileActive,
    TabBar.tabBarWallet,
    TabBar.tabBarWalletActive,
    Wallet.walletArrowGreen,
    Wallet.walletArrowHeader,
    Wallet.walletScanner,
    Wallet.walletSort,
    addaddress24Submit300,
    arrowGreen,
    arrowRed,
    arrowTransfer,
    arrowleft14Basic200,
    arrowright14Basic200,
    assetChangeArrows,
    assetReceive,
    assets,
    backChevron,
    backspace48Disabled900,
    bgIphone5Top,
    bgIphone5,
    bgIphone8Top,
    bgIphone8,
    bgIphone8plusTop,
    bgIphone8plus,
    bgIphonexTop,
    bgIphonex,
    btnBack,
    btnBars,
    btnOrder,
    changearrows14Basic500,
    chartArrowGreen,
    chartArrowRed,
    chartEmpty,
    chartarrow22Accent100,
    chartarrow22Error500,
    chartarrow22Success400,
    checkMark,
    checkSuccess,
    checkmarkEmpty,
    checkmarkEmptyGray,
    checkmarkFill,
    checkmarkFillGray,
    close,
    copyAddress,
    copyBlack,
    deladdress24Error400,
    delete,
    delete22Error500,
    dex,
    disclosure,
    doneBtn,
    downChevron,
    down,
    dragElem,
    editaddress24Submit300,
    eyeclsoe24Basic500,
    eyeopen24Basic500,
    faceid48Submit300,
    favorite14Submit300,
    favoriteMini14Submit300,
    flag18Britain,
    flag18China,
    flag18Danish,
    flag18Hindi,
    flag18Korea,
    flag18Nederland,
    flag18Rus,
    flag18Turkey,
    forwardChevron,
    hide,
    history,
    historyEmpty,
    iAnonim42Submit400,
    iBackup42Submit400,
    iMailopen42Submit400,
    iOs42Submit400,
    iPassbrowser42Submit400,
    iRefreshbrowser42Submit400,
    iShredder42Submit400,
    iWifi42Submit400,
    iconBtc,
    iconEth,
    iconAction,
    iconCert,
    iconExchange,
    iconFavEmpty,
    iconLock,
    iconMenu,
    iconMenuSort,
    iconReceive,
    iconSend,
    iconWaves,
    info18Basic300,
    info18Error500,
    info18Warning600,
    information22Multy,
    logo,
    logo3x,
    logoBitcoin48,
    logoBitcoincash48,
    logoDash48,
    logoEthereum48,
    logoEuro48,
    logoLira48,
    logoLtc48,
    logoMonero48,
    logoUsd48,
    logoWaves48,
    menuDiscord,
    menuFacebook,
    menuGit,
    menuTel,
    menuTitleLogo,
    menuTwitter,
    minus18Disabled900,
    notStar,
    notStarBtn,
    off,
    on,
    pMastercard28,
    pVisa28,
    pairNotSelected,
    pairSelected,
    plus18Disabled900,
    qrcode,
    qrcode24Basic500,
    rBank14Basic500,
    rBank14White,
    rCard14Basic500,
    rCard14White,
    rGateway14Basic500,
    rGateway14White,
    rInwaves14Basic500,
    rInwaves14White,
    receive,
    receiveBtn,
    repeatBtn,
    search,
    search24Basic500,
    send,
    sendBtn,
    settings,
    shareAddress,
    sizefull14Basic500,
    star,
    starBtn,
    swipeLeft,
    swipeRight,
    tAlias48,
    tCloselease28,
    tCloselease48,
    tData48,
    tExchange48,
    tIncominglease48,
    tMassreceived48,
    tMasstransfer48,
    tResend28,
    tSelftrans48,
    tSend48,
    tSoonExchange28,
    tSoonExchange48,
    tSpamMassreceived48,
    tSpamReceive48,
    tTokenburn48,
    tTokengen48,
    tTokenreis48,
    tUndefined48,
    tabbarWavesActive,
    topbarAddaddress,
    topbarAddmarkets,
    topbarBackwhite,
    topbarClose,
    topbarClosewhite,
    topbarFavoriteOff,
    topbarFavoriteOn,
    topbarFilter,
    topbarFlashOff,
    topbarFlashOn,
    topbarInfowhite,
    topbarLogout,
    topbarMenuwhite,
    topbarSort,
    touchid48Submit300,
    unhide,
    upChevron,
    userimgBackupmoney80Submit400,
    userimgBlockchain80White,
    userimgDex80Multy,
    userimgDex80White,
    userimgDone80Success400,
    userimgEmpty80Multi,
    userimgSeed80Submit400,
    userimgToken80White,
    userimgWallet80White,
    verification28Error500,
    verification28Success400,
    verified,
    walletArrowRight,
    walletIconFav,
    walletInfo,
    walletQuickNote,
    walletStartLease,
    warning18Black,
    warningAddress,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  internal static let allValues: [ImagesType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

internal extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
