//
//  AccountAttentionViewController.swift
//  WavesWallet-iOS
//
//  Created by Лера on 9/26/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

protocol AccountAttentionViewControllerDelegate: AnyObject {
    func AccountAttentionViewControllerDidResetAllAccounts()
}

final class AccountAttentionViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var labelWarning: UILabel!
    @IBOutlet private weak var buttonResetAll: UIButton!
    @IBOutlet private weak var buttonCancel: UIButton!
    
    weak var delegate: AccountAttentionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        setupLocalization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
    }

    @IBAction private func resetTapped(_ sender: Any) {
    
        let vc = UIAlertController(title: Localizable.Waves.Accountattention.Alert.title, message: Localizable.Waves.Accountattention.Alert.subtitle, preferredStyle: .alert)
        let cancel = UIAlertAction(title: Localizable.Waves.Accountattention.Alert.cancel, style: .cancel, handler: nil)
        let yes = UIAlertAction(title: Localizable.Waves.Accountattention.Alert.yes, style: .default) { (action) in
            self.delegate?.AccountAttentionViewControllerDidResetAllAccounts()
        }
        vc.addAction(cancel)
        vc.addAction(yes)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func cancelTapped(_ sender: Any) {
    
        let vc = MyAccountsModuleBuilder().build()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Accountattention.Label.title
        labelDescription.text = Localizable.Waves.Accountattention.Label.subtitle
        labelWarning.text = Localizable.Waves.Accountattention.Label.warning
        buttonResetAll.setTitle(Localizable.Waves.Accountattention.Button.resetAll, for: .normal)
        buttonCancel.setTitle(Localizable.Waves.Accountattention.Button.cancel, for: .normal)
    }
}
