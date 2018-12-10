//
//  NetworkViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxFeedback
import RxCocoa
import RxSwift

final class NetworkSettingsViewController: UIViewController {

    fileprivate typealias Types = NetworkSettingsTypes

    @IBOutlet private weak var spamUrlTextField: InputTextField!

    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var setDefaultButton: UIButton!
    @IBOutlet private weak var spamFilterSwitch: UISwitch!
    @IBOutlet private weak var spamTitleLabel: UILabel!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet private weak var tableView: DynamicHeaderTableView!
    
    private var initialLayoutInsets: UIEdgeInsets?
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    var presenter: NetworkSettingsPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.barTintColor = .white

        saveButton.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        saveButton.setBackgroundImage(UIColor.submit400.image, for: .normal)

        hideTopBarLine()
        setupBigNavigationBar()
        createBackButton()
        setupTextField()
        setupSystem()
        setupLocalizable()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if initialLayoutInsets == nil {
            self.initialLayoutInsets = layoutInsets
            self.tableView.initialLayoutInsets = layoutInsets
        }
    }
}

// MARK: UIScrollViewDelegate
extension NetworkSettingsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

// MARK: Private
extension NetworkSettingsViewController {

    private func setupLocalizable() {
        spamTitleLabel.text = Localizable.Waves.Networksettings.Label.Switchspam.title
        navigationItem.title = Localizable.Waves.Networksettings.Navigation.title
        saveButton.setTitle(Localizable.Waves.Networksettings.Button.Save.title, for: .normal)
        setDefaultButton.setTitle(Localizable.Waves.Networksettings.Button.Setdefault.title, for: .normal)
    }

    private func setupTextField() {

        spamUrlTextField.keyboardType = .URL
        spamUrlTextField.autocapitalizationType = .none
        spamUrlTextField.clearButtonMode = .whileEditing


        spamUrlTextField.update(with: InputTextField.Model(title: Localizable.Waves.Networksettings.Textfield.Spamfilter.title,
                                                            kind: .text,
                                                            placeholder: "http://wavesplatform.com"))

        spamUrlTextField.returnKey = .done

        spamUrlTextField.textFieldShouldReturn = { [weak self] _ in
            self?.spamUrlTextField.endEditing(true)
        }

        spamUrlTextField.changedValue = { [weak self] isValidData, text in
            self?.eventInput.onNext(.inputSpam(text))
        }
    }
}

private extension NetworkSettingsViewController {

    func setupSystem() {

        let uiFeedback: NetworkSettingsPresenter.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), mutations: owner.events())
        }

        let readyViewFeedback: NetworkSettingsPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .rx
                .viewWillAppear
                .asObservable()
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.readyView }
        }

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback])
    }

    func events() -> [Signal<Types.Event>] {

        let input = eventInput.asSignal(onErrorSignalWith: Signal.empty())

        let tapSave = saveButton.rx.tap
            .map { Types.Event.tapSave }
            .asSignal(onErrorSignalWith: Signal.empty())

        let tapSetDeffault = setDefaultButton.rx.tap
            .map { Types.Event.tapSetDeffault }
            .asSignal(onErrorSignalWith: Signal.empty())

        let spamFilterSwitch = self.spamFilterSwitch.rx.value
            .map { Types.Event.switchSpam($0) }
            .asSignal(onErrorSignalWith: Signal.empty())

        return [input, tapSave, tapSetDeffault, spamFilterSwitch]
    }

    func subscriptions(state: Driver<Types.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {

        spamUrlTextField.value = state.spamUrl
        spamUrlTextField.error = state.spamError
        spamFilterSwitch.isOn = state.isSpam
        saveButton.isEnabled = state.isEnabledSaveButton
        setDefaultButton.isEnabled = state.isEnabledSetDeffaultButton

        spamFilterSwitch.isUserInteractionEnabled = state.isEnabledSpamSwitch
        spamUrlTextField.isUserInteractionEnabled = state.isEnabledSpamInput

        if state.isLoading {
            activityIndicatorView.startAnimating()
        } else {
             activityIndicatorView.stopAnimating()
        }

    }
}
