//
//  SendConfirmationViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/18/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 2
}

final class SendConfirmationViewController: UIViewController {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelBalance: UILabel!
    @IBOutlet private weak var labelTotalUsd: UILabel!
    @IBOutlet private weak var viewRecipient: SendConfirmationRecipientView!
    @IBOutlet private weak var labelFee: UILabel!
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var labelDescriptionError: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var buttonConfirm: HighlightedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewContainer.createTopCorners(radius: Constants.cornerRadius)
//        addBgBlueImage()
        createBackWhiteButton()
        setupLocalization()
        viewRecipient.update(with: .init(name: nil, address: "dsadsadafa"))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        setupBigNavigationBar()
        navigationItem.backgroundImage = UIImage()
        navigationItem.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//MARK: - UI
private extension SendConfirmationViewController {
    func setupLocalization() {
        title = Localizable.SendConfirmation.Label.confirmation
        labelFee.text = Localizable.SendConfirmation.Label.fee
        labelDescription.text = Localizable.SendConfirmation.Label.description
        labelDescriptionError.text = Localizable.SendConfirmation.Label.descriptionIsTooLong
        textField.placeholder = Localizable.SendConfirmation.Label.optionalMessage
        buttonConfirm.setTitle(Localizable.SendConfirmation.Button.confim, for: .normal)
    }
}
