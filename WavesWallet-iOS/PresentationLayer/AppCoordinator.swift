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
import RxOptional

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
    case start(withHelloDisplay: Bool)
    case mainTabBar
    case enter
    case mainWithPasscode(DomainLayer.DTO.Wallet)
    case passcode(DomainLayer.DTO.Wallet)
}

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private var slideMenuViewController: SlideMenu = {

        let menuController = StoryboardScene.Main.menuViewController.instantiate()
        let slideMenuViewController = SlideMenu(contentViewController: UIViewController(),
                                                leftMenuViewController: menuController,
                                                rightMenuViewController: nil)!
        return slideMenuViewController
    }()

    private let window: UIWindow

    private let authoAuthorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let disposeBag: DisposeBag = DisposeBag()
    private var isActiveApp: Bool = false
    private var needShowMainDisplayAfterAuth: Bool = false

    init(_ window: UIWindow) {
        self.window = window
    }

    func start() {
        self.isActiveApp = true
        self.window.rootViewController = slideMenuViewController
        self.window.makeKeyAndVisible()
        logInApplication()

        #if DEBUG
            addTapGestureForSupportDisplay()
        #endif
    }

    private var isMainTabDisplayed: Bool {
        return childCoordinators.first(where: { $0 is MainTabBarCoordinator }) != nil
    }

    private func currentDisplay(wallet: DomainLayer.DTO.Wallet?) -> Observable<Display> {

        if let wallet = wallet {
            return currentDisplayForWallet(wallet)
        } else {
            let settings = Application.get()
            if settings.isAlreadyShownHelloDisplay {
                return Observable.just(Display.start(withHelloDisplay: false))
            } else {
                return Observable.just(Display.start(withHelloDisplay: true))
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
                    return .mainWithPasscode(wallet)
                }
            }
    }

    private func logInApplication() {
        authoAuthorizationInteractor
            .lastWalletLoggedIn()
            .take(1)
            .flatMap(weak: self, selector: { $0.currentDisplay })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(weak: self, onNext: { $0.showDisplay })
            .disposed(by: disposeBag)
    }

    private func revokeAuthAndOpenPasscode() {
        authoAuthorizationInteractor
            .revokeAuth()
            .flatMap { [weak self] _ -> Observable<DomainLayer.DTO.Wallet> in

                guard let owner = self else { return Observable.never() }

                return owner.authoAuthorizationInteractor
                    .lastWalletLoggedIn()
                    .take(1)
                    .errorOnNil()
            }
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(weak: self, onNext: { $0.showPasscode(wallet: $1) })
            .disposed(by: disposeBag)
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

    func userLogouted() {
        showDisplay(.enter)
    }
}

// MARK: Methods for showing differnt displays
extension AppCoordinator {


    private func showDisplay(_ display: Display) {

        switch display {
        case .start(let withHelloDisplay):
            showStartController(withHelloDisplay: withHelloDisplay)

        case .mainTabBar:
            showMainTabBarDisplay()

        case .passcode(let wallet):
            showPasscode(wallet: wallet)

        case .mainWithPasscode(let wallet):
            showPasscode(wallet: wallet, animated: false)

        case .enter:
            showEnter()
        }
    }

    private func showMainTabBarDisplay() {

        if isMainTabDisplayed {
            return
        }

        let mainTabBarController = MainTabBarCoordinator(slideMenuViewController: slideMenuViewController)
        addChildCoordinator(childCoordinator: mainTabBarController)
        mainTabBarController.start()
    }

    private func showStartController(withHelloDisplay: Bool) {

        if withHelloDisplay {
            let helloCoordinator = HelloCoordinator(viewController: slideMenuViewController, presentCompletion: {
                self.showEnter()
            })

            helloCoordinator.delegate = self
            addChildCoordinator(childCoordinator: helloCoordinator)
            helloCoordinator.start()
        } else {
            showEnter()
        }
    }

    private func showEnter() {

        //TODO: Нужно придумать другой способ
        let mainTabBarCoordinator = childCoordinators.first(where: { $0 is MainTabBarCoordinator })
        mainTabBarCoordinator?.removeFromParentCoordinator()

        let customNavigationController = CustomNavigationController()

        let enter = EnterCoordinator(navigationController: customNavigationController)
        enter.delegate = self
        addChildCoordinator(childCoordinator: enter)
        enter.start()
        slideMenuViewController.contentViewController = customNavigationController
    }

    private func showPasscode(wallet: DomainLayer.DTO.Wallet, animated: Bool = true) {

        //TODO: Нужно придумать другой способ
        if childCoordinators.first(where: { $0 is PasscodeCoordinator }) != nil {
            return
        }

        let passcodeCoordinator = PasscodeCoordinator(viewController: window.rootViewController!,
                                                      kind: .logIn(wallet))
        passcodeCoordinator.animated = animated
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

// MARK: Lifecycle application
extension AppCoordinator {

    func applicationDidEnterBackground() {
        self.isActiveApp = false

        revokeAuthAndOpenPasscode()
    }

    func applicationDidBecomeActive() {
        if isActiveApp {
            return
        }
        isActiveApp = true
    }
}


#if DEBUG

// MARK: Support
extension AppCoordinator {

    func addTapGestureForSupportDisplay() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(tap:)))
        tapGesture.numberOfTouchesRequired = 2
        tapGesture.numberOfTapsRequired = 2
        self.window.addGestureRecognizer(tapGesture)
    }

    @objc func tapGesture(tap: UITapGestureRecognizer) {
        let vc = StoryboardScene.Support.supportViewController.instantiate()
        vc.delegate = self
        self.window.rootViewController!.present(vc, animated: true, completion: nil)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: SupportViewControllerDelegate
extension AppCoordinator: SupportViewControllerDelegate  {
    func closeSupportView() {

        self.window.rootViewController?.dismiss(animated: true, completion: {
            self.logInApplication()
        })
    }
}

#endif
