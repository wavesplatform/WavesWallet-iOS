//
//  ImportAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import QRCodeReader

protocol ImportAccountViewControllerDelegate: AnyObject {
    func scanTapped()
}

final class ImportAccountScanViewController: UIViewController {
    
    @IBOutlet final weak var stepOneTitleLabel: UILabel!
    @IBOutlet final weak var stepTwoTitleLabel: UILabel!
    @IBOutlet final weak var stepTwoDetailLabel: UILabel!
    @IBOutlet final weak var stepThreeTitleLabel: UILabel!
    @IBOutlet final weak var scanPairingButton: UIButton!
    
    @IBOutlet var pairingButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var pairingButtonRightConstraint: NSLayoutConstraint!
    
    weak var delegate: ImportAccountViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .basic50
        
        setupLocalization()
        setupConstraints()
    }
    
    private func setupLocalization() {
        stepOneTitleLabel.text = Localizable.Waves.Import.Scan.Label.Step.One.title
        stepTwoDetailLabel.text = Localizable.Waves.Import.Scan.Label.Step.Two.detail
        stepTwoTitleLabel.text = Localizable.Waves.Import.Scan.Label.Step.Two.title
        stepThreeTitleLabel.text = Localizable.Waves.Import.Scan.Label.Step.Three.title
        scanPairingButton.setTitle(Localizable.Waves.Import.Scan.Button.title, for: .normal)
        scanPairingButton.addTableCellShadowStyle()
    }
    
    private func setupConstraints() {
        if Platform.isIphone5 {
            pairingButtonLeftConstraint.constant = 24
            pairingButtonRightConstraint.constant = 24
        } else {
            pairingButtonLeftConstraint.constant = 32
            pairingButtonRightConstraint.constant = 32
        }
    }
    
    // MARK: - Actions
    
    @IBAction func scanTapped(_ sender: Any) {
        delegate?.scanTapped()
    }
    
}
