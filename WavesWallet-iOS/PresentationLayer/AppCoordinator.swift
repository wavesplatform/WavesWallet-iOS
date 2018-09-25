//
//  AppCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
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

private enum Display {
    case start
    case hello
    case mainTabBar
    case passcode(DomainLayer.DTO.Wallet)
}

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private var slideMenuViewController: SlideMenu?
    private let window: UIWindow

    private let authoAuthorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let disposeBag: DisposeBag = DisposeBag()

    init(_ window: UIWindow) {
        self.window = window
    }

    func start() {

        authoAuthorizationInteractor
            .lastWalletLoggedIn()
            .flatMap(weak: self, selector: { $0.currentDisplay })
            .subscribe(weak: self, onNext: { $0.showDisplay })
            .disposed(by: disposeBag)
    }

    private func currentDisplay(wallet: DomainLayer.DTO.Wallet?) -> Observable<Display> {

        if let wallet = wallet {
            return currentDisplayForWallet(wallet)
        } else {
            let settings = Application.get()
            if settings.isAlreadyShownHelloDisplay {
                return Observable.just(Display.start)
            } else {
                return Observable.just(Display.hello)
            }
        }
    }

    private func currentDisplayForWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Display> {
        return authoAuthorizationInteractor
            .isAuthorizedWallet(wallet)
            .map { isAuthorizedWallet -> Display in

                if isAuthorizedWallet {
                    return .mainTabBar
                } else {
                    return .passcode(wallet)
                }
            }
    }
}

// MARK: EnterCoordinatorDelegate
extension AppCoordinator: EnterCoordinatorDelegate  {
    func userCompletedLogIn() {
        showDisplay(.mainTabBar)
    }
}

// MARK: HelloCoordinatorDelegate
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

// MARK: PasscodeCoordinatorDelegate
extension AppCoordinator: PasscodeCoordinatorDelegate {

    func userAuthorizationCompleted() {
        showDisplay(.mainTabBar)
    }
}

// MARK: Methods for showing differnt displays
extension AppCoordinator {


    private func showDisplay(_ display: Display) {
        switch display {
        case .hello:
            showHelloDisplay()

        case .start:
            showStartController()

        case .mainTabBar:
            showMainTabBarDisplay()

        case .passcode(let wallet):
            showPasscode(wallet: wallet)
        }
    }

    private func showMainTabBarDisplay() {

        guard let slideMenuViewController = slideMenuViewController else { return }

        let mainTabBarController = MainTabBarCoordinator(slideMenuViewController: slideMenuViewController)
        addChildCoordinator(childCoordinator: mainTabBarController)
        mainTabBarController.start()
    }

    private func showHelloDisplay() {
        let helloCoordinator = HelloCoordinator(window)
        helloCoordinator.delegate = self
        addChildCoordinator(childCoordinator: helloCoordinator)
        helloCoordinator.start()
    }

    private func showStartController() {

        let customNavigationController = CustomNavigationController()
        showSideMenuViewController(contentViewController: customNavigationController)

        let enter = EnterCoordinator(navigationController: customNavigationController)
        enter.delegate = self

        addChildCoordinator(childCoordinator: enter)
        enter.start()
    }

    private func showPasscode(wallet: DomainLayer.DTO.Wallet) {

        let passcodeCoordinator = PasscodeCoordinator(viewController: window.rootViewController!,
                                                      kind: .logIn(wallet))
        passcodeCoordinator.delegate = self


        addChildCoordinator(childCoordinator: passcodeCoordinator)
        passcodeCoordinator.start()
    }

    private func showSideMenuViewController(contentViewController: UIViewController) {

        let menuController = StoryboardScene.Main.menuViewController.instantiate()
        let slideMenuViewController = SlideMenu(contentViewController: contentViewController,
                                                leftMenuViewController: menuController,
                                                rightMenuViewController: nil)!

        self.slideMenuViewController = slideMenuViewController


        if let view =  self.window.rootViewController?.view {
            UIView.transition(from:view, to: slideMenuViewController.view, duration: 0.24, options: [.transitionCrossDissolve], completion: { _ in
                self.window.rootViewController = slideMenuViewController
            })
        } else {
            self.window.rootViewController = slideMenuViewController
        }
        self.window.makeKeyAndVisible()
    }
}
