import UIKit
import RDVTabBarController

final class MainTabBarController: RDVTabBarController {

    let walletCoordinator: WalletCoordinator = WalletCoordinator()
    let historyCoordinator: HistoryCoordinator = HistoryCoordinator()
    let dexListCoordinator: DexCoordinator = DexCoordinator()

    override var viewControllers: [Any]! {
        didSet {
            let walletItem = tabBar.items[0] as! RDVTabBarItem
            walletItem.setFinishedSelectedImage(Images.TabBar.tabBarWalletActive.image, withFinishedUnselectedImage: Images.TabBar.tabBarWallet.image)

            let dexItem = tabBar.items[1] as! RDVTabBarItem
            dexItem.setFinishedSelectedImage(Images.TabBar.tabBarDexActive.image, withFinishedUnselectedImage: Images.TabBar.tabBarDex.image)

            let plusItem = tabBar.items[2] as! RDVTabBarItem
            plusItem.setFinishedSelectedImage(Images.TabBar.tabBarPlusActive.image, withFinishedUnselectedImage: Images.TabBar.tabBarPlus.image)

            let historyItem = tabBar.items[3] as! RDVTabBarItem
            historyItem.setFinishedSelectedImage(Images.TabBar.tabBarHistoryActive.image, withFinishedUnselectedImage: Images.TabBar.tabBarHistory.image)

            let profileItem = tabBar.items[4] as! RDVTabBarItem
            profileItem.setFinishedSelectedImage(Images.TabBar.tabBarProfileActive.image, withFinishedUnselectedImage: Images.TabBar.tabBarProfile.image)
            
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
