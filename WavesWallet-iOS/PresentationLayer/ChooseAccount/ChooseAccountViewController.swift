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
    @IBOutlet private weak var noResultInfoLabel: UILabel!

    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    var presenter: ChooseAccountPresenterProtocol!

    private var wallets: [DomainLayer.DTO.Wallet] = .init()
    private let identity: Identity = Identity(options: Identity.defaultOptions)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBigNavigationBar()
        hideTopBarLine()
        navigationItem.barTintColor = .white
        navigationItem.tintColor = .white
        navigationItem.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.largeTitleTextAttributes = [.foregroundColor: UIColor.white]        
        setupSystem()
        addBgBlueImage()
        createBackWhiteButton()
        navigationItem.title = Localizable.ChooseAccount.Navigation.title
        noResultInfoLabel.text = Localizable.ChooseAccount.Label.nothingWallets
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func showEmptyView() {
        tableView.addSubview(viewNoResult)
        viewNoResult.setNeedsLayout()
        viewNoResult.frame.origin = CGPoint(x: (tableView.frame.width - viewNoResult.frame.width) * 0.5,
                                            y: (tableView.frame.height - viewNoResult.frame.height - layoutInsets.top) * 0.5)
        viewNoResult.alpha = 0
        UIView.animate(withDuration: 0.24) {
            self.viewNoResult.alpha = 1
        }
    }

    private func hideEmptyView() {
        viewNoResult.removeFromSuperview()
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

        switch state.action {
        case .reload:
            tableView.reloadData()
            if wallets.count > 0 {
                hideEmptyView()
            } else {
                showEmptyView()
            }

        case .remove(let indexPath):

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                if self.wallets.count > 0 {
                    self.hideEmptyView()
                } else {
                    self.showEmptyView()
                }
            }
            tableView.beginUpdates()
            if wallets.count == 0 {
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.endUpdates()
            CATransaction.commit()
        default:
            break
        }
    }
    
}

// MARK: - MGSwipeTableCellDelegate/ UITableViewDelegate/ UITableViewDatasource
extension ChooseAccountViewController {

    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {

        guard let indexPath = tableView.indexPath(for: cell) else { return false }
        let wallet = wallets[indexPath.row]

        let alert = UIAlertController(title: Localizable.ChooseAccount.Alert.Delete.title,
                                      message: Localizable.ChooseAccount.Alert.Delete.message,
                                      preferredStyle: .alert)

        let cancel = UIAlertAction(title: Localizable.ChooseAccount.Alert.Button.no, style: .cancel) { (action) in
            cell.hideSwipe(animated: true)
        }

        let yes = UIAlertAction(title: Localizable.ChooseAccount.Alert.Button.ok, style: .default) { [weak self] (action) in
            self?.eventInput.onNext(.tapRemoveButton(wallet, indexPath: indexPath))
        }
        alert.addAction(cancel)
        alert.addAction(yes)
        present(alert, animated: true, completion: nil)

        return true
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {

        if direction == .rightToLeft {

            //TODO: Edit
//            let edit = MGSwipeButton(title: "", icon: UIImage(named: "editaddress24Submit300"), backgroundColor: nil)
//            edit.setEdgeInsets(UIEdgeInsetsMake(0, 15, 0, 0))
//            edit.buttonWidth = 72

            let delete = MGSwipeButton(title: "", icon: Images.deladdress24Error400.image, backgroundColor: nil)
            delete.buttonWidth = 72
            return [delete]
        }
        return nil
    }

    //MARK: - UITableView

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let wallet = wallets[indexPath.row]
        eventInput.onNext(.tapWallet(wallet))
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
