//
//  LightPasscodeViewController.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

final class PasscodeViewController: UIViewController {

    fileprivate typealias Types = PasscodeTypes

    @IBOutlet private var passcodeView: PasscodeView!
    @IBOutlet private var logInByPasswordButton: UIButton!
    @IBOutlet private var logInByPasswordTitle: UILabel!

    private lazy var backButtonItem: UIBarButtonItem = UIBarButtonItem(image: Images.btnBack.image, style: .plain, target: self, action: #selector(backButtonDidTap))

    private var isAppeared: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    private var disposeBag: DisposeBag = DisposeBag()
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()
    
    var presenter: PasscodePresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = " "
        passcodeView.delegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()

        logInByPasswordButton.setTitle(Localizable.Waves.Passcode.Button.Forgotpasscode.title, for: .normal)
        logInByPasswordTitle.text = Localizable.Waves.Passcode.Label.Forgotpasscode.title

        setupSystem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppeared.onNext(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isAppeared.onNext(false)
    }
    
    @objc private func backButtonDidTap() {
        eventInput.onNext(.tapBack)
    }

    @objc private func logoutButtonDidTap() {
        eventInput.onNext(.tapLogoutButton)
    }

    @IBAction func logInByPasswordDidTap() {
        eventInput.onNext(.tapLogInByPassword)
    }
}

// MARK: RxFeedback

private extension PasscodeViewController {

    func setupSystem() {

        let uiFeedback: PasscodePresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), mutations: owner.events())
        }

        let readyViewFeedback: PasscodePresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            let applicationWillEnterForeground =  NotificationCenter
                .default
                .rx
                .notification(UIApplication.willEnterForegroundNotification, object: nil)
                .flatMap({ [weak self] _ -> Observable<Bool> in
                    guard let strongSelf = self else { return Observable.empty() }
                    let isAppeared = (try? strongSelf.isAppeared.value()) ?? false
                    return Observable.just(isAppeared)
                })
                .ignoreWhen({ $0 == false })
                .sweetDebug("UIApplicationWillEnterForeground")

            return Observable<Bool>.merge([strongSelf.rx.viewDidAppear.asObservable(),
                                           applicationWillEnterForeground])
                .throttle(1, scheduler: MainScheduler.instance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewDidAppear }
        }


        let viewWillAppear: PasscodePresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in Types.Event.viewWillAppear }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback, viewWillAppear])
    }

    func events() -> [Signal<Types.Event>] {
        return [eventInput.asSignal(onErrorSignalWith: Signal.empty())]
    }

    func subscriptions(state: Driver<Types.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {

        passcodeView.update(with: .init(numbers: state.numbers,
                                        text: state.titleLabel,
                                        detail: state.detailLabel))

        if state.isHiddenBackButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem()
        } else {
            navigationItem.leftBarButtonItem = backButtonItem
        }

        if state.isHiddenLogoutButton {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarLogout.image,
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(logoutButtonDidTap))
        }
        
        passcodeView.hiddenButton(by: .biometric, isHidden: state.isHiddenBiometricButton)

        self.logInByPasswordTitle.isHidden = state.isHiddenLogInByPassword
        self.logInByPasswordButton.isHidden = state.isHiddenLogInByPassword

        if let error = state.error {
            switch error {
            case .incorrectPasscode:
                passcodeView.showInvalidateState()

            case .message(let message):
                self.showErrorSnackWithoutAction(title: message)

            case .attemptsEndedLogout:
                showAlertAttemptsEndedAndLogout()

            case .attemptsEnded:
                showAlertAttemptsEnded()

            case .internetNotWorking:
                self.showWithoutInternetSnackWithoutAction()

            case .notFound:
                self.showErrorNotFoundSnackWithoutAction()

            case .none:
                break
            }
        }

        passcodeView.isUserInteractionEnabled = !state.isLoading
        if state.isLoading {
            passcodeView.startLoadingIndicator()
        } else {
            passcodeView.stopLoadingIndicator()
        }
    }

    private func showAlertAttemptsEnded() {

        let alert = UIAlertController(title: Localizable.Waves.Passcode.Alert.Attempsended.title,
                                      message: Localizable.Waves.Passcode.Alert.Attempsended.subtitle, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: Localizable.Waves.Passcode.Alert.Attempsended.Button.cancel,
                                      style: UIAlertAction.Style.cancel,
                                      handler: { [weak self] (UIAlertAction) in
            self?.eventInput.onNext(.tapLogoutButton)
        }))

        alert.addAction(UIAlertAction(title: Localizable.Waves.Passcode.Alert.Attempsended.Button.enterpassword,
                                      style: UIAlertAction.Style.default,
                                      handler: { [weak self] (UIAlertAction) in
            self?.eventInput.onNext(.tapLogInByPassword)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func showAlertAttemptsEndedAndLogout() {

        let alert = UIAlertController(title: Localizable.Waves.Passcode.Alert.Attempsended.title,
                                      message: Localizable.Waves.Passcode.Alert.Attempsended.subtitle, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: Localizable.Waves.Passcode.Alert.Attempsended.Button.ok,
                                      style: UIAlertAction.Style.cancel,
                                      handler: { [weak self] (UIAlertAction) in
            self?.eventInput.onNext(.tapLogoutButton)
        }))

        self.present(alert, animated: true, completion: nil)

    }
}

extension PasscodeViewController: PasscodeViewDelegate {

    func completedInput(with numbers: [Int]) {
        eventInput.onNext(.completedInputNumbers(numbers))
    }

    func biometricButtonDidTap() {
        eventInput.onNext(.tapBiometricButton)        
    }
}
