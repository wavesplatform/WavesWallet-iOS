//
//  ProfileViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import RxCocoa
import RxFeedback
import RxSwift
import UIKit

private enum Constants {
    static let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
}

final class ProfileViewController: UIViewController {
    fileprivate typealias Types = ProfileTypes

    @IBOutlet private var tableView: UITableView!
    private lazy var logoutItem = UIBarButtonItem(image: Images.topbarLogout.image, style: .plain, target: self,
                                                  action: #selector(logoutTapped))
    private var sections: [Types.ViewModel.Section] = [Types.ViewModel.Section]()

    var presenter: ProfilePresenterProtocol!
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()

        createMenuButton()
        setupBigNavigationBar()
        setupSystem()
        setupLanguages()
        setupTableview()
        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification,
                         object: nil)
    }

    @objc private func logoutTapped() {
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.profile(.profileLogoutUp))

        eventInput.onNext(.tapLogout)
    }

    @objc private func changedLanguage() {
        setupLanguages()
        tableView.reloadData()
    }

    @objc private func appDidBecomeActive() {
        eventInput.onNext(.updatePushNotificationsSettings)
    }
}

// MARK: - MainTabBarControllerProtocol

extension ProfileViewController: MainTabBarControllerProtocol {
    func mainTabBarControllerDidTapTab() {
        guard isViewLoaded else { return }
        tableView.setContentOffset(tableViewTopOffsetForBigNavBar(tableView), animated: true)
    }
}

// MARK: Setup Methods

private extension ProfileViewController {
    private func setupLanguages() {
        navigationItem.title = Localizable.Waves.Profile.Navigation.title
    }

    private func setupTableview() {
        tableView.contentInset = Constants.contentInset
        tableView.scrollIndicatorInsets = Constants.contentInset
    }
}

// MARK: RxFeedback

private extension ProfileViewController {
    func setupSystem() {
        let uiFeedback: ProfilePresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: ProfilePresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }

            return self.rx.viewDidAppear.asObservable()
                .throttle(1, scheduler: MainScheduler.asyncInstance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewDidAppear }
        }

        let viewDidDisappear: ProfilePresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }

            return self.rx.viewDidDisappear.asObservable()
                .throttle(1, scheduler: MainScheduler.asyncInstance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewDidDisappear }
        }

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback, viewDidDisappear])
    }

    func events() -> [Signal<Types.Event>] {
        return [eventInput.asSignal(onErrorSignalWith: Signal.empty())]
    }

    func subscriptions(state: Driver<Types.State>) -> [Disposable] {
        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let self = self else { return }

            self.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {
        sections = state.sections
        if let action = state.action {
            switch action {
            case .update:
                navigationItem.rightBarButtonItem = logoutItem
                tableView.reloadData()
            case .none:
                break
            }
        }
    }
}

