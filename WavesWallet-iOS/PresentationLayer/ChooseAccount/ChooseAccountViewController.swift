//
//  EnterSelectAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import IdentityImg
import RxCocoa
import RxSwift
import RxFeedback
import MGSwipeTableCell

final class ChooseAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {

    fileprivate typealias Types = ChooseAccountTypes

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var viewNoResult: UIView!

    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    var presenter: ChooseAccountPresenterProtocol!

    private var wallets: [DomainLayer.DTO.Wallet] = .init()
    private let identity: Identity = Identity(options: Identity.defaultOptions)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose account"


        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()
        navigationItem.barTintColor = .white
        navigationItem.tintColor = .white
        navigationItem.titleTextAttributes = [.foregroundColor: UIColor.white]
        setupSystem()
        addBgBlueImage()
        setupBigNavigationBar()
        createBackWhiteButton()


//        viewNoResult.isHidden = accounts.count > 0
//        tableView.isHidden = accounts.count == 0
//        tableView.contentInset = UIEdgeInsetsMake(18, 0, 0, 0)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
}

// MARK: RxFeedback

private extension ChooseAccountViewController {

    func setupSystem() {

        let uiFeedback: ChooseAccountPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: ChooseAccountPresenterProtocol.Feedback = { [weak self] _ in
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

        self.wallets = state.wallets
        tableView.reloadData()
    }
}

extension ChooseAccountViewController {

    //MARK: - MGSwipeTableCellDelegate

//    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
//
//        let indexPath = tableView.indexPath(for: cell)!
//
//        if index == 0 {
//
//            let isSeed = true
//
//            if isSeed {
//                let controller = StoryboardManager.ProfileStoryboard().instantiateViewController(withIdentifier: "DeleteAccountViewController") as! DeleteAccountViewController
//
//                controller.deleteBlock = {
//                    cell.hideSwipe(animated: true)
//                }
//                controller.cancelBlock = {
//                    cell.hideSwipe(animated: true)
//                }
//                controller.showInController(self)
//            }
//            else {
//                let controller = UIAlertController(title: "Delete account", message: "Are you sure you want to delete this account?", preferredStyle: .alert)
//                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//                    cell.hideSwipe(animated: true)
//                }
//
//                let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
//                    cell.hideSwipe(animated: true)
//                }
//                controller.addAction(cancel)
//                controller.addAction(yes)
//                present(controller, animated: true, completion: nil)
//            }
//
//            return false
//        } else if index == 1 {
//            let controller = storyboard?.instantiateViewController(withIdentifier: "EditAccountNameViewController") as! EditAccountNameViewController
//            navigationController?.pushViewController(controller, animated: true)
//        }
//
//        return true
//    }
//
//    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
//
//        if direction == .rightToLeft {
//
//            let edit = MGSwipeButton(title: "", icon: UIImage(named: "editaddress24Submit300"), backgroundColor: nil)
//            edit.setEdgeInsets(UIEdgeInsetsMake(0, 15, 0, 0))
//            edit.buttonWidth = 72
//
//            let delete = MGSwipeButton.init(title: "", icon: UIImage(named: "deladdress24Error400"), backgroundColor: nil)
//            delete.buttonWidth = 72
//            return [delete, edit]
//        }
//        return nil
//    }

    //MARK: - UITableView

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let wallet = wallets[indexPath.row]
        eventInput.onNext(.tapWallet(wallet))
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChouseAccountCell = tableView.dequeueAndRegisterCell()

        let wallet = wallets[indexPath.row]
        cell.delegate = self
        cell.labelTitle.text = wallet.name
        cell.imageIcon.image = identity.createImage(by: wallet.address, size: cell.imageIcon.frame.size)
        return cell
    }
}
