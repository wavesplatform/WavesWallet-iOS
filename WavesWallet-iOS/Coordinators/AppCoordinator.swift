//
//  AppCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RESideMenu
import RxOptional
import RxSwift
import UIKit
import WavesSDK
import WavesSDKExtensions
import Intercom

private enum Contants {
    #if DEBUG
        static let delay: TimeInterval = 1
    #else
        static let delay: TimeInterval = 10
    #endif
}

struct Application: TSUD {
    struct Settings: Codable, Mutating {
        var isAlreadyShowHelloDisplay = false
        var isAlreadyShowMigrationWavesExchangeDisplay = false
        // был опциональный буль, вроде нигде не заниляется. обратить внимание!!!
    }

    private static let key: String = "com.waves.application.settings"

    static let defaultValue = Settings(isAlreadyShowHelloDisplay: false, isAlreadyShowMigrationWavesExchangeDisplay: false)
    
    static let stringKey = Application.key
}

protocol ApplicationCoordinatorProtocol: AnyObject {
    func showEnterDisplay()
}

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let windowRouter: WindowRouter

    private let authoAuthorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let mobileKeeperRepository: MobileKeeperRepositoryProtocol = UseCasesFactory.instance.repositories.mobileKeeperRepository
    private let applicationVersionUseCase: ApplicationVersionUseCaseProtocol = UseCasesFactory.instance.applicationVersionUseCase

    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol = UseCasesFactory.instance.repositories.developmentConfigsRepository

    private let disposeBag = DisposeBag()
    private var deepLink: DeepLink?
    private var isActiveApp = false
    private var snackError: String?

    // TODO: It is very bad code
    private var isLockChangeDisplay: Bool = false

    #if DEBUG || TEST
        init(_ debugWindowRouter: DebugWindowRouter, deepLink: DeepLink?) {
            self.windowRouter = debugWindowRouter
            debugWindowRouter.delegate = self
            self.deepLink = deepLink
        }

    #else
        init(_ windowRouter: WindowRouter, deepLink: DeepLink?) {
            self.windowRouter = windowRouter
            self.deepLink = deepLink
        }
    #endif

    func start() {
        isActiveApp = true

        launchApplication()

        if let deepLink = deepLink {
            openURL(link: deepLink)
        }

        checkAndRunForceUpdate()

        checkAndRunServerMaintenance()
    }

    private func launchApplication() {
        removeCoordinators()
        isLockChangeDisplay = false

        #if DEBUG || TEST
            if CommandLine.arguments.contains("UI-Develop") {
                addChildCoordinatorAndStart(childCoordinator: UIDeveloperCoordinator(windowRouter: windowRouter))
            } else {
                logInApplication()
            }
        #else
            logInApplication()
        #endif
    }

    private var isMainTabDisplayed: Bool { childCoordinators.first(where: { $0 is MainTabBarCoordinator }) != nil }
}

// MARK: Methods for showing differnt displays

extension AppCoordinator: PresentationCoordinator {
    enum Display {
        case hello(_ isNewUser: Bool)
        case slide(DomainLayer.DTO.Wallet)
        case enter
        case passcode(DomainLayer.DTO.Wallet)
        case widgetSettings
        case mobileKeeper(DomainLayer.DTO.MobileKeeper.Request)
        case send(DeepLink)
        case dex(DeepLink)
        case forceUpdate(DomainLayer.DTO.VersionUpdateData)
        case maintenanceServer

        var isForceUpdateDisplay: Bool {
            switch self {
            case .forceUpdate:
                return true
            default:
                return false
            }
        }
    }

