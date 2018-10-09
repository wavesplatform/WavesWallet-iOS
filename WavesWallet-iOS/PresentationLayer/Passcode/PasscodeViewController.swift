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

        setupSystem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppeared.onNext(true)
//        eventInput.onNext(.completedInputNumbers([1,1,1,1]))
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
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: PasscodePresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            let applicationWillEnterForeground =  NotificationCenter
                .default
                .rx
                .notification(.UIApplicationWillEnterForeground, object: nil)
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

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback])
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
            }
        }

        if state.isLoading {
            debug("state.isLoading true")
        } else {
            debug("state.isLoading false")
        }
        
        passcodeView.isUserInteractionEnabled = !state.isLoading
        if state.isLoading {
            passcodeView.startLoadingIndicator()
        } else {
            passcodeView.stopLoadingIndicator()
        }
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
