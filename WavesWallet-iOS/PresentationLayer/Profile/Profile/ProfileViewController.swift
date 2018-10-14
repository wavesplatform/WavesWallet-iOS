//
//  ProfileViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxFeedback
import RxSwift
import RxCocoa

private enum Constants {
    static let contentInset = UIEdgeInsetsMake(0, 0, 24, 0)
}

final class ProfileViewController: UIViewController {

    fileprivate typealias Types = ProfileTypes

    @IBOutlet private weak var tableView: UITableView!
    private lazy var logoutItem = UIBarButtonItem(image: Images.topbarLogout.image, style: .plain, target: self, action: #selector(logoutTapped))
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
    }

    @objc func logoutTapped() {
        eventInput.onNext(.tapLogout)
    }

    @objc func changedLanguage() {
        setupLanguages()
        tableView.reloadData()
    }
}

// MARK: Setup Methods

private extension ProfileViewController {

    private func setupLanguages() {
        navigationItem.title = Localizable.Profile.Navigation.title
    }

    private func setupTableview() {
        self.tableView.contentInset = Constants.contentInset
        self.tableView.scrollIndicatorInsets = Constants.contentInset
    }
}

// MARK: RxFeedback

private extension ProfileViewController {

    func setupSystem() {

        let uiFeedback: ProfilePresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: ProfilePresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.rx.viewDidAppear.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewDidAppear }
        }

        let viewDidDisappear: ProfilePresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.rx.viewDidDisappear.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
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

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {

        self.sections = state.sections
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
            cell.update(with: .init(title: Localizable.Profile.Cell.Addresses.title))
            return cell

        case .addressbook:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Profile.Cell.Addressbook.title))
            return cell

        case .pushNotifications:
            let cell: ProfilePushTableCell = tableView.dequeueCell()
            cell.update(with: ())
            return cell

        case .language(let language):
            let cell: ProfileLanguageCell = tableView.dequeueCell()
            cell.update(with: .init(languageIcon: UIImage(named: language.icon) ?? UIImage()))
            return cell

        case .backupPhrase(let isBackedUp):
            let cell: ProfileBackupPhraseCell = tableView.dequeueCell()
            cell.update(with: .init(isBackedUp: isBackedUp))
            return cell

        case .changePassword:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Profile.Cell.Changepassword.title))
            return cell

        case .changePasscode:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Profile.Cell.Changepasscode.title))
            return cell

        case .biometric(let isOn):
            let cell: ProfileBiometricCell = tableView.dequeueCell()
            cell.update(with: .init(isOnBiometric: isOn))
            cell.switchChangedValue = { [weak self] isOn in
                self?.eventInput.onNext(.setEnabledBiometric(isOn))
            }
            return cell

        case .network:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Profile.Cell.Network.title))
            return cell

        case .rateApp:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Profile.Cell.Rateapp.title))
            return cell

        case .feedback:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Profile.Cell.Feedback.title))
            return cell

        case .supportWavesplatform:
            let cell: ProfileValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Profile.Cell.Supportwavesplatform.title))
            return cell
            
        case .info(let version, let height):
            let cell: ProfileInfoCell = tableView.dequeueCell()

            cell.update(with: ProfileInfoCell.Model.init(version: version,
                                                         height: height,
                                                         isLoadingHeight: height == nil))
            cell.deleteButtonDidTap = { [weak self] in
                self?.eventInput.onNext(.tapDelete)
            }
            cell.logoutButtonDidTap = { [weak self] in
                self?.eventInput.onNext(.tapLogout)
            }
            return cell
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
}

// MARK: UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let row = sections[indexPath]
        eventInput.onNext(.tapRow(row))
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProfileHeaderView.viewHeight()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view: ProfileHeaderView = tableView.dequeueAndRegisterHeaderFooter()

        let section = sections[section]

        switch section.kind {
        case .general:
            view.update(with: Localizable.Profile.Header.General.title)

        case .security:
            view.update(with: Localizable.Profile.Header.Security.title)

        case .other:
            view.update(with: Localizable.Profile.Header.Other.title)

        }
       
        return view
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

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

        case .backupPhrase:
            return ProfileBackupPhraseCell.cellHeight()

        case .pushNotifications:
            return ProfilePushTableCell.cellHeight()

        case .language:
            return ProfileLanguageCell.cellHeight()

        case .info:
            return ProfileInfoCell.cellHeight()
        }
    }
}

// MARK: UIScrollViewDelegate

extension ProfileViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
