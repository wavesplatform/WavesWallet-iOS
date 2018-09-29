//
//  StartLeasingGeneratorView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader

private enum Constants {
    static let animationFrameDuration: TimeInterval = 0.3
    static let animationButtonsDuration: TimeInterval = 0.3
    static let inputScrollViewHeight: CGFloat = 30
    static let addressBookIndex: Int = 0
}

protocol StartLeasingGeneratorViewDelegate: AnyObject {
    func startLeasingGeneratorViewDidSelectAddressBook()
    func startLeasingGeneratorViewDidSelect(_ contact: DomainLayer.DTO.Contact)
    func startLeasingGeneratorViewDidChangeAddress(_ address: String)

}

final class StartLeasingGeneratorView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var inputScrollView: InputScrollButtonsView!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonScan: UIButton!
    @IBOutlet private weak var viewContentTextField: UIView!
    @IBOutlet private weak var inputScrollViewHeight: NSLayoutConstraint!
    
    weak var delegate: StartLeasingGeneratorViewDelegate?
    private var lastContacts: [DomainLayer.DTO.Contact] = []
    private var isHiddenDeleteButton = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelTitle.text = Localizable.StartLeasing.Label.generator
        textField.placeholder = Localizable.StartLeasing.Label.nodeAddress
        viewContentTextField.addTableCellShadowStyle()
        inputScrollView.inputDelegate = self
        buttonDelete.alpha = 0
        hideInputScrollView(animation: false)
    }
    
    
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.showSwitchCameraButton = false
            $0.showTorchButton = true
            $0.reader = QRCodeReader()
            $0.readerView = QRCodeReaderContainer(displayable: ScannerCustomView())
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
}

//MARK: - Methods
extension StartLeasingGeneratorView {
    
    func setupText(_ text: String, animation: Bool) {
        textField.text = text
        if text.count > 0 {
            hideInputScrollView(animation: animation)
        }
        else {
            showInputScrollView(animation: animation)
        }
        setupButtonsState()
    }
}

//MARK: - ViewConfiguration
extension StartLeasingGeneratorView: ViewConfiguration {
    
    func update(with lastContacts: [DomainLayer.DTO.Contact]) {
        self.lastContacts = lastContacts
        var names = lastContacts.map( {$0.name} )
        names.insert(Localizable.StartLeasing.Button.chooseFromAddressBook, at: 0)
        inputScrollView.update(with: names)
        showInputScrollView(animation: false)
    }
}

//MARK: - InputScrollButtonsViewDelegate
extension StartLeasingGeneratorView: InputScrollButtonsViewDelegate {
    
    func inputScrollButtonsViewDidTapAt(index: Int) {
        if index == Constants.addressBookIndex {
            delegate?.startLeasingGeneratorViewDidSelectAddressBook()
        }
        else {
            
            let contact = lastContacts[index - 1]
            delegate?.startLeasingGeneratorViewDidSelect(contact)
            setupText(contact.name, animation: true)
        }
    }
}


//MARK: - Actions
private extension StartLeasingGeneratorView {
    
    
    @IBAction func addressDidChange(_ sender: Any) {
        setupButtonsState()
        
        if let text = textField.text {
            delegate?.startLeasingGeneratorViewDidChangeAddress(text)
        }
    }
   
    @IBAction func deleteTapped(_ sender: Any) {
        setupText("", animation: true)
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        showScanner()
    }
}

//MARK: - SetupUI

private extension StartLeasingGeneratorView {
    
    func setupButtonsState() {
        if textField.text?.count ?? 0 > 0 {
            
            if isHiddenDeleteButton {
               isHiddenDeleteButton = false
                UIView.animate(withDuration: Constants.animationButtonsDuration) {
                    self.buttonDelete.alpha = 1
                    self.buttonScan.alpha = 0
                }
                
                hideInputScrollView(animation: true)
            }
        }
        else {
            if !isHiddenDeleteButton {
                isHiddenDeleteButton = true
                UIView.animate(withDuration: Constants.animationButtonsDuration) {
                    self.buttonDelete.alpha = 0
                    self.buttonScan.alpha = 1
                }
                
                showInputScrollView(animation: true)
            }
        }
    }
}

//MARK: - Change frame

private extension StartLeasingGeneratorView {
    
    func showInputScrollView(animation: Bool) {
        
        let height = inputScrollView.frame.origin.y + inputScrollView.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        inputScrollViewHeight.constant = Constants.inputScrollViewHeight
        updateWithAnimationIfNeed(animation: animation)
    }
    
    func hideInputScrollView(animation: Bool) {

        let height = viewContentTextField.frame.origin.y + viewContentTextField.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        inputScrollViewHeight.constant = 0
        updateWithAnimationIfNeed(animation: animation)
    }
    
    func updateWithAnimationIfNeed(animation: Bool) {
        if animation {
            UIView.animate(withDuration: Constants.animationFrameDuration) {
                self.firstAvailableViewController().view.layoutIfNeeded()
            }
        }
    }
    
    var heightConstraint: NSLayoutConstraint {
        
        if let constraint = constraints.first(where: {$0.firstAttribute == .height}) {
            return constraint
        }
        return NSLayoutConstraint()
    }
}

//MARK: - QRCodeReader

private extension StartLeasingGeneratorView {

    func showScanner() {
        
        guard QRCodeReader.isAvailable() else { return }
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
            
            if let address = result?.value {
                
                self.setupText(address, animation: false)
                self.delegate?.startLeasingGeneratorViewDidChangeAddress(address)
            }
            
            self.firstAvailableViewController().dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        firstAvailableViewController().present(readerVC, animated: true) {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
    }
}
