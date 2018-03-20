import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainTabBarController.customiseTabBar(tabBar: tabBar)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkOpenUrl), name:
            NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        checkOpenUrl()
        updateBadges()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkOpenUrl() {
        if OpenUrlManager.openUrl != nil {
            selectedIndex = 2
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateBadges() {
        self.tabBar.items![4].badgeValue = (WalletManager.currentWallet?.isBackedUp ?? false) ? nil : "1"
    }
    
    class func customiseTabBar(tabBar: UITabBar?) {
        tabBar?.barTintColor = AppColors.wavesColor
        tabBar?.tintColor = AppColors.activeColor
        if #available(iOS 10.0, *) {
            tabBar?.unselectedItemTintColor = AppColors.inactiveColor
        } else {
            // Fallback on earlier versions
        }
        
        /*UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0),
             NSForegroundColorAttributeName: UIColor(netHex: 0x717171)],
            forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name: "Bariol-Bold", size:14)!,
             NSForegroundColorAttributeName: UIColor(netHex: 0xFF585B)],
            forState: .Selected)*/

        //UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], for: .normal)
    }

    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        var isDexTab = false
        for (index, element) in (tabBar.items?.enumerated())! {
            
            if index == 3 && element == item {
                isDexTab = true
            }
        }
        
//        if isDexTab {
//            tabBar.barTintColor = AppColors.dexNavBarColor
//        }
//        else {
//            tabBar.barTintColor = AppColors.wavesColor
//        }
    }
}
