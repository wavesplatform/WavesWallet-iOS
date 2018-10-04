import UIKit

private class DUMPVC: UIViewController {}

final class MainTabBarController: UITabBarController {

    let walletCoordinator: WalletCoordinator = WalletCoordinator()
    let historyCoordinator: HistoryCoordinator = HistoryCoordinator()
    let dexListCoordinator: DexCoordinator = DexCoordinator()
    var profileCoordinator: ProfileCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let navWallet = CustomNavigationController()
        walletCoordinator.start(navigationController: navWallet)
        navWallet.tabBarItem.image = Images.TabBar.tabBarWallet.image.withRenderingMode(.alwaysOriginal)
        navWallet.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, -16, 0)
        navWallet.tabBarItem.selectedImage = Images.TabBar.tabBarWalletActive.image.withRenderingMode(.alwaysOriginal)

        let navHistory = CustomNavigationController()
        historyCoordinator.start(navigationController: navHistory, historyType: .all)
        navHistory.tabBarItem.image = Images.TabBar.tabBarHistory.image.withRenderingMode(.alwaysOriginal)
        navHistory.tabBarItem.selectedImage = Images.TabBar.tabBarHistoryActive.image.withRenderingMode(.alwaysOriginal)
        navHistory.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, -16, 0)

        let navDex = CustomNavigationController()
        dexListCoordinator.start(navigationController: navDex)
        navDex.tabBarItem.image = Images.TabBar.tabBarDex.image.withRenderingMode(.alwaysOriginal)
        navDex.tabBarItem.selectedImage = Images.TabBar.tabBarDexActive.image.withRenderingMode(.alwaysOriginal)
        navDex.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, -16, 0)

        let navProfile = CustomNavigationController()
        profileCoordinator = ProfileCoordinator(navigationController: navProfile)
        profileCoordinator.start()
        navProfile.tabBarItem.image = Images.TabBar.tabBarProfile.image.withRenderingMode(.alwaysOriginal)
        navProfile.tabBarItem.selectedImage = Images.TabBar.tabBarProfileActive.image.withRenderingMode(.alwaysOriginal)
        navProfile.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, -16, 0)

        if #available(iOS 10.0, *) {
            navProfile.tabBarItem.badgeColor = UIColor.clear
            navProfile.tabBarItem.setBadgeTextAttributes([NSAttributedStringKey.foregroundColor.rawValue: UIColor.red], for: .normal)
            navProfile.tabBarItem.badgeValue = "●"
        } else {
            navProfile.tabBarItem.badgeValue = ""
        }

        let fake = DUMPVC()
        fake.tabBarItem.image = Images.tabbarWavesDefault.image.withRenderingMode(.alwaysOriginal)
        fake.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, -16, 0)
        viewControllers = [navWallet, navDex, fake, navHistory, navProfile]
    }
}

extension MainTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController is DUMPVC {
            let controller = StoryboardManager.WavesStoryboard().instantiateViewController(withIdentifier: "WavesPopupViewController")
            let popup = PopupViewController()
            popup.contentHeight = 300
            popup.present(contentViewController: controller)
            return false
        }
        return true
    }
}
