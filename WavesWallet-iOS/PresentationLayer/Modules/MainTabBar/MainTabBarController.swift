import UIKit
import RxSwift
import RxCocoa

private enum Constants {
    static let tabBarItemImageInset = UIEdgeInsets.init(top: 0, left: 0, bottom: -8, right: 0)
}
private class DUMPVC: UIViewController {}

protocol MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab()
}

final class MainTabBarController: UITabBarController {

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let walletsRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal

    private var walletCoordinator: WalletCoordinator!
    private var historyCoordinator: HistoryCoordinator!
    private var dexListCoordinator: DexCoordinator!
    private var profileCoordinator: ProfileCoordinator!

    private let navWallet = CustomNavigationController()
    private let navHistory = CustomNavigationController()
    private let navDex = CustomNavigationController()
    private let navProfile = CustomNavigationController()

    private let disposeBag = DisposeBag()

    weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        walletCoordinator = WalletCoordinator(navigationController: navWallet)
        walletCoordinator.start()
        navWallet.tabBarItem.image = Images.TabBar.tabBarWallet.image.withRenderingMode(.alwaysOriginal)
        navWallet.tabBarItem.imageInsets = Constants.tabBarItemImageInset
        navWallet.tabBarItem.selectedImage = Images.TabBar.tabBarWalletActive.image.withRenderingMode(.alwaysOriginal)

        historyCoordinator = HistoryCoordinator(navigationController: navHistory, historyType: .all)
        historyCoordinator.start()
        navHistory.tabBarItem.image = Images.TabBar.tabBarHistory.image.withRenderingMode(.alwaysOriginal)
        navHistory.tabBarItem.selectedImage = Images.TabBar.tabBarHistoryActive.image.withRenderingMode(.alwaysOriginal)
        navHistory.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        dexListCoordinator = DexCoordinator(navigationController: navDex)
        dexListCoordinator.start()
        navDex.tabBarItem.image = Images.TabBar.tabBarDex.image.withRenderingMode(.alwaysOriginal)
        navDex.tabBarItem.selectedImage = Images.TabBar.tabBarDexActive.image.withRenderingMode(.alwaysOriginal)
        navDex.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        profileCoordinator = ProfileCoordinator(navigationController: navProfile, applicationCoordinator: applicationCoordinator)
        profileCoordinator.start()
        navProfile.tabBarItem.image = Images.TabBar.tabBarProfile.image.withRenderingMode(.alwaysOriginal)
        navProfile.tabBarItem.selectedImage = Images.TabBar.tabBarProfileActive.image.withRenderingMode(.alwaysOriginal)
        navProfile.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        let fake = DUMPVC()
        fake.tabBarItem.image = Images.tabbarWavesDefault.image.withRenderingMode(.alwaysOriginal)
        fake.tabBarItem.imageInsets = Constants.tabBarItemImageInset
        viewControllers = [navWallet, navDex, fake, navHistory, navProfile]
        
        listenerWallet()
    }

    private func addTabBarBadge() {
        if #available(iOS 10.0, *) {
            navProfile.tabBarItem.badgeColor = UIColor.clear
            navProfile.tabBarItem.setBadgeTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: UIColor.error400]), for: .normal)
            navProfile.tabBarItem.badgeValue = "●"
        } else {
            navProfile.tabBarItem.badgeValue = "●"
        }
    }

    private func removeTabBarBadge() {
        navProfile.tabBarItem.badgeValue = nil
    }

    private func listenerWallet() {

        authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<DomainLayer.DTO.Wallet> in
                guard let strongSelf = self else { return Observable.empty() }
                return strongSelf.walletsRepository.listenerWallet(by: wallet.wallet.publicKey)
            })
            .asDriver(onErrorRecover: { _ in Driver.empty() })
            .drive(onNext: { [weak self] wallet in

                guard let strongSelf = self else { return }

                if wallet.isBackedUp {
                    strongSelf.removeTabBarBadge()
                } else {
                    strongSelf.addTabBarBadge()
                }


            })
            .disposed(by: disposeBag)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController is DUMPVC {
            let vc = StoryboardScene.Waves.wavesPopupViewController.instantiate()
            vc.moduleOutput = self
            let popup = PopupViewController()
            popup.contentHeight = 300
            popup.present(contentViewController: vc)

            return false
        }
        
        //TODO: need to implement more clearly logic
        if let nav = tabBarController.selectedViewController as? CustomNavigationController,
            let currentVC = nav.viewControllers.first,
            let nextNav = viewController as? CustomNavigationController,
            let nextVC = nextNav.viewControllers.first,
            currentVC === nextVC,
            let tabBarProtocol = currentVC as? MainTabBarControllerProtocol {

            tabBarProtocol.mainTabBarControllerDidTapTab()
        }
        return true
    }
}

//MARK: - WavesPopupModuleOutput
extension MainTabBarController: WavesPopupModuleOutput {
    
    func showSend() {
        
        if let nav = selectedViewController as? CustomNavigationController {
            let vc = SendModuleBuilder().build(input: .empty)
            nav.pushViewController(vc, animated: true)
        }
    }
    
    func showReceive() {
        
        if let nav = selectedViewController as? CustomNavigationController {
            let vc = ReceiveContainerModuleBuilder().build(input: nil)
            nav.pushViewController(vc, animated: true)
        }
    }
    
    func showExchange() {
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
