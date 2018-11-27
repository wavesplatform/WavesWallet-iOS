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

private enum Contants {
    static let delay: TimeInterval = 10
}

struct Application: TSUD {

    struct Settings: Codable, Mutating {
        var isAlreadyShowHelloDisplay: Bool  = false
    }

    private static let key: String = "com.waves.application.settings"

    static var defaultValue: Settings {
        return Settings(isAlreadyShowHelloDisplay: false)
    }

    static var stringKey: String {
        return Application.key
    }
}

protocol ApplicationCoordinatorProtocol: AnyObject {
    func showEnterDisplay()
}

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let window: UIWindow

    private let authoAuthorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let disposeBag: DisposeBag = DisposeBag()
    private var isActiveApp: Bool = false

    init(_ window: UIWindow) {
        self.window = window
        let vc = CustomNavigationController()
        let root = StoryboardScene.LaunchScreen.initialScene.instantiate()
        root.navigationItem.shadowImage = UIImage()
        vc.pushViewController(root, animated: false)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    func start() {
        self.isActiveApp = true

        logInApplication()

        #if DEBUG || TEST
            addTapGestureForSupportDisplay()
        #endif
    }

    private var isMainTabDisplayed: Bool {
        return childCoordinators.first(where: { $0 is MainTabBarCoordinator }) != nil
    }

    private func display(by wallet: DomainLayer.DTO.Wallet?) -> Observable<Display> {

        if let wallet = wallet {
            return display(by: wallet)
        } else {
            let settings = Application.get()
            if settings.isAlreadyShowHelloDisplay {
                return Observable.just(Display.enter)
            } else {
                return Observable.just(Display.hello)
            }
        }
    }

    private func display(by wallet: DomainLayer.DTO.Wallet) -> Observable<Display> {
        return authoAuthorizationInteractor
            .isAuthorizedWallet(wallet)
            .map { isAuthorizedWallet -> Display in
                if isAuthorizedWallet {
                    return Display.slide(wallet)
                } else {
                    return Display.passcode(wallet)
                }
            }
    }

    private func logInApplication() {
        authoAuthorizationInteractor
            .lastWalletLoggedIn()
            .take(1)
            .catchError { _ -> Observable<DomainLayer.DTO.Wallet?> in
                return Observable.just(nil)
            }
            .flatMap(weak: self, selector: { $0.display })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(weak: self, onNext: { $0.showDisplay })
            .disposed(by: disposeBag)
    }

    private func revokeAuthAndOpenPasscode() {

        Observable
            .just(1)
            .delay(Contants.delay, scheduler: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ -> Observable<DomainLayer.DTO.Wallet?> in
                
                guard let owner = self else { return Observable.never() }

                if owner.isActiveApp == true {
                    return Observable.never()
                }

                return
                    owner
                        .authoAuthorizationInteractor
                        .revokeAuth()
                        .flatMap({ [weak self] (_) -> Observable<DomainLayer.DTO.Wallet?> in
                            guard let owner = self else { return Observable.never() }

                            return owner.authoAuthorizationInteractor
                                    .lastWalletLoggedIn()
                                    .take(1)
                        })
            }
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(weak: self, onNext: { owner, wallet in
                if let wallet = wallet {
                    owner.showDisplay(.passcode(wallet))
                } else {
                    owner.showDisplay(.enter)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: HelloCoordinatorDelegate
extension AppCoordinator: HelloCoordinatorDelegate  {

    func userFinishedGreet() {
        var settings = Application.get()
        settings.isAlreadyShowHelloDisplay = true
        Application.set(settings)
        showDisplay(.enter)
    }

    func userChangedLanguage(_ language: Language) {
        Language.change(language)
    }
}

// MARK: PasscodeCoordinatorDelegate
extension AppCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {
        showDisplay(.slide(wallet))
    }

    func passcodeCoordinatorWalletLogouted() {
        showDisplay(.enter)
    }
}

// MARK: Methods for showing differnt displays
extension AppCoordinator: PresentationCoordinator {

    enum Display: Equatable {
        case hello
        case slide(DomainLayer.DTO.Wallet)
        case enter
        case passcode(DomainLayer.DTO.Wallet)
    }

    func showDisplay(_ display: AppCoordinator.Display) {

        switch display {
        case .hello:

            let helloCoordinator = HelloCoordinator(navigationController: window.rootViewController as! UINavigationController)
            helloCoordinator.delegate = self
            addChildCoordinatorAndStart(childCoordinator: helloCoordinator)

        case .passcode(let wallet):

            guard isHasCoordinator(type: PasscodeCoordinator.self) != true else { return }

            let passcodeCoordinator = PasscodeCoordinator(viewController: window.rootViewController!,
                                                          kind: .logIn(wallet))
            passcodeCoordinator.animated = false
            passcodeCoordinator.delegate = self

            addChildCoordinator(childCoordinator: passcodeCoordinator)
            passcodeCoordinator.start()

        case .slide(let wallet):

            guard isHasCoordinator(type: SlideCoordinator.self) != true else { return }

            let slideCoordinator = SlideCoordinator(window: window, wallet: wallet)
            addChildCoordinatorAndStart(childCoordinator: slideCoordinator)

        case .enter:

            let prevSlideCoordinator = self.childCoordinators.first { (coordinator) -> Bool in
                return coordinator is SlideCoordinator
            }

            guard prevSlideCoordinator?.isHasCoordinator(type: EnterCoordinator.self) != true else { return }

            let slideCoordinator = SlideCoordinator(window: window, wallet: nil)
            addChildCoordinatorAndStart(childCoordinator: slideCoordinator)
        }
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

#if DEBUG || TEST

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
    func closeSupportView(isTestNet: Bool) {

        self.window.rootViewController?.dismiss(animated: true, completion: {
            if Environments.isTestNet != isTestNet {

                self.authoAuthorizationInteractor
                    .logout()
                    .subscribe(onCompleted: { [weak self] in
                        Environments.isTestNet = isTestNet
                        self?.showDisplay(.enter)
                    })
                    .disposed(by: self.disposeBag)
            }
        })
    }
}

#endif
