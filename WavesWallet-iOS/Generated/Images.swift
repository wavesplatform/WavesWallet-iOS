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
  internal static let image = ImageAsset(name: "Image")
  internal static let addAddressIcon = ImageAsset(name: "add_address_icon")
  internal static let addaddress24Submit200 = ImageAsset(name: "addaddress24Submit200")
  internal static let addaddress24Submit300 = ImageAsset(name: "addaddress24Submit300")
  internal static let arrowGreen = ImageAsset(name: "arrow_green")
  internal static let arrowLeft = ImageAsset(name: "arrow_left")
  internal static let arrowRed = ImageAsset(name: "arrow_red")
  internal static let arrowRight = ImageAsset(name: "arrow_right")
  internal static let arrowTransfer = ImageAsset(name: "arrow_transfer")
  internal static let arrowdown14Basic300 = ImageAsset(name: "arrowdown14Basic300")
  internal static let arrowdown24Black = ImageAsset(name: "arrowdown24Black")
  internal static let arrowright14Basic200 = ImageAsset(name: "arrowright14Basic200")
  internal static let arrowup14Basic300 = ImageAsset(name: "arrowup14Basic300")
  internal static let assetChangeArrows = ImageAsset(name: "asset_change_arrows")
  internal static let assetReceive = ImageAsset(name: "asset_receive")
  internal static let assets = ImageAsset(name: "assets")
  internal static let backChevron = ImageAsset(name: "back-chevron")
  internal static let backspace48Disabled900 = ImageAsset(name: "backspace48Disabled900")
  internal static let bchHardforkPart1 = ImageAsset(name: "bchHardforkPart1")
  internal static let bgIphone5 = ImageAsset(name: "bg-iphone5")
  internal static let bgIphone8 = ImageAsset(name: "bg-iphone8")
  internal static let bgIphone8plus = ImageAsset(name: "bg-iphone8plus")
  internal static let bgIphonex = ImageAsset(name: "bg-iphonex")
  internal static let bgIphonexr = ImageAsset(name: "bg-iphonexr")
  internal static let bgIphonexsmax = ImageAsset(name: "bg-iphonexsmax")
  internal static let blockchain80 = ImageAsset(name: "blockchain80")
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
  internal static let check18Success400 = ImageAsset(name: "check18Success400")
  internal static let checkMark = ImageAsset(name: "check_mark")
  internal static let checkSuccess = ImageAsset(name: "check_success")
  internal static let checkboxOff = ImageAsset(name: "checkbox-off")
  internal static let checkboxOn = ImageAsset(name: "checkbox-on")
  internal static let close = ImageAsset(name: "close")
  internal static let closeLeaseIcon = ImageAsset(name: "close_lease_icon")
  internal static let copy18Black = ImageAsset(name: "copy18Black")
  internal static let copy18Submit400 = ImageAsset(name: "copy18Submit400")
  internal static let copyAddress = ImageAsset(name: "copy_address")
  internal static let copyBlack = ImageAsset(name: "copy_black")
  internal static let deladdress24Error400 = ImageAsset(name: "deladdress24Error400")
  internal static let delete = ImageAsset(name: "delete")
  internal static let delete22Error500 = ImageAsset(name: "delete22Error500")
  internal static let dex = ImageAsset(name: "dex")
  internal static let dex80 = ImageAsset(name: "dex80")
  internal static let disclosure = ImageAsset(name: "disclosure")
  internal static let doneBtn = ImageAsset(name: "done_btn")
  internal static let downChevron = ImageAsset(name: "down-chevron")
  internal static let down = ImageAsset(name: "down")
  internal static let dragElem = ImageAsset(name: "dragElem")
  internal static let draglock22Disabled400 = ImageAsset(name: "draglock22Disabled400")
  internal static let editAddressIcon = ImageAsset(name: "edit_address_icon")
  internal static let editaddress24Submit200 = ImageAsset(name: "editaddress24Submit200")
  internal static let editaddress24Submit300 = ImageAsset(name: "editaddress24Submit300")
  internal static let eyeclsoe24Basic500 = ImageAsset(name: "eyeclsoe24Basic500")
  internal static let eyeopen24Basic500 = ImageAsset(name: "eyeopen24Basic500")
  internal static let faceid48Submit300 = ImageAsset(name: "faceid48Submit300")
  internal static let favorite14Submit300 = ImageAsset(name: "favorite14Submit300")
  internal static let favoriteMini14Submit300 = ImageAsset(name: "favoriteMini14Submit300")
  internal static let flag18Brazil = ImageAsset(name: "flag18Brazil")
  internal static let flag18Britain = ImageAsset(name: "flag18Britain")
  internal static let flag18China = ImageAsset(name: "flag18China")
  internal static let flag18Danish = ImageAsset(name: "flag18Danish")
  internal static let flag18Germany = ImageAsset(name: "flag18Germany")
  internal static let flag18Hindi = ImageAsset(name: "flag18Hindi")
  internal static let flag18Indonesia = ImageAsset(name: "flag18Indonesia")
  internal static let flag18Italiano = ImageAsset(name: "flag18Italiano")
  internal static let flag18Japan = ImageAsset(name: "flag18Japan")
  internal static let flag18Korea = ImageAsset(name: "flag18Korea")
  internal static let flag18Nederland = ImageAsset(name: "flag18Nederland")
  internal static let flag18Polszczyzna = ImageAsset(name: "flag18Polszczyzna")
  internal static let flag18Portugal = ImageAsset(name: "flag18Portugal")
  internal static let flag18Rus = ImageAsset(name: "flag18Rus")
  internal static let flag18Spain = ImageAsset(name: "flag18Spain")
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
  internal static let identifiergateway14Ocean = ImageAsset(name: "identifiergateway14Ocean")
  internal static let info18Basic300 = ImageAsset(name: "info18Basic300")
  internal static let info18Error500 = ImageAsset(name: "info18Error500")
  internal static let info18Warning600 = ImageAsset(name: "info18Warning600")
  internal static let information22Multy = ImageAsset(name: "information22Multy")
  internal static let launcher34 = ImageAsset(name: "launcher34")
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
  internal static let logoWct48 = ImageAsset(name: "logoWct48")
  internal static let logoZec48 = ImageAsset(name: "logoZec48")
  internal static let menuDiscord = ImageAsset(name: "menu_discord")
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
  internal static let refresh18Basic500 = ImageAsset(name: "refresh18Basic500")
  internal static let refresh18White = ImageAsset(name: "refresh18White")
  internal static let repeatBtn = ImageAsset(name: "repeat_btn")
  internal static let resendIcon = ImageAsset(name: "resend_icon")
  internal static let sReddit28 = ImageAsset(name: "sReddit28")
  internal static let scriptasset18White = ImageAsset(name: "scriptasset18White")
  internal static let search = ImageAsset(name: "search")
  internal static let search24Basic500 = ImageAsset(name: "search24Basic500")
  internal static let send = ImageAsset(name: "send")
  internal static let sendBtn = ImageAsset(name: "send_btn")
  internal static let settings = ImageAsset(name: "settings")
  internal static let share18Submit400 = ImageAsset(name: "share18Submit400")
  internal static let shareAddress = ImageAsset(name: "share_address")
  internal static let sizefull14Basic500 = ImageAsset(name: "sizefull14Basic500")
  internal static let sponsoritem18White = ImageAsset(name: "sponsoritem18White")
  internal static let star = ImageAsset(name: "star")
  internal static let starBtn = ImageAsset(name: "star_btn")
  internal static let swipeLeft = ImageAsset(name: "swipe_left")
  internal static let swipeRight = ImageAsset(name: "swipe_right")
  internal static let tAlias48 = ImageAsset(name: "tAlias48")
  internal static let tCloselease18 = ImageAsset(name: "tCloselease18")
  internal static let tCloselease48 = ImageAsset(name: "tCloselease48")
  internal static let tData48 = ImageAsset(name: "tData48")
  internal static let tExchange48 = ImageAsset(name: "tExchange48")
  internal static let tIncominglease48 = ImageAsset(name: "tIncominglease48")
  internal static let tMassreceived48 = ImageAsset(name: "tMassreceived48")
  internal static let tMasstransfer48 = ImageAsset(name: "tMasstransfer48")
  internal static let tResend18 = ImageAsset(name: "tResend18")
  internal static let tSelftrans48 = ImageAsset(name: "tSelftrans48")
  internal static let tSend48 = ImageAsset(name: "tSend48")
  internal static let tSetassetscript48 = ImageAsset(name: "tSetassetscript48")
  internal static let tSetscript48 = ImageAsset(name: "tSetscript48")
  internal static let tSetscriptCancel48 = ImageAsset(name: "tSetscriptCancel48")
  internal static let tSoonExchange28 = ImageAsset(name: "tSoonExchange28")
  internal static let tSoonExchange48 = ImageAsset(name: "tSoonExchange48")
  internal static let tSpamMassreceived48 = ImageAsset(name: "tSpamMassreceived48")
  internal static let tSpamReceive48 = ImageAsset(name: "tSpamReceive48")
  internal static let tSponsoredDisable48 = ImageAsset(name: "tSponsoredDisable48")
  internal static let tSponsoredEnable48 = ImageAsset(name: "tSponsoredEnable48")
  internal static let tSponsoredPlus48 = ImageAsset(name: "tSponsoredPlus48")
  internal static let tStartlease48 = ImageAsset(name: "tStartlease48")
  internal static let tTokenburn24 = ImageAsset(name: "tTokenburn24")
  internal static let tTokenburn48 = ImageAsset(name: "tTokenburn48")
  internal static let tTokengen48 = ImageAsset(name: "tTokengen48")
  internal static let tTokenreis48 = ImageAsset(name: "tTokenreis48")
  internal static let tUndefined48 = ImageAsset(name: "tUndefined48")
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
  internal static let tabbarWavesActive = ImageAsset(name: "tabbarWavesActive")
  internal static let tabbarWavesDefault = ImageAsset(name: "tabbarWavesDefault")
  internal static let token80 = ImageAsset(name: "token80")
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
  internal static let userimgBackup100 = ImageAsset(name: "userimgBackup100")
  internal static let userimgBlockchain80 = ImageAsset(name: "userimgBlockchain80")
  internal static let userimgBlockchain80White = ImageAsset(name: "userimgBlockchain80White")
  internal static let userimgDex80 = ImageAsset(name: "userimgDex80")
  internal static let userimgDex80Multy = ImageAsset(name: "userimgDex80Multy")
  internal static let userimgDex80White = ImageAsset(name: "userimgDex80White")
  internal static let userimgDisconnect80Multy = ImageAsset(name: "userimgDisconnect80Multy")
  internal static let userimgDone80Success400 = ImageAsset(name: "userimgDone80Success400")
  internal static let userimgEmpty80Multi = ImageAsset(name: "userimgEmpty80Multi")
  internal static let userimgPairing80 = ImageAsset(name: "userimgPairing80")
  internal static let userimgSeed80Submit400 = ImageAsset(name: "userimgSeed80Submit400")
  internal static let userimgServerdown80Multy = ImageAsset(name: "userimgServerdown80Multy")
  internal static let userimgWallet80 = ImageAsset(name: "userimgWallet80")
  internal static let userimgWallet80White = ImageAsset(name: "userimgWallet80White")
  internal static let verification28Error500 = ImageAsset(name: "verification28Error500")
  internal static let verification28Success400 = ImageAsset(name: "verification28Success400")
  internal static let verified = ImageAsset(name: "verified")
  internal static let viewexplorer18Black = ImageAsset(name: "viewexplorer18Black")
  internal static let wallet80 = ImageAsset(name: "wallet80")
  internal static let walletArrowGreen = ImageAsset(name: "wallet_arrow_green")
  internal static let walletArrowHeader = ImageAsset(name: "wallet_arrow_header")
  internal static let walletArrowRight = ImageAsset(name: "wallet_arrow_right")
  internal static let walletIconFav = ImageAsset(name: "wallet_icon_fav")
  internal static let walletInfo = ImageAsset(name: "wallet_info")
  internal static let walletQuickNote = ImageAsset(name: "wallet_quick_note")
  internal static let walletScanner = ImageAsset(name: "wallet_scanner")
  internal static let walletSort = ImageAsset(name: "wallet_sort")
  internal static let walletStartLease = ImageAsset(name: "wallet_start_lease")
  internal static let warning18Black = ImageAsset(name: "warning18Black")
  internal static let warning18Disabled500 = ImageAsset(name: "warning18Disabled500")
  internal static let warning18White = ImageAsset(name: "warning18White")
  internal static let warningAddress = ImageAsset(name: "warning_address")
  internal static let wavesLogo = ImageAsset(name: "waves_logo")

  // swiftlint:disable trailing_comma
  internal static let allColors: [ColorAsset] = [
  ]
  internal static let allImages: [ImageAsset] = [
    image,
    addAddressIcon,
    addaddress24Submit200,
    addaddress24Submit300,
    arrowGreen,
    arrowLeft,
    arrowRed,
    arrowRight,
    arrowTransfer,
    arrowdown14Basic300,
    arrowdown24Black,
    arrowright14Basic200,
    arrowup14Basic300,
    assetChangeArrows,
    assetReceive,
    assets,
    backChevron,
    backspace48Disabled900,
    bchHardforkPart1,
    bgIphone5,
    bgIphone8,
    bgIphone8plus,
    bgIphonex,
    bgIphonexr,
    bgIphonexsmax,
    blockchain80,
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
    check18Success400,
    checkMark,
    checkSuccess,
    checkboxOff,
    checkboxOn,
    close,
    closeLeaseIcon,
    copy18Black,
    copy18Submit400,
    copyAddress,
    copyBlack,
    deladdress24Error400,
    delete,
    delete22Error500,
    dex,
    dex80,
    disclosure,
    doneBtn,
    downChevron,
    down,
    dragElem,
    draglock22Disabled400,
    editAddressIcon,
    editaddress24Submit200,
    editaddress24Submit300,
    eyeclsoe24Basic500,
    eyeopen24Basic500,
    faceid48Submit300,
    favorite14Submit300,
    favoriteMini14Submit300,
    flag18Brazil,
    flag18Britain,
    flag18China,
    flag18Danish,
    flag18Germany,
    flag18Hindi,
    flag18Indonesia,
    flag18Italiano,
    flag18Japan,
    flag18Korea,
    flag18Nederland,
    flag18Polszczyzna,
    flag18Portugal,
    flag18Rus,
    flag18Spain,
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
    identifiergateway14Ocean,
    info18Basic300,
    info18Error500,
    info18Warning600,
    information22Multy,
    launcher34,
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
    logoWct48,
    logoZec48,
    menuDiscord,
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
    refresh18Basic500,
    refresh18White,
    repeatBtn,
    resendIcon,
    sReddit28,
    scriptasset18White,
    search,
    search24Basic500,
    send,
    sendBtn,
    settings,
    share18Submit400,
    shareAddress,
    sizefull14Basic500,
    sponsoritem18White,
    star,
    starBtn,
    swipeLeft,
    swipeRight,
    tAlias48,
    tCloselease18,
    tCloselease48,
    tData48,
    tExchange48,
    tIncominglease48,
    tMassreceived48,
    tMasstransfer48,
    tResend18,
    tSelftrans48,
    tSend48,
    tSetassetscript48,
    tSetscript48,
    tSetscriptCancel48,
    tSoonExchange28,
    tSoonExchange48,
    tSpamMassreceived48,
    tSpamReceive48,
    tSponsoredDisable48,
    tSponsoredEnable48,
    tSponsoredPlus48,
    tStartlease48,
    tTokenburn24,
    tTokenburn48,
    tTokengen48,
    tTokenreis48,
    tUndefined48,
    tabBarDex,
    tabBarDexActive,
    tabBarHistory,
    tabBarHistoryActive,
    tabBarPlus,
    tabBarPlusActive,
    tabBarProfile,
    tabBarProfileActive,
    tabBarWallet,
    tabBarWalletActive,
    tabbarWavesActive,
    tabbarWavesDefault,
    token80,
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
    userimgBackup100,
    userimgBlockchain80,
    userimgBlockchain80White,
    userimgDex80,
    userimgDex80Multy,
    userimgDex80White,
    userimgDisconnect80Multy,
    userimgDone80Success400,
    userimgEmpty80Multi,
    userimgPairing80,
    userimgSeed80Submit400,
    userimgServerdown80Multy,
    userimgWallet80,
    userimgWallet80White,
    verification28Error500,
    verification28Success400,
    verified,
    viewexplorer18Black,
    wallet80,
    walletArrowGreen,
    walletArrowHeader,
    walletArrowRight,
    walletIconFav,
    walletInfo,
    walletQuickNote,
    walletScanner,
    walletSort,
    walletStartLease,
    warning18Black,
    warning18Disabled500,
    warning18White,
    warningAddress,
    wavesLogo,
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
