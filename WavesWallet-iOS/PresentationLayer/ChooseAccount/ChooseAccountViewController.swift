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

private enum Constants {
    static let swipeButtonWidth: CGFloat = 72
    static let editButtonTag = 1000
    static let deleteButtonTag = 1001
}

final class ChooseAccountViewController: UIViewController {

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

        view.backgroundColor = .basic50
        noResultInfoLabel.text = Localizable.Waves.Chooseaccount.Label.nothingWallets
        setupNavigation()
        
        setupSystem()
    }
    
    private func setupNavigation() {
        
        navigationItem.title = Localizable.Waves.Chooseaccount.Navigation.title
        setupBigNavigationBar()
        createBackButton()
        hideTopBarLine()
    }
    
    // MARK: - Content

    fileprivate lazy var swipeButtons: [UIView] = {
        let edit = MGSwipeButton(title: "", icon: Images.editaddress24Submit300.image, backgroundColor: nil)
        edit.buttonWidth = Constants.swipeButtonWidth
        edit.tag = Constants.editButtonTag
        
        let delete = MGSwipeButton(title: "", icon: Images.deladdress24Error400.image, backgroundColor: nil)
        delete.buttonWidth = Constants.swipeButtonWidth
        delete.tag = Constants.deleteButtonTag
        
        return [delete, edit]
    }()
    
    fileprivate var editButtonIndex: Int {
        return swipeButtons.firstIndex(where: { (view) -> Bool in
            view.tag == Constants.editButtonTag
        })!
    }
    
    fileprivate var deleteButtonIndex: Int {
        return swipeButtons.firstIndex(where: { (view) -> Bool in
            view.tag == Constants.deleteButtonTag
        })!
    }
    
    // MARK: - State
    
    fileprivate func reloadTableView() {
        tableView.reloadData()
        
        if wallets.count > 0 {
            hideEmptyView()
        } else {
            showEmptyView()
        }
    }
    
    fileprivate func removeAccount(atIndexPath indexPath: IndexPath) {
        
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
        
    }
    
    // MARK: Actions
    
    fileprivate func deleteTap(atIndexPath indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ChooseAccountCell else { return }
        
        let wallet = wallets[indexPath.row]
        
        let alert = UIAlertController(title: Localizable.Waves.Chooseaccount.Alert.Delete.title,
        message: Localizable.Waves.Chooseaccount.Alert.Delete.message,
        preferredStyle: .alert)
    
        let cancel = UIAlertAction(title: Localizable.Waves.Chooseaccount.Alert.Button.no, style: .cancel) { (action) in
            cell.hideSwipe(animated: true)
        }
    
        let yes = UIAlertAction(title: Localizable.Waves.Chooseaccount.Alert.Button.ok, style: .default) { [weak self] (action) in
            self?.eventInput.onNext(.tapRemoveButton(wallet, indexPath: indexPath))
        }
    
        alert.addAction(cancel)
        alert.addAction(yes)
    
        present(alert, animated: true, completion: nil)
        
    }
    
    private func editTap(atIndexPath indexPath: IndexPath) {
        
        let wallet = wallets[indexPath.row]
        
        eventInput.onNext(.tapEditButton(wallet, indexPath: indexPath))
        
    }
    
    // MARK: Empty
    
    private func showEmptyView() {
        tableView.addSubview(viewNoResult)
        viewNoResult.setNeedsLayout()
        viewNoResult.frame.origin = CGPoint(x: (tableView.frame.width - viewNoResult.frame.width) * 0.5,
                                            y: (tableView.frame.height - viewNoResult.frame.height - layoutInsets.top) * 0.5)
        viewNoResult.alpha = 0
        UIView.animate(withDuration: UIView.fastDurationAnimation) {
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
            
           reloadTableView()

        case .remove(let indexPath):
            
            removeAccount(atIndexPath: indexPath)
            
        default:
            break
        }
    }
    
}

extension ChooseAccountViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ChooseAccountCell = tableView.dequeueAndRegisterCell()
        let wallet = wallets[indexPath.row]
        
        let model = ChooseAccountCell.Model(
                title: wallet.name,
                address: wallet.address,
                image: identity.createImage(by: wallet.address, size: cell.imageIcon.frame.size))
        
        cell.update(with: model)
        cell.delegate = self
        
        return cell
    }
}

extension ChooseAccountViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let wallet = wallets[indexPath.row]
        eventInput.onNext(.tapWallet(wallet))
        
    }
    
}

extension ChooseAccountViewController: MGSwipeTableCellDelegate {
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return false }

        
        if direction == .rightToLeft {
            
            if index == deleteButtonIndex {
                
                deleteTap(atIndexPath: indexPath)
                
            } else if index == editButtonIndex {
                
                editTap(atIndexPath: indexPath)
                
            }
            
        }
        
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        if direction == .rightToLeft {
            
            return swipeButtons
            
        }
        
        return nil
    }
    
}
