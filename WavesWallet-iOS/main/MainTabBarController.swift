import UIKit
import RDVTabBarController

final class MainTabBarController: RDVTabBarController {

    let walletCoordinator: WalletCoordinator = WalletCoordinator()
    let historyCoordinator: HistoryCoordinator = HistoryCoordinator()
    let dexListCoordinator: DexCoordinator = DexCoordinator()

    override var viewControllers: [Any]! {
        didSet {
            let walletItem = tabBar.items[0] as! RDVTabBarItem
            walletItem.title = "Wallet"
            walletItem.setFinishedSelectedImage(UIImage(named: "tab_bar_wallet_black"), withFinishedUnselectedImage: UIImage(named: "tab_bar_wallet_gray"))

            let dexItem = tabBar.items[1] as! RDVTabBarItem
            dexItem.title = "DEX"
            dexItem.setFinishedSelectedImage(UIImage(named: "tab_bar_dex_black"), withFinishedUnselectedImage: UIImage(named: "tab_bar_dex_gray"))

            let plusItem = tabBar.items[2] as! RDVTabBarItem
            plusItem.setFinishedSelectedImage(UIImage(named: "tab_bar_plus"), withFinishedUnselectedImage: UIImage(named: "tab_bar_plus"))

            let historyItem = tabBar.items[3] as! RDVTabBarItem
            historyItem.title = "History"
            historyItem.setFinishedSelectedImage(UIImage(named: "tab_bar_history_black"), withFinishedUnselectedImage: UIImage(named: "tab_bar_history_gray"))

            let profileItem = tabBar.items[4] as! RDVTabBarItem
            profileItem.title = "Profile"
            profileItem.setFinishedSelectedImage(UIImage(named: "tab_bar_profile_black"), withFinishedUnselectedImage: UIImage(named: "tab_bar_profile_gray"))
            
            for tabBarItem in tabBar.items {
                setupTabBarItem(tabBarItem as! RDVTabBarItem)
            }
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Platform.isIphoneX {
            tabBar.setHeight(83)
        }
        else {
            tabBar.setHeight(50)
        }

        let navWallet = CustomNavigationController()
        walletCoordinator.start(navigationController: navWallet)
        
        let navHistory = CustomNavigationController()
        historyCoordinator.start(navigationController: navHistory, historyType: .all)

        let navDex = CustomNavigationController()
        dexListCoordinator.start(navigationController: navDex)
        
        
        let profile = StoryboardManager.ProfileStoryboard().instantiateViewController(withIdentifier: "ProfileViewController")
        let navProfile = CustomNavigationController(rootViewController: profile)
        
        viewControllers = [navWallet, navDex, UIViewController(), navHistory, navProfile]

        tabBar.backgroundView.backgroundColor = UIColor.white

        let line = UIView(frame: CGRect(x: 0, y: 0, width: Platform.ScreenWidth, height: 0.5))
        line.backgroundColor = UIColor(188, 188, 188)
        tabBar.addSubview(line)
        
        selectedIndex = 0
    }
    
    func setupTabBarItem(_ tabBarItem: RDVTabBarItem) {
        tabBarItem.selectedTitleAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black,
                                              NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]
        tabBarItem.unselectedTitleAttributes = [NSAttributedStringKey.foregroundColor : UIColor(153, 153, 153),
                                                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]
        tabBarItem.titlePositionAdjustment = UIOffsetMake(0, 3)
        
        if Platform.isIphoneX {
            tabBarItem.imagePositionAdjustment = UIOffsetMake(0, -15)
            tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -13)
        }
    }
    
    override func tabBar(_ tabBar: RDVTabBar!, shouldSelectItemAt index: Int) -> Bool {
        if index == 2 {
            
            let controller = StoryboardManager.WavesStoryboard().instantiateViewController(withIdentifier: "WavesPopupViewController")
            let popup = PopupViewController()
            popup.contentHeight = 300
            popup.present(contentViewController: controller)
            return false
        }
        return super.tabBar(tabBar, shouldSelectItemAt: index)
    }

    func updateBadges() {
        let profileItem = tabBar.items[4] as! RDVTabBarItem
        profileItem.badgeValue = (WalletManager.currentWallet?.isBackedUp ?? false) ? nil : "1"
    }

    func setupLastScrollCorrectOffset() {
//        let nav = selectedViewController as! UINavigationController
//        for controller in nav.viewControllers {
//            let selector = #selector(WalletViewController.setupLastScrollCorrectOffset)
//            if controller.responds(to: selector) {
//                controller.perform(selector)
//            }
//        }
    }
}
