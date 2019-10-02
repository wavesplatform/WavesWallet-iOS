//
//  MigrateAccountsViewController.swift
//  WavesWallet-iOS
//
//  Created by Лера on 9/25/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import IdentityImg
import Extensions
import RxCocoa
import RxSwift

private enum Constants {
    static let walletRowHeight: CGFloat = 72
}

final class MigrateAccountsViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonProceed: UIButton!
    
    private var sections: [MigrateAccountsTypes.ViewModel.Section] = []
    private let identity: Identity = Identity(options: Identity.defaultOptions)
    private let disposeBag = DisposeBag()
    
    var system: System<MigrateAccountsTypes.State, MigrateAccountsTypes.Event>!

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
        navigationItem.isNavigationBarHidden = true
    }
    
    @IBAction private func proceedTapped(_ sender: Any) {
        
        //TODO: - Logic
        let vc = StoryboardScene.MultiAccount.accountAttentionViewController.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: UI
private extension MigrateAccountsViewController {
    
    func setupLocalization() {
        buttonProceed.setTitle(Localizable.Waves.Migrationaccounts.Button.proceed, for: .normal)
    }
    
    func update(sections: [MigrateAccountsTypes.ViewModel.Section]) {
        self.sections = sections
        tableView.reloadData()
    }
}

//MARK: - UITableViewDelegate
extension MigrateAccountsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = sections[indexPath.section].rows[indexPath.row]

        switch row {
        case .lock(let wallet):
            system.send(.unlockWallet(wallet))

        default:
            break
        }
    }
}

//MARK: - UITableViewDataSource
extension MigrateAccountsViewController: UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let kind = sections[section].kind
        switch kind {
        case .locked, .unlocked:
            return MigrateAccountsHeaderView.viewHeight()
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let kind = sections[section].kind
        
        switch kind {
        case .locked:
            let view = tableView.dequeueAndRegisterHeaderFooter() as MigrateAccountsHeaderView
            view.update(with: Localizable.Waves.Migrationaccounts.Label.pendingUnlock)
            return view
            
        case .unlocked:
            let view = tableView.dequeueAndRegisterHeaderFooter() as MigrateAccountsHeaderView
            view.update(with: Localizable.Waves.Migrationaccounts.Label.successfullyUnlocked)
            return view
            
        case .title:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let kind = sections[indexPath.section].kind
        switch kind {
        case .locked, .unlocked:
            return Constants.walletRowHeight
            
        default:
            return tableView.estimatedRowHeight
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
        
        
        switch row {
        case .title:
            let cell = tableView.dequeueCell() as MigrateAccountsTopCell
            return cell
            
        case .unlock(let wallet):
            let cell = tableView.dequeueAndRegisterCell() as ChooseAccountCell
            let model = ChooseAccountCell.MigrateAccountModel(title: wallet.name,
                                                              address: wallet.address,
                                                              image: identity.createImage(by: wallet.address, size: cell.imageSize),
                                                              isLock: false)
            cell.update(with: .migrateAccount(model))
            return cell

        case .lock(let wallet):
            let cell = tableView.dequeueAndRegisterCell() as ChooseAccountCell
            let model = ChooseAccountCell.MigrateAccountModel(title: wallet.name,
                                                              address: wallet.address,
                                                              image: identity.createImage(by: wallet.address, size: cell.imageSize),
                                                              isLock: true)
            cell.update(with: .migrateAccount(model))
            return cell
        }
    }
}
