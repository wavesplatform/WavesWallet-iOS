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

    struct Input {
        let asset: DomainLayer.DTO.Asset
        let address: String
        let displayAddress: String
        let fee: Money
        let amount: Money
        let amountWithoutFee: Money
        let isAlias: Bool
        var attachment: String
        let isGateway: Bool
    }
    
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelBalance: UILabel!
    @IBOutlet private weak var viewRecipient: SendConfirmationRecipientView!
    @IBOutlet private weak var labelFee: UILabel!
    @IBOutlet private weak var labelFeeAmount: UILabel!
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var labelDescriptionError: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var buttonConfirm: HighlightedButton!
    @IBOutlet private weak var tickerView: TickerView!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var viewDescription: UIView!
    
    private var isShowError = false
    
    var input: Input!
    weak var resultDelegate: SendResultDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackWhiteButton()
        setupLocalization()
        setupData()
        labelDescriptionError.alpha = 0
        viewDescription.isHidden = input.isGateway
        setupButtonState()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewContainer.createTopCorners(radius: Constants.cornerRadius)
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
        
        let vc = StoryboardScene.Send.sendLoadingViewController.instantiate()
        vc.delegate = resultDelegate
        vc.input = input
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func descriptionDidChange(_ sender: Any) {
        
        input.attachment = descriptionText
        showError(!isValidAttachment)
        setupButtonState()
    }
    
    private var isValidAttachment: Bool {
        return descriptionText.utf8.count <= Send.ViewModel.maximumDescriptionLength
    }
    
    private func setupButtonState() {
        buttonConfirm.isUserInteractionEnabled = isValidAttachment
        buttonConfirm.backgroundColor = isValidAttachment ? .submit400 : .submit200
    }
    
    private var descriptionText: String {
        return textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    }
}

//MARK: - UITextFieldDelegate

extension SendConfirmationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        confirmTapped(buttonConfirm)
        return true
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
    
    func setupLocalization() {
        title = Localizable.Waves.Sendconfirmation.Label.confirmation
        labelFee.text = Localizable.Waves.Sendconfirmation.Label.fee
        labelDescription.text = Localizable.Waves.Sendconfirmation.Label.description
        labelDescriptionError.text = Localizable.Waves.Sendconfirmation.Label.descriptionIsTooLong
        textField.placeholder = Localizable.Waves.Sendconfirmation.Label.optionalMessage
        buttonConfirm.setTitle(Localizable.Waves.Sendconfirmation.Button.confim, for: .normal)
    }
    
    func setupData() {
        
        let addressBook: AddressBookInteractorProtocol = AddressBookInteractor()
        addressBook.users().subscribe(onNext: { [weak self] contacts in

            guard let strongSelf = self else { return }
            
            if let contact = contacts.first(where: {$0.address == strongSelf.input.address}) {
                strongSelf.viewRecipient.update(with: .init(name: contact.name, address: strongSelf.input.displayAddress))

            }
            else {
                strongSelf.viewRecipient.update(with: .init(name: nil, address: strongSelf.input.address))
            }

        }).dispose()
        
        if let ticker = input.asset.ticker {
            labelAssetName.isHidden = true
            tickerView.update(with: .init(text: ticker, style: .soft))
        }
        else {
            tickerView.isHidden = true
            labelAssetName.text = input.asset.displayName
        }
        labelFeeAmount.text = input.fee.displayText + " WAVES"
        labelBalance.attributedText = NSAttributedString.styleForBalance(text: input.amountWithoutFee.displayTextFull, font: labelBalance.font)
    }
}
