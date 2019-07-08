//
//  MainTabBarCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private enum Constants {
    static let tabBarItemImageInset = UIEdgeInsets.init(top: 0, left: 0, bottom: -8, right: 0)
}

private class PopoperButtonViewController: UIViewController {}

protocol MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab()
}

final class MainTabBarCoordinator: NSObject, Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let slideMenuRouter: SlideMenuRouter
    private lazy var tabBarRouter: TabBarRouter = {

        let mainTabBar = StoryboardScene.Main.mainTabBarController.instantiate()

        mainTabBar.delegate = self
        mainTabBar.tabBar.isTranslucent = false
        mainTabBar.tabBar.barTintColor = .white
        mainTabBar.tabBar.backgroundImage = UIImage()
        mainTabBar.tabBar.shadowImage = UIImage.shadowImage(color: .accent100)

        return TabBarRouter(tabBarController: mainTabBar)
    }()

    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?
    private let disposeBag = DisposeBag()

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let walletsRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal

    private let navigationRouterWallet: NavigationRouter = {

        let navigation = CustomNavigationController()

        navigation.tabBarItem.image = Images.tabBarWallet.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset
        navigation.tabBarItem.selectedImage = Images.tabBarWalletActive.image.withRenderingMode(.alwaysOriginal)

        return NavigationRouter(navigationController: navigation)
    }()

    private let navigationRouterHistory: NavigationRouter = {

        let navigation = CustomNavigationController()

        navigation.tabBarItem.image = Images.tabBarHistory.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.selectedImage = Images.tabBarHistoryActive.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return NavigationRouter(navigationController: navigation)
    }()

    private let navigationRouterDex: NavigationRouter = {

        let navigation = CustomNavigationController()

        navigation.tabBarItem.image = Images.tabBarDex.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.selectedImage = Images.tabBarDexActive.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return NavigationRouter(navigationController: navigation)
    }()

    private let navigationRouterProfile: NavigationRouter = {

        let navigation = CustomNavigationController()

        navigation.tabBarItem.image = Images.tabBarProfile.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.selectedImage = Images.tabBarProfileActive.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return NavigationRouter(navigationController: navigation)
    }()

    private let popoperButton: PopoperButtonViewController = {

        let popoperButton = PopoperButtonViewController()
        popoperButton.tabBarItem.image = Images.tabbarWavesDefault.image.withRenderingMode(.alwaysOriginal)
        popoperButton.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return popoperButton
    }()

    init(slideMenuRouter: SlideMenuRouter, applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.slideMenuRouter = slideMenuRouter
        self.applicationCoordinator = applicationCoordinator
        super.init()

        tabBarRouter.setViewControllers([navigationRouterWallet.navigationController,
                                         navigationRouterDex.navigationController,
                                         popoperButton,
                                         navigationRouterHistory.navigationController,
                                         navigationRouterProfile.navigationController])

        let walletCoordinator = WalletCoordinator(navigationRouter: navigationRouterWallet)
        addChildCoordinatorAndStart(childCoordinator: walletCoordinator)

        let historyCoordinator = HistoryCoordinator(navigationRouter: navigationRouterHistory, historyType: .all)
        addChildCoordinatorAndStart(childCoordinator: historyCoordinator)

        let dexListCoordinator = DexCoordinator(navigationRouter: navigationRouterDex)
        addChildCoordinatorAndStart(childCoordinator: dexListCoordinator)

        let profileCoordinator = ProfileCoordinator(navigationRouter: navigationRouterProfile, applicationCoordinator: applicationCoordinator)
        addChildCoordinatorAndStart(childCoordinator: profileCoordinator)
    }

    func start() {
        slideMenuRouter.setContentViewController(tabBarRouter.tabBarController)
        listenerWallet()
    }
}

// MARK: Logic

private extension MainTabBarCoordinator {

    var navProfile: UINavigationController {
        return navigationRouterProfile.navigationController
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
                guard let self = self else { return Observable.empty() }
                return self.walletsRepository.listenerWallet(by: wallet.wallet.publicKey)
            })
            .asDriver(onErrorRecover: { _ in Driver.empty() })
            .drive(onNext: { [weak self] wallet in

                guard let self = self else { return }

                if wallet.isBackedUp {
                    self.removeTabBarBadge()
                } else {
                    self.addTabBarBadge()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: UITabBarControllerDelegate

extension MainTabBarCoordinator: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController is PopoperButtonViewController {
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
            currentVC == nextVC,
            let tabBarProtocol = currentVC as? MainTabBarControllerProtocol {

            tabBarProtocol.mainTabBarControllerDidTapTab()
        }
        return true
    }
}

// MARK: - WavesPopupModuleOutput

extension MainTabBarCoordinator: WavesPopupModuleOutput {

    private var selectedViewController: UIViewController? {
        return tabBarRouter.tabBarController.selectedViewController
    }

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

    func showExchange() {}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