// MARK: UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath]

        switch row {
        case .addressesKeys:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Profile.Cell.Addresses.title))
            return cell

        case .addressbook:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Profile.Cell.Addressbook.title))
            return cell

        case let .pushNotifications(isActive):
            let cell: ProfileBackupPhraseCell = tableView.dequeueCell()
            cell.update(with: .init(isBackedUp: isActive, title: Localizable.Waves.Profile.Cell.Pushnotifications.title))
            return cell

        case let .language(language):
            let cell: ProfileLanguageCell = tableView.dequeueCell()
            cell.update(with: .init(languageIcon: UIImage(named: language.icon) ?? UIImage()))
            return cell

        case let .backupPhrase(isBackedUp):
            let cell: ProfileBackupPhraseCell = tableView.dequeueCell()
            cell.update(with: .init(isBackedUp: isBackedUp, title: Localizable.Waves.Profile.Cell.Backupphrase.title))
            return cell

        case .changePassword:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Profile.Cell.Changepassword.title))
            return cell

        case .changePasscode:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Profile.Cell.Changepasscode.title))
            return cell

        case .biometricDisabled:
            let cell: ProfileDisabledButtomTableCell = tableView.dequeueCell()
            cell.update(with: BiometricType.biometricByDevice.title ?? "")
            return cell

        case let .biometric(isOn):
            let cell: ProfileBiometricCell = tableView.dequeueCell()
            cell.update(with: .init(isOnBiometric: isOn))
            cell.switchChangedValue = { [weak self] isOn in
                self?.eventInput.onNext(.setEnabledBiometric(isOn))
            }
            return cell

        case .network:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Profile.Cell.Network.title))
            return cell

        case .rateApp:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Profile.Cell.Rateapp.title))
            return cell

        case .feedback:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Profile.Cell.Feedback.title))
            return cell

        case .supportWavesplatform:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Profile.Cell.Supportwavesplatform.title))
            return cell

        case let .info(version, height, isBackedUp):
            let cell: ProfileInfoCell = tableView.dequeueCell()

            cell.update(with: ProfileInfoCell.Model(version: version,
                                                    height: height,
                                                    isLoadingHeight: height == nil))
            cell.deleteButtonDidTap = { [weak self] in
                if isBackedUp {
                    self?.showAlertDeleteAccount()
                } else {
                    self?.showAlertDeleteAccountWithNeedBackup()
                }
            }
            cell.logoutButtonDidTap = { [weak self] in

                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.profile(.profileLogoutDown))

                self?.eventInput.onNext(.tapLogout)
            }
            return cell
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }
}

// MARK: UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath]
        eventInput.onNext(.tapRow(row))
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return ProfileHeaderView.viewHeight()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: ProfileHeaderView = tableView.dequeueAndRegisterHeaderFooter()

        let section = sections[section]

        switch section.kind {
        case .general:
            view.update(with: Localizable.Waves.Profile.Header.General.title)

        case .security:
            view.update(with: Localizable.Waves.Profile.Header.Security.title)

        case .other:
            view.update(with: Localizable.Waves.Profile.Header.Other.title)
        }

        return view
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath]

        switch row {
        case .addressesKeys,
             .addressbook,
             .changePassword,
             .changePasscode,
             .biometric,
             .network,
             .rateApp,
             .feedback,
             .supportWavesplatform:
            return ProfileValueCell.cellHeight()

        case .backupPhrase, .pushNotifications:
            return ProfileBackupPhraseCell.cellHeight()

        case .biometricDisabled:
            return ProfileDisabledButtomTableCell.cellHeight()

        case .language:
            return ProfileLanguageCell.cellHeight()

        case .info:
            return ProfileInfoCell.cellHeight()
        }
    }
}

// MARK: UIScrollViewDelegate

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_: UIScrollView) {
        setupTopBarLine()
    }
}

// MARK: Private

private extension ProfileViewController {
    func showAlertDeleteAccountWithNeedBackup() {
        let vc = StoryboardScene.Profile.alertDeleteAccountViewController.instantiate()
        vc.deleteBlock = { [weak self] in
            self?.eventInput.onNext(.tapDelete)
        }
        vc.showInController(self)
    }

    func showAlertDeleteAccount() {
        let alert = UIAlertController(title: Localizable.Waves.Profile.Alert.Deleteaccount.title,
                                      message: Localizable.Waves.Profile.Alert.Deleteaccount.Withoutbackup.message,
                                      preferredStyle: .alert)

        let delete = UIAlertAction(title: Localizable.Waves.Profile.Alert.Deleteaccount.Button.delete,
                                   style: UIAlertAction.Style.default,
                                   handler: { [weak self] _ in
                                       self?.eventInput.onNext(.tapDelete)
        })

        let cancel = UIAlertAction(title: Localizable.Waves.Profile.Alert.Deleteaccount.Button.cancel,
                                   style: UIAlertAction.Style.cancel,
                                   handler: { [weak alert] _ in
                                       alert?.dismiss(animated: true, completion: nil)
        })

        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
