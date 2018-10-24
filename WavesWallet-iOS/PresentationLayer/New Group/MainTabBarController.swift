import UIKit
import RxSwift
import RxCocoa

private enum Constants {
    static let tabBarItemImageInset = UIEdgeInsetsMake(0, 0, -16, 0)
}
private class DUMPVC: UIViewController {}

final class MainTabBarController: UITabBarController {

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let walletsRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal

    private let walletCoordinator: WalletCoordinator = WalletCoordinator()
    private let historyCoordinator: HistoryCoordinator = HistoryCoordinator()
    private let dexListCoordinator: DexCoordinator = DexCoordinator()
    private var profileCoordinator: ProfileCoordinator!

    private let navWallet = CustomNavigationController()
    private let navHistory = CustomNavigationController()
    private let navDex = CustomNavigationController()
    private let navProfile = CustomNavigationController()

    private let disposeBag = DisposeBag()

    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    convenience init() {
        self.init(applicationCoordinator: nil)
    }

    init(applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.applicationCoordinator = applicationCoordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        listenerWallet()

        walletCoordinator.start(navigationController: navWallet)
        navWallet.tabBarItem.image = Images.TabBar.tabBarWallet.image.withRenderingMode(.alwaysOriginal)
        navWallet.tabBarItem.imageInsets = Constants.tabBarItemImageInset
        navWallet.tabBarItem.selectedImage = Images.TabBar.tabBarWalletActive.image.withRenderingMode(.alwaysOriginal)

        historyCoordinator.start(navigationController: navHistory, historyType: .all)
        navHistory.tabBarItem.image = Images.TabBar.tabBarHistory.image.withRenderingMode(.alwaysOriginal)
        navHistory.tabBarItem.selectedImage = Images.TabBar.tabBarHistoryActive.image.withRenderingMode(.alwaysOriginal)
        navHistory.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        dexListCoordinator.start(navigationController: navDex)
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
    }

    private func addTabBarBadge() {
        if #available(iOS 10.0, *) {
            navProfile.tabBarItem.badgeColor = UIColor.clear
            navProfile.tabBarItem.setBadgeTextAttributes([NSAttributedStringKey.foregroundColor.rawValue: UIColor.error400], for: .normal)
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
        return true
    }
}

//MARK: - WavesPopupModuleOutput
extension MainTabBarController: WavesPopupModuleOutput {
    
    func showSend() {
        
//        if let nav = selectedViewController as? CustomNavigationController {
//            let vc = StoryboardManager.WavesStoryboard().instantiateViewController(withIdentifier: "WavesSendViewController") as! WavesSendViewController
//            nav.pushViewController(vc, animated: true)
//        }
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
