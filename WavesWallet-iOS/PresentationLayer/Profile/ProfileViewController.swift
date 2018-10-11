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
    private let logoutItem = UIBarButtonItem(image: Images.topbarLogout.image, style: .plain, target: self, action: #selector(logoutTapped))
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
    }

    @objc func logoutTapped() {
        eventInput.onNext(.tapLogout)
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
//@objc func logoutTapped() {
//
//    let enter = StoryboardManager.EnterStoryboard().instantiateViewController(withIdentifier: "EnterStartViewController") as! EnterStartViewController
//    let nav = UINavigationController(rootViewController: enter)
//    AppDelegate.shared().menuController.setContentViewController(nav, animated: true)
//}
//
//@objc func deleteAccountTapped() {
//
//    let hasSeed = false
//
//    if hasSeed {
//        let controller = storyboard?.instantiateViewController(withIdentifier: "DeleteAccountViewController") as! DeleteAccountViewController
//
//        controller.showInController(rdv_tabBarController)
//    }
//    else {
//        let controller = UIAlertController(title: "Delete account", message: "Are you sure you want to delete this account from device?", preferredStyle: .alert)
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let delete = UIAlertAction(title: "Delete", style: .default) { (action) in
//
//        }
//        controller.addAction(cancel)
//        controller.addAction(delete)
//        present(controller, animated: true, completion: nil)
//}

//MARK: - UITableView

//func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    if indexPath.section == ProfileSection.general.rawValue {
//
//        if indexPath.row == GeneralSection.addressesAndKeys.rawValue {
//
//            setupLastScrollCorrectOffset()
//            let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileAddressKeyViewController") as! ProfileAddressKeyViewController
//            navigationController?.pushViewController(controller, animated: true)
//            rdv_tabBarController.setTabBarHidden(true, animated: true)
//        }
//        else if indexPath.row == GeneralSection.addressBook.rawValue {
//
//            setupLastScrollCorrectOffset()
//
//            let controller = AddressBookModuleBuilder(output: nil).build(input: .init(isEditMode: true))
//            navigationController?.pushViewController(controller, animated: true)
//            rdv_tabBarController.setTabBarHidden(true, animated: true)
//        }
//        else if indexPath.row == GeneralSection.language.rawValue {
//
//            setupLastScrollCorrectOffset()
//            let controller = storyboard?.instantiateViewController(withIdentifier: "LanguageViewController") as! LanguageViewController
//            navigationController?.pushViewController(controller, animated: true)
//            rdv_tabBarController.setTabBarHidden(true, animated: true)
//        }
//    }
//    else if indexPath.section == ProfileSection.security.rawValue {
//
//        if indexPath.row == SecuritySection.changePassword.rawValue {
//
//            setupLastScrollCorrectOffset()
//            let controller = storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
//            navigationController?.pushViewController(controller, animated: true)
//            rdv_tabBarController.setTabBarHidden(true, animated: true)
//        }
//        else if indexPath.row == SecuritySection.changePasscode.rawValue {
//
//            setupLastScrollCorrectOffset()
//            let controller = storyboard?.instantiateViewController(withIdentifier: "PasscodeViewController") as! PasscodeViewController
//            navigationController?.pushViewController(controller, animated: true)
//            rdv_tabBarController.setTabBarHidden(true, animated: true)
//        }
//        else if indexPath.row == SecuritySection.network.rawValue {
//
//            setupLastScrollCorrectOffset()
//            let controller = storyboard?.instantiateViewController(withIdentifier: "NetworkViewController") as! NetworkViewController
//            navigationController?.pushViewController(controller, animated: true)
//            rdv_tabBarController.setTabBarHidden(true, animated: true)
//        }
//    }
//}
//
//func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//    if let offset = lastScrollCorrectOffset, Platform.isIphoneX {
//        scrollView.contentOffset = offset // to fix top bar offset in iPhoneX when tabBarHidden = true
//    }
//    setupTopBarLine()
//}
//
//func numberOfSections(in tableView: UITableView) -> Int {
//    return 3
//}
//
//func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//    return WalletHeaderView.viewHeight()
//}
//
//func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    let view: WalletHeaderView = tableView.dequeueAndRegisterHeaderFooter()
//
//    view.labelTitle.textColor = .disabled500
//    view.iconArrow.isHidden = true
//
//    if section == ProfileSection.general.rawValue {
//        view.labelTitle.text = "General settings"
//    }
//    else if section == ProfileSection.security.rawValue {
//        view.labelTitle.text = "Security"
//    }
//    else if section == ProfileSection.other.rawValue {
//        view.labelTitle.text = "Other"
//    }
//
//    return view
//}
//
//func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//    if indexPath.section == ProfileSection.general.rawValue {
//        if indexPath.row == generalNames.count - 1 {
//            return ProfileTableCell.cellHeight() + 10
//        }
//    }
//    else if indexPath.section == ProfileSection.security.rawValue {
//        if indexPath.row == securityNames.count - 1 {
//            return ProfileTableCell.cellHeight() + 10
//        }
//    }
//    else if indexPath.section == ProfileSection.other.rawValue {
//        if indexPath.row == OtherSection.bottomRow.rawValue {
//            return ProfileBottomCell.cellHeight()
//        }
//    }
//
//    return ProfileTableCell.cellHeight()
//}
//
//func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//    if section == ProfileSection.general.rawValue {
//        return generalNames.count
//    }
//    else if section == ProfileSection.security.rawValue {
//        return securityNames.count
//    }
//    else if section == ProfileSection.other.rawValue {
//        return otherNames.count
//    }
//    return 0
//}
//
//func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    if indexPath.section == ProfileSection.general.rawValue && indexPath.row == GeneralSection.push.rawValue {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePushTableCell") as! ProfilePushTableCell
//        return cell
//    }
//    else if indexPath.section == ProfileSection.security.rawValue && indexPath.row == SecuritySection.backupPhrase.rawValue {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileBackupPhraseCell") as! ProfileBackupPhraseCell
//
//        let isSuccess = false
//        if isSuccess {
//            cell.iconState.image = UIImage(named: "check_success")
//            cell.viewColorState.backgroundColor = .success400
//        }
//        else {
//            cell.iconState.image = UIImage(named: "info18Error500")
//            cell.viewColorState.backgroundColor = .error500
//        }
//        return cell
//    }
//    else if indexPath.section == ProfileSection.other.rawValue && indexPath.row == OtherSection.bottomRow.rawValue {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileBottomCell") as! ProfileBottomCell
//        cell.buttonDelete.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
//        return cell
//    }
//
//    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableCell") as! ProfileTableCell
//    cell.iconLang.isHidden = true
//    cell.switchControl.isHidden = true
//    cell.iconArrow.isHidden = false
//
//    if indexPath.section == ProfileSection.general.rawValue {
//        cell.labelTitle.text = generalNames[indexPath.row]
//
//        if indexPath.row == GeneralSection.language.rawValue {
//            cell.iconLang.isHidden = false
//        }
//    }
//    else if indexPath.section == ProfileSection.security.rawValue {
//        cell.labelTitle.text = securityNames[indexPath.row]
//
//        if indexPath.row == SecuritySection.touchID.rawValue {
//            cell.switchControl.isHidden = false
//            cell.iconArrow.isHidden = true
//            cell.switchControl.isOn = DataManager.isUseTouchID()
//        }
//    }
//    else if indexPath.section == ProfileSection.other.rawValue {
//        cell.labelTitle.text = otherNames[indexPath.row]
//    }
//    return cell
//}
