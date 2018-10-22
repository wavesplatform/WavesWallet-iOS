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
    static let animationDuration: TimeInterval = 0.3
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
    
    private var isShowError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewContainer.createTopCorners(radius: Constants.cornerRadius)
        createBackWhiteButton()
        setupLocalization()
        setupButtonState()
        labelDescriptionError.alpha = 0
        viewRecipient.update(with: .init(name: nil, address: "dsadsadafa"))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        setupBigNavigationBar()
        navigationItem.backgroundImage = UIImage()
        navigationItem.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationItem.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func confirmTapped(_ sender: Any) {
        
    }
    
    @IBAction private func descriptionDidChange(_ sender: Any) {
        showError(descriptionText.utf8.count > Send.ViewModel.maximumDescriptionLength)
    }
    
    private var descriptionText: String {
        return textField.text ?? ""
    }
}

//MARK: - UI
private extension SendConfirmationViewController {
    
    func showError(_ isShow: Bool) {
        
        if isShow {
            if !isShowError {
                isShowError = true
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.labelDescriptionError.alpha = 1
                }
            }
           
        }
        else {
            if isShowError {
               isShowError = false
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.labelDescriptionError.alpha = 0
                }
            }
        }
    }
    
    func setupButtonState() {
        let canContinue = true
        buttonConfirm.isUserInteractionEnabled = canContinue
        buttonConfirm.backgroundColor = canContinue ? .submit400 : .submit200
    }
    
    func setupLocalization() {
        title = Localizable.SendConfirmation.Label.confirmation
        labelFee.text = Localizable.SendConfirmation.Label.fee
        labelDescription.text = Localizable.SendConfirmation.Label.description
        labelDescriptionError.text = Localizable.SendConfirmation.Label.descriptionIsTooLong
        textField.placeholder = Localizable.SendConfirmation.Label.optionalMessage
        buttonConfirm.setTitle(Localizable.SendConfirmation.Button.confim, for: .normal)
    }
}
