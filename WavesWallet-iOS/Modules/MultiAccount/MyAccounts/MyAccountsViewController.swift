//
//  MyAccountsViewController.swift
//  WavesWallet-iOS
//
//  Created by Лера on 9/30/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import RxCocoa
import RxSwift
import IdentityImg
import MGSwipeTableCell
import DomainLayer

private enum Constants {
    static let deltaAddButtonWidth: CGFloat = 40
    static let rowHeight: CGFloat = 60
    static let spaceBetweenSections: CGFloat = 10

    static let swipeButtonWidth: CGFloat = 72
    static let editButtonTag = 1000
    static let deleteButtonTag = 1001
}

final class MyAccountsViewController: UIViewController {

    @IBOutlet private weak var addAccountButton: UIButton!
    @IBOutlet private weak var addAccountButtonWidth: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    
    private var sections: [MyAccountsTypes.ViewModel.Section] = []
    private let disposeBag = DisposeBag()
    private let identity: Identity = Identity(options: Identity.defaultOptions)

    var system: System<MyAccountsTypes.State, MyAccountsTypes.Event>!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        
        system
            .start()
            .drive(onNext: { [weak self] state in
                guard let self = self else { return }
                self.update(sections: state.sections)
            }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
        title = Localizable.Waves.Myaccounts.title
        
    }
    
    @IBAction private func addAccountTapped(_ sender: Any) {
    
        let vc = AddAccountModuleBuilder().build()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupLocalization() {
        let title = Localizable.Waves.Myaccounts.Button.addAccount
        addAccountButton.setTitle(title, for: .normal)
        addAccountButtonWidth.constant = title.maxWidth(font: addAccountButton.titleLabel?.font ?? UIFont()) + Constants.deltaAddButtonWidth
    }
    
    private func update(sections: [MyAccountsTypes.ViewModel.Section]) {
        self.sections = sections
        tableView.reloadData()
    }
    
    private func showEditNameVC(wallet: DomainLayer.DTO.Wallet) {
        let vc = NewEditAccountNameModuleBuilder(output: self).build(input: wallet)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
        present(vc, animated: true, completion: nil)
    }
    
    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning(dismiss: nil)
}


//MARK: - UITableViewDelegate
extension MyAccountsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = sections[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .lock(let wallet):
            system.send(.unlockWallet(wallet))
            
        case .unlock(let wallet):
            system.send(.activateWallet(wallet))
        default:
            break
        }
    }
}

//MARK: - UITableViewDataSource
extension MyAccountsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MigrateAccountsHeaderView.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let kind = sections[section].kind
        
        let view = tableView.dequeueAndRegisterHeaderFooter() as MigrateAccountsHeaderView
        view.bgContent.backgroundColor = .white
        
        switch kind {
        case .locked:
            view.update(with: Localizable.Waves.Migrationaccounts.Label.pendingUnlock)
        case .unlocked:
            view.update(with: Localizable.Waves.Migrationaccounts.Label.successfullyUnlocked)
        }
        
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let kind = sections[section].kind
        switch kind {
        case .unlocked:
            return UIView()
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let kind = sections[section].kind
        switch kind {
        case .unlocked:
            return Constants.spaceBetweenSections
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = sections[indexPath.section].rows[indexPath.row]
        
        let cell = tableView.dequeueAndRegisterCell() as ChooseAccountCell
        cell.delegate = self

        switch row {
            
        case .selected(let wallet):
            let model = ChooseAccountCell.MyAccountModel(title: wallet.name,
                                                         address: wallet.address,
                                                         image: identity.createImage(by: wallet.address, size: cell.imageSize),
                                                         isLock: false,
                                                         isSelected: true)
            cell.update(with: .myAccount(model))
            
        case .unlock(let wallet):
            let model = ChooseAccountCell.MyAccountModel(title: wallet.name,
                                                         address: wallet.address,
                                                         image: identity.createImage(by: wallet.address, size: cell.imageSize),
                                                         isLock: false,
                                                         isSelected: false)
            cell.update(with: .myAccount(model))
            
        case .lock(let wallet):
            let model = ChooseAccountCell.MyAccountModel(title: wallet.name,
                                                         address: wallet.address,
                                                         image: identity.createImage(by: wallet.address, size: cell.imageSize),
                                                         isLock: true,
                                                         isSelected: false)
            cell.update(with: .myAccount(model))
        }
        
        return cell
    }
}

//MARK: - MGSwipeTableCellDelegate
extension MyAccountsViewController: MGSwipeTableCellDelegate {
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
   
        guard let indexPath = tableView.indexPath(for: cell) else { return false }

        let row = sections[indexPath.section].rows[indexPath.row]
        switch row {
        case .unlock(let wallet):
            print("TODO")
            if index == deleteButtonIndex {

            } else if index == editButtonIndex {
                self.showEditNameVC(wallet: wallet)
            }
        case .lock(let wallet):
            print("TODO")
            if index == deleteButtonIndex {
                
            } else if index == editButtonIndex {
                self.showEditNameVC(wallet: wallet)
            }

        default:
            break
        }

    
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        let row = sections[indexPath.section].rows[indexPath.row]
        if case .selected = row {
            return nil
        }
        
        if direction == .leftToRight {
            return swipeButtons
        }
        
        return nil
    }
}

//MARK: - SwipeCellUI
private extension MyAccountsViewController {
    
    var swipeButtons: [UIView] {
        let edit = MGSwipeButton(title: "", icon: Images.editaddress24Submit300.image, backgroundColor: nil)
        edit.buttonWidth = Constants.swipeButtonWidth
        edit.tag = Constants.editButtonTag
        edit.backgroundColor = .basic50
        
        let delete = MGSwipeButton(title: "", icon: Images.deladdress24Error400.image, backgroundColor: nil)
        delete.buttonWidth = Constants.swipeButtonWidth
        delete.tag = Constants.deleteButtonTag
        delete.backgroundColor = .basic50
        
        return [delete, edit]
    }
    
    var editButtonIndex: Int {
        return swipeButtons.firstIndex(where: {$0.tag == Constants.editButtonTag}) ?? 0

    }
    
    var deleteButtonIndex: Int {
        return swipeButtons.firstIndex(where: {$0.tag == Constants.deleteButtonTag}) ?? 0
    }
}

//MARK: - NewEditAccountNameModuleBuilderOutput
extension MyAccountsViewController: NewEditAccountNameModuleBuilderOutput {
    
    func newEditAccountDidChangeName(newName: String) {
        
        print("TODO")
    }
}
