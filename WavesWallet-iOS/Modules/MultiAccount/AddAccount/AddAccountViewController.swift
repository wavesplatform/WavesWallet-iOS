//
//  AddAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/1/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

final class AddAccountViewController: UIViewController {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var labelCreateNewAccount: UILabel!
    @IBOutlet private weak var labelFastAndFree: UILabel!
    @IBOutlet private weak var labelImportAccount: UILabel!
    @IBOutlet private weak var labelViaSeedPhrase: UILabel!
    @IBOutlet private weak var viewCreateNewAccount: UIView!
    @IBOutlet private weak var viewImportAccount: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        setupLocalization()
        viewCreateNewAccount.addTableCellShadowStyle()
        viewImportAccount.addTableCellShadowStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
    }
    
    @IBAction private func createAccountTapped(_ sender: Any) {
        let vc = StoryboardScene.NewAccount.newAccountViewController.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func importAccountTapped(_ sender: Any) {
        
        let vc = StoryboardScene.Import.importAccountViewController.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupLocalization() {
        labelTitle.text = Localizable.Waves.Addaccount.Label.title
        labelSubtitle.text = Localizable.Waves.Addaccount.Label.subTitle
        labelCreateNewAccount.text = Localizable.Waves.Addaccount.Label.createNewAccount
        labelFastAndFree.text = Localizable.Waves.Addaccount.Label.fastAndFree
        labelImportAccount.text = Localizable.Waves.Addaccount.Label.importAccount
        labelViaSeedPhrase.text = Localizable.Waves.Addaccount.Label.viaSeedPhrase
    }
}