    func showDisplay(_ display: AppCoordinator.Display) {
        // TODO: Надо бы переделать это. так как это метод недолжен отвечать за логику
        if display.isForceUpdateDisplay {
            isLockChangeDisplay = false
        }

        guard isLockChangeDisplay == false else { return }

        switch display {
        case .hello(let isNewUser):

            let helloCoordinator = HelloCoordinator(windowRouter: windowRouter, isNewUser: isNewUser)
            helloCoordinator.delegate = self
            addChildCoordinatorAndStart(childCoordinator: helloCoordinator)

        case .passcode(let wallet):

            guard isHasCoordinator(type: PasscodeLogInCoordinator.self) != true else { return }

            let passcodeCoordinator = PasscodeLogInCoordinator(wallet: wallet, routerKind: .alertWindow)
            passcodeCoordinator.delegate = self

            addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)

        case .slide(let wallet):

            guard isHasCoordinator(type: SlideCoordinator.self) != true else {
                showDeepLinkVcIfNeed()
                return
            }

            let slideCoordinator = SlideCoordinator(windowRouter: windowRouter, wallet: wallet)
            slideCoordinator.menuViewControllerDelegate = self
            addChildCoordinatorAndStart(childCoordinator: slideCoordinator)
            showDeepLinkVcIfNeed()

        case .enter:

            let prevSlideCoordinator = childCoordinators.first { (coordinator) -> Bool in
                coordinator is SlideCoordinator
            }

            guard prevSlideCoordinator?.isHasCoordinator(type: EnterCoordinator.self) != true else { return }

            let slideCoordinator = SlideCoordinator(windowRouter: windowRouter, wallet: nil)
            slideCoordinator.menuViewControllerDelegate = self
            addChildCoordinatorAndStart(childCoordinator: slideCoordinator)

        case .widgetSettings:

            guard isHasCoordinator(type: WidgetSettingsCoordinator.self) != true else {
                return
            }

            let coordinator = WidgetSettingsCoordinator(windowRouter: windowRouter)
            addChildCoordinatorAndStart(childCoordinator: coordinator)

        case .mobileKeeper(let request):
            let coordinator = MobileKeeperCoordinator(windowRouter: windowRouter, request: request)
            addChildCoordinatorAndStart(childCoordinator: coordinator)

        case .send(let link):

            deepLink = link

        case .dex(let link):

            deepLink = link

        case .forceUpdate(let data):

            isLockChangeDisplay = true

            // TODO: add coordinator
            let vc = StoryboardScene.ForceUpdateApp.forceUpdateAppViewController.instantiate()
            vc.data = data
            windowRouter.window.rootViewController = vc
            windowRouter.window.makeKeyAndVisible()

        case .maintenanceServer:

            isLockChangeDisplay = true
            // TODO: add coordinator
            let vc = StoryboardScene.ServerMaintenance.serverMaintenanceViewController.instantiate()
            vc.delegate = self
            let navigation = CustomNavigationController(rootViewController: vc)

            windowRouter.window.rootViewController = navigation
            windowRouter.window.makeKeyAndVisible()
        }
    }

    func openURL(link: DeepLink) {
        guard isLockChangeDisplay == false else { return }

        if link.url.absoluteString == DeepLink.widgetSettings {
            showDisplay(.widgetSettings)
        } else if link.isClientSendLink {
            showDisplay(.send(link))
        } else if link.isClientDexLink {
            showDisplay(.dex(link))
        } else if link.isMobileKeeper {
            mobileKeeperRepository
                .decodableRequest(link.url)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { request in
                    guard let request = request else { return }
                    self.showDisplay(.mobileKeeper(request))
                }, onError: { [weak self] error in

                    if let error = error as? MobileKeeperUseCaseError {
                        self?.showErrorView(with: error)
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    // TODO: Localization
    private func showErrorView(with error: MobileKeeperUseCaseError) {
        if let snackError = snackError {
            UIApplication.shared.windows.last?.rootViewController?.hideSnack(key: snackError)
        }

        switch error {
        case .dAppDontOpen:
            snackError = showErrorSnack("Application don't open")

        case .dataIncorrect:
            snackError = showErrorSnack("Request incorect")

        case .transactionDontSupport:
            snackError = showErrorSnack("Transaction don't support")
        default:
            snackError = UIApplication.shared.windows.last?.rootViewController?.showErrorNotFoundSnackWithoutAction()
        }
    }

    private func showErrorSnack(_ message: String) -> String? {
        return UIApplication.shared.windows.last?.rootViewController?.showErrorSnackWithoutAction(title: message)
    }
}

// MARK: Main Logic

extension AppCoordinator {
    private func showDeepLinkVcIfNeed() {
        if let link = deepLink, link.isClientSendLink {
            guard isHasCoordinator(type: SendCoordinator.self) != true else {
                return
            }
            let coordinator = SendCoordinator(windowRouter: windowRouter, deepLink: link)
            addChildCoordinatorAndStart(childCoordinator: coordinator)
        } else if let link = deepLink, link.isClientDexLink {
            guard isHasCoordinator(type: DexDeepLinkCoordinator.self) != true else {
                return
            }
            let coordinator = DexDeepLinkCoordinator(windowRouter: windowRouter, deepLink: link)
            addChildCoordinatorAndStart(childCoordinator: coordinator)
        }
    }

    private func display(by wallet: DomainLayer.DTO.Wallet?) -> Observable<Display> {
        let settings = Application.get()

        if let wallet = wallet {
            if settings.isAlreadyShowMigrationWavesExchangeDisplay ?? false {
                return display(by: wallet)
            } else {
                return Observable.just(Display.hello(false))
            }
        } else {
            if settings.isAlreadyShowHelloDisplay {
                if settings.isAlreadyShowMigrationWavesExchangeDisplay ?? false {
                    return Observable.just(Display.enter)
                } else {
                    return Observable.just(Display.hello(false))
                }
            } else {
                return Observable.just(Display.hello(true))
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
                Observable.just(nil)
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self, selector: { $0.display })
            .subscribe(weak: self, onNext: { $0.showDisplay })
            .disposed(by: disposeBag)
    }

    private func revokeAuthAndOpenPasscode() {
        Observable<TimeInterval>
            .just(1)
            .delay(Contants.delay, scheduler: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ -> Observable<DomainLayer.DTO.Wallet?> in

                guard let self = self else { return Observable.never() }

                if self.isActiveApp == true {
                    return Observable.never()
                }

                return
                    self
                        .authoAuthorizationInteractor
                        .revokeAuth()
                        .flatMap { [weak self] (_) -> Observable<DomainLayer.DTO.Wallet?> in
                            guard let self = self else { return Observable.never() }

                            return self.authoAuthorizationInteractor
                                .lastWalletLoggedIn()
                                .take(1)
                        }
            }
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .flatMap { [weak self] wallet -> Observable<Display> in
                guard let self = self else { return Observable.never() }
                return self.display(by: wallet)
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] display in
                guard let self = self else { return }
                self.showDisplay(display)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: HelloCoordinatorDelegate

extension AppCoordinator: HelloCoordinatorDelegate {
    func userFinishedGreet() {
        var settings = Application.get()

        if settings.isAlreadyShowHelloDisplay {
            settings.isAlreadyShowMigrationWavesExchangeDisplay = true
        } else {
            settings.isAlreadyShowHelloDisplay = true
            settings.isAlreadyShowMigrationWavesExchangeDisplay = true
        }

        Application.set(settings)

        launchApplication()
    }

    func userChangedLanguage(_ language: Language) {
        Language.change(language)
    }
}

// MARK: PasscodeLogInCoordinatorDelegate

extension AppCoordinator: PasscodeLogInCoordinatorDelegate {
    func passcodeCoordinatorLogInCompleted(wallet: DomainLayer.DTO.Wallet) {
        showDisplay(.slide(wallet))
    }

    func passcodeCoordinatorWalletLogouted() {
        showDisplay(.enter)
        deepLink = nil
    }
}

// MARK: Lifecycle application

extension AppCoordinator {
    func applicationDidEnterBackground() {
        isActiveApp = false
        deepLink = nil
        revokeAuthAndOpenPasscode()
    }

    func applicationDidBecomeActive() {
        if isActiveApp {
            return
        }
        isActiveApp = true
    }
}

// MARK: ServerMaintenanceViewControllerDelegate

extension AppCoordinator: ServerMaintenanceViewControllerDelegate {
    func serverMaintenanceDisabled() {
        launchApplication()
    }
}

// MARK: DebugWindowRouterDelegate

extension AppCoordinator: DebugWindowRouterDelegate {
    func relaunchApplication() {
        authoAuthorizationInteractor
            .logout()
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                
                Intercom.logout()
                self.showDisplay(.enter)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: MenuViewControllerDelegate

extension AppCoordinator: MenuViewControllerDelegate {
    func menuViewControllerDidTapWavesLogo() {
        let vc = StoryboardScene.Support.debugViewController.instantiate()
        vc.delegate = self
        let nv = CustomNavigationController()
        nv.viewControllers = [vc]
        nv.modalPresentationStyle = .fullScreen
        windowRouter.window.rootViewController?.present(nv, animated: true, completion: nil)
    }
}

// MARK: DebugViewControllerDelegate

extension AppCoordinator: DebugViewControllerDelegate {
    func dissmissDebugVC(isNeedRelaunchApp: Bool) {
        if isNeedRelaunchApp {
            relaunchApplication()
        }

        windowRouter.window.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ServerMaintenance

private extension AppCoordinator {
    func checkAndRunServerMaintenance() {
        developmentConfigsRepository
            .isEnabledMaintenance()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabledMaintenance in
                guard let self = self else { return }

                if isEnabledMaintenance {
                    self.showDisplay(.maintenanceServer)
                }
            })
            .disposed(by: disposeBag)

        NotificationCenter.default
            .rx.notification(UIApplication.willEnterForegroundNotification, object: nil)
            .flatMap { [weak self] (_) -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                return self.developmentConfigsRepository
                    .isEnabledMaintenance()
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabledMaintenance in
                guard let self = self else { return }
                if isEnabledMaintenance {
                    self.showDisplay(.maintenanceServer)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ForceUpdate

private extension AppCoordinator {
    func checkAndRunForceUpdate() {
        applicationVersionUseCase
            .isNeedForceUpdate()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }

                if data.isNeedForceUpdate {
                    self.showDisplay(.forceUpdate(data))
                }
            }).disposed(by: disposeBag)
    }
}
