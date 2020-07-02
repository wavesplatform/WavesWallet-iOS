//
//  MainTabBarCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DeviceKit
import DomainLayer
import Intercom

private enum Constants {
    static let tabBarItemImageInset = UIEdgeInsets.init(top: 0, left: 0, bottom: -8, right: 0)
}

private class ActionButtonViewController: UIViewController {}

protocol MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab()
}

final class MainTabBarCoordinator: NSObject, Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let windowRouter: WindowRouter
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

    private let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let analyticManager: AnalyticManagerProtocol = UseCasesFactory.instance.analyticManager
    private let walletsRepository: WalletsRepositoryProtocol = UseCasesFactory.instance.repositories.walletsRepositoryLocal
    private let userRepository: UserRepository = UseCasesFactory.instance.repositories.userRepository

    private let navigationRouterWallet: NavigationRouter = {

        let navigation = CustomNavigationController(navigationBarClass: UINavigationBar.self, toolbarClass: nil)
        
        navigation.tabBarItem.image = Images.tabbarWalletDefault.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.selectedImage = Images.tabbarWalletActive.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return NavigationRouter(navigationController: navigation)
    }()

    private let navigationRouterInvest: NavigationRouter = {

        let navigation = CustomNavigationController()

        navigation.tabBarItem.image = Images.invest26.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.selectedImage = Images.investActive26.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return NavigationRouter(navigationController: navigation)
    }()

    private let navigationRouterDex: NavigationRouter = {

        let navigation = CustomNavigationController()

        navigation.tabBarItem.image = Images.tabbarDexDefault.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.selectedImage = Images.tabbarDexActive.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return NavigationRouter(navigationController: navigation)
    }()

    private let navigationRouterProfile: NavigationRouter = {

        let navigation = CustomNavigationController()

        navigation.tabBarItem.image = Images.tabbarProfileDefault.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.selectedImage = Images.tabbarProfileActive.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return NavigationRouter(navigationController: navigation)
    }()

    private let popoperButton: ActionButtonViewController = {

        let navigation = ActionButtonViewController()
        navigation.tabBarItem.image = Images.chat26.image.withRenderingMode(.alwaysOriginal)
        navigation.tabBarItem.selectedImage = Images.chatActive26.image.withRenderingMode(.alwaysOriginal)
        
        navigation.tabBarItem.imageInsets = Constants.tabBarItemImageInset

        return navigation
    }()

    init(windowRouter: WindowRouter, applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.windowRouter = windowRouter
        self.applicationCoordinator = applicationCoordinator
        super.init()

        tabBarRouter.setViewControllers([navigationRouterWallet.navigationController,
                                         navigationRouterDex.navigationController,
                                         navigationRouterInvest.navigationController,
                                         popoperButton,
                                         navigationRouterProfile.navigationController])

        tabBarRouter.setSelectedIndex(2)
        
        let walletCoordinator = WalletCoordinator(navigationRouter: navigationRouterWallet)
        addChildCoordinatorAndStart(childCoordinator: walletCoordinator)

        let investingCoordinator = InvestmentCoordinator(navigationRouter: navigationRouterInvest)
        
        addChildCoordinatorAndStart(childCoordinator: investingCoordinator)
        
        
        let tradeCoordinator = TradeCoordinator(navigationRouter: navigationRouterDex)
        addChildCoordinatorAndStart(childCoordinator: tradeCoordinator)

        let profileCoordinator = ProfileCoordinator(navigationRouter: navigationRouterProfile,
                                                    applicationCoordinator: applicationCoordinator)
        addChildCoordinatorAndStart(childCoordinator: profileCoordinator)
        
    }

    func start() {
        windowRouter.setRootViewController(tabBarRouter.tabBarController)
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
            let tabBarItemAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.error400]
            let tabBarItemAttributedStrings = convertToOptionalNSAttributedStringKeyDictionary(tabBarItemAttributes)
            navProfile.tabBarItem.setBadgeTextAttributes(tabBarItemAttributedStrings, for: .normal)
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
            .flatMap({ [weak self] wallet -> Observable<Wallet> in
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
    
    private func handlerActionButton() {
            
        authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<(wallet: SignedWallet, uid: String)> in
                guard let self = self else { return Observable.never() }
                return self.userRepository.userUID(wallet: wallet).map { (wallet: wallet, uid: $0) }
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] wallet, uid in
        
                self?.analyticManager.trackEvent(.intercom(.intercomButtonTap))
                                
                Intercom.registerUser(withUserId: "\(uid)_\(wallet.address.suffix(4))")
                
                var value = IntercomInitial.value
                if let deviceToken = value.apns {                    
                    Intercom.setDeviceToken(deviceToken)
                }
                
                if (value.accounts[wallet.address] ?? false) == false {
                    self?.analyticManager.trackEvent(.intercom(.intercomInit))
                }
                
                value.accounts[wallet.address] = true
                IntercomInitial.set(value)
                
                let attributes = ICMUserAttributes()
                attributes.userId = wallet.address
                attributes.customAttributes = ["platform": "iOS",
                                               "version": Bundle.main.versionAndBuild,
                                               "device": Device.current.model ?? "",
                                               "carrierName": UIDevice.current.carrierName,
                                               "os": UIDevice.current.osVersion,
                                               "deviceId": UIDevice.uuid]
                Intercom.updateUser(attributes)
        
                Intercom.presentMessenger()
            })
            .disposed(by: disposeBag)
        
        
    }
}

// MARK: UITabBarControllerDelegate

extension MainTabBarCoordinator: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController is ActionButtonViewController {
            self.handlerActionButton()
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
