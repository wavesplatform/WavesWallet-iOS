//
//  AppCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RESideMenu


private struct Application: TSUD {

    struct Settings: Codable, Mutating {
        var isAlreadyShownHelloDisplay: Bool  = false
    }

    private static let key: String = "com.waves.application.settings"

    static var defaultValue: Settings {
        return Settings(isAlreadyShownHelloDisplay: false)
    }

    static var stringKey: String {
        return Application.key
    }
}

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let window: UIWindow
    private var sideMenu: RESideMenu?

    init(_ window: UIWindow) {
        self.window = window
    }

    func start() {

        let info = WalletManager.isWalletLoggedIn

        if let item = info.item, info.isLoggedIn == true {
            WalletManager.didLogin(toWallet: item)
        } else {
            let settings = Application.get()
            if settings.isAlreadyShownHelloDisplay {
                showStartController()
            } else {
                showHelloDisplay()
            }
        }
    }

    private func showHelloDisplay() {
        let helloCoordinator = HelloCoordinator(window)
        helloCoordinator.delegate = self
        addChildCoordinator(childCoordinator: helloCoordinator)
        helloCoordinator.start()
    }

    private func showStartController() {
        let enter = StoryboardScene.Enter.enterStartViewController.instantiate()
        let navigationController = CustomNavigationController(rootViewController: enter)
        showSideMenuViewController(contentViewController: navigationController)
    }

    private func showSideMenuViewController(contentViewController: UIViewController) {

//        self.window.rootViewController = contentViewController
//
//        self.window.makeKeyAndVisible()
//        return

        let menuController = StoryboardScene.Main.menuViewController.instantiate()
        let sideMenuViewController = RESideMenu(contentViewController:contentViewController,
                                                leftMenuViewController: menuController,
                                                rightMenuViewController: nil)!
        sideMenuViewController.contentViewShadowEnabled = true
        sideMenuViewController.panGestureEnabled = false
        sideMenuViewController.interactivePopGestureRecognizerEnabled = false
        sideMenuViewController.panFromEdge = false
        sideMenuViewController.interactivePopGestureRecognizerEnabled = true
        sideMenuViewController.view.backgroundColor = menuController.view.backgroundColor
        sideMenuViewController.contentViewShadowOffset = CGSize(width: 0, height: 10)
        sideMenuViewController.contentViewShadowOpacity = 0.2
        sideMenuViewController.contentViewShadowRadius = 15

//        sideMenuViewController.contentViewScaleValue = 1
        sideMenuViewController.contentViewInPortraitOffsetCenterX = 100

        sideMenu = sideMenuViewController

        if let view =  self.window.rootViewController?.view {
            UIView.transition(from:view, to: sideMenuViewController.view, duration: 0.24, options: [.transitionCrossDissolve], completion: { _ in
                self.window.rootViewController = sideMenuViewController
            })
        } else {
            self.window.rootViewController = sideMenuViewController
        }
        self.window.makeKeyAndVisible()
    }
}

extension AppCoordinator: HelloCoordinatorDelegate  {

    func userFinishedGreet() {
        var settings = Application.get()
        settings.isAlreadyShownHelloDisplay = true
        Application.set(settings)
        showStartController()
    }

    func userChangedLanguage(_ language: Language) {
        Language.change(language)
    }
}
