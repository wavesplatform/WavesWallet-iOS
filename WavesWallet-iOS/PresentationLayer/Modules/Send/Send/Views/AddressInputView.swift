//
//  StartLeasingGeneratorView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import QRCodeReader
import RxSwift
import RxCocoa


private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let borderRadius: CGFloat = 2
    static let borderWidth: CGFloat = 0.5
}

protocol AddressInputViewDelegate: AnyObject {
    func addressInputViewDidSelectContactAtIndex(_ index: Int)
    func addressInputViewDidSelectAddressBook()
    func addressInputViewDidChangeAddress(_ address: String)
    func addressInputViewDidDeleteAddress()
    func addressInputViewDidScanAddress(_ address: String, amount: Money?, assetID: String?)
    func addressInputViewDidTapNext()
    func addressInputViewDidEndEditing()
    func addressInputViewDidStartLoadingInfo()
    func addressInputViewDidRemoveBlockMode()

}

extension AddressInputViewDelegate {
    func addressInputViewDidStartLoadingInfo() {}
    func addressInputViewDidRemoveBlockMode() {}
}

final class AddressInputView: UIView, NibOwnerLoadable {
    
    struct Input {
        let title: String
        let error: String
        let placeHolder: String
        let contacts: [String]
        let canChangeAsset: Bool
    }
    
    var errorValidation:((String) -> Bool)?
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var inputScrollView: InputScrollButtonsView!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var buttonScan: UIButton!
    @IBOutlet private weak var viewContentTextField: UIView!
    @IBOutlet private weak var labelError: UILabel!
    @IBOutlet private weak var inputScrollViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    private let assetInteractor = FactoryInteractors.instance.assetsInteractor
    private let assetsRepositoryLocal = FactoryRepositories.instance.assetsRepositoryLocal
    private let auth = FactoryInteractors.instance.authorization

    weak var delegate: AddressInputViewDelegate?
    var decimals: Int = 0
    
    private var isHiddenDeleteButton = true
    private var isShowErrorLabel = false
    private var canChangeAsset = false
    
    var isBlockAddressMode: Bool = false {
        didSet {
            updateStyleView()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    var text: String {
        return textField.text ?? ""
    }
    
    var isKeyboardShow: Bool {
        return textField.isFirstResponder
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        labelError.alpha = 0
        viewContentTextField.addTableCellShadowStyle()
        inputScrollView.inputDelegate = self
        buttonDelete.alpha = 0
        showInputScrollView(animation: false)
    }
    
    
    private lazy var readerVC: QRCodeReaderViewController = QRCodeReaderFactory.deffaultCodeReader
    
    //MARK: - Actions
    @IBAction private func addressDidChange(_ sender: Any) {
       
        hideLoadingState()
        setupButtonsState()
        updateHeight(animation: true)
        
        if let text = textField.text {
            delegate?.addressInputViewDidChangeAddress(text)
        }
        
        showLabelError(isShow: false)
    }
    
    @IBAction private func deleteTapped(_ sender: Any) {
        setupText("", animation: true)
        delegate?.addressInputViewDidDeleteAddress()
        showLabelError(isShow: false)
        if isBlockAddressMode {
            isBlockAddressMode = false
            delegate?.addressInputViewDidRemoveBlockMode()
        }
    }
    
    @IBAction private func scanTapped(_ sender: Any) {
        
        CameraAccess.requestAccess(success: { [weak self] in
                self?.showScanner()
            }, failure: { [weak self] in
                let alert = CameraAccess.alertController
            self?.firstAvailableViewController().present(alert, animated: true, completion: nil)
        })
    }
}

extension AddressInputView: ViewConfiguration {

    func update(with model: Input) {
        canChangeAsset = model.canChangeAsset
        labelTitle.text = model.title
        labelError.text = model.error
        textField.placeholder = model.placeHolder
        inputScrollView.update(with: [Localizable.Waves.Startleasing.Button.chooseFromAddressBook] + model.contacts)
    }
}

//MARK: - Methods
extension AddressInputView {
    
    func showLoadingState() {
        buttonDelete.isHidden = true
        buttonScan.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingState() {
        buttonDelete.isHidden = false
        buttonScan.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func setupText(_ text: String, animation: Bool) {
        textField.text = text
        updateHeight(animation: animation)
        setupButtonsState()
    }
    
    func checkIfValidAddress() {
        if let text = textField.text, text.count > 0 {
            var showError = false
            if let validation = errorValidation {
                showError = !validation(text)
            }
            
            showLabelError(isShow: showError)
        }
        else {
            showLabelError(isShow: false)
        }
    }
}

//MARK: - InputScrollButtonsViewDelegate
extension AddressInputView: InputScrollButtonsViewDelegate {
    
    func inputScrollButtonsViewDidTapAt(index: Int) {
        if index == 0 {
            delegate?.addressInputViewDidSelectAddressBook()
        }
        else {
            delegate?.addressInputViewDidSelectContactAtIndex(index - 1)
        }
    }
}


//MARK: - UITextFieldDelegate
extension AddressInputView: UITextFieldDelegate {
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.addressInputViewDidTapNext()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.addressInputViewDidEndEditing()
    }
    
    private func showLabelError(isShow: Bool) {
        guard isShowErrorLabel != isShow else { return }
        isShowErrorLabel = isShow
        UIView.animate(withDuration: Constants.animationDuration) {
            self.labelError.alpha = isShow ? 1 : 0
        }
    }
}


//MARK: - SetupUI

private extension AddressInputView {
    
    func updateStyleView() {
        
        if isBlockAddressMode {
            textField.isUserInteractionEnabled = false
            viewContentTextField.layer.removeShadow()
            viewContentTextField.backgroundColor = .clear
            viewContentTextField.layer.cornerRadius = Constants.borderRadius
            viewContentTextField.layer.borderWidth = Constants.borderWidth
            viewContentTextField.layer.borderColor = UIColor.overlayDark.cgColor
        }
        else {
            textField.isUserInteractionEnabled = true
            viewContentTextField.backgroundColor = .white
            viewContentTextField.layer.cornerRadius = 0
            viewContentTextField.layer.borderWidth = 0
            viewContentTextField.layer.borderColor = nil
            viewContentTextField.addTableCellShadowStyle()
        }
    }
    
    func setupButtonsState() {
        if textField.text?.count ?? 0 > 0 {
            
            if isHiddenDeleteButton {
                isHiddenDeleteButton = false
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.buttonDelete.alpha = 1
                    self.buttonScan.alpha = 0
                }
                
                hideInputScrollView(animation: true)
            }
        }
        else {
            if !isHiddenDeleteButton {
                isHiddenDeleteButton = true
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.buttonDelete.alpha = 0
                    self.buttonScan.alpha = 1
                }
                
                showInputScrollView(animation: true)
            }
        }
    }
}

//MARK: - Change frame

private extension AddressInputView {
    
    func updateHeight(animation: Bool) {
        
        if textField.text?.count ?? 0 > 0 {
            hideInputScrollView(animation: animation)
        }
        else {
            showInputScrollView(animation: animation)
        }
    }
    
    func showInputScrollView(animation: Bool) {
        
        let height = inputScrollView.frame.origin.y + inputScrollView.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        updateWithAnimationIfNeed(animation: animation, isShowInputScrollView: true)
    }
    
    func hideInputScrollView(animation: Bool) {
        
        let height = viewContentTextField.frame.origin.y + viewContentTextField.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        updateWithAnimationIfNeed(animation: animation, isShowInputScrollView: false)
    }
    
    func updateWithAnimationIfNeed(animation: Bool, isShowInputScrollView: Bool) {
        if animation {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.firstAvailableViewController().view.layoutIfNeeded()
                self.inputScrollView.alpha = isShowInputScrollView ? 1 : 0
            }
        }
        else {
            inputScrollView.alpha = isShowInputScrollView ? 1 : 0
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

private extension AddressInputView {
    
    func showScanner() {
        
        guard QRCodeReader.isAvailable() else { return }
        firstAvailableViewController().view.endEditing(true)
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            if let value = result?.value {

                let address = QRCodeParser.parseAddress(value)
                let assetID = QRCodeParser.parseAssetID(value)
                let amount = QRCodeParser.parseAmount(value)
                self.setupText(address, animation: false)

                if amount > 0 {
                    self.getDecimals(assetID: assetID).asDriver { (error) -> SharedSequence<DriverSharingStrategy, Int> in
                        return SharedSequence.just(0)
                    }
                    .drive(onNext: { (decimals) in
                            
                        let amount = Money(value: Decimal(amount), decimals)
                        DispatchQueue.main.async {
                            self.delegate?.addressInputViewDidScanAddress(address,
                                                                          amount: amount,
                                                                          assetID: assetID)
                        }
                    })
                    .disposed(by: self.disposeBag)
                }
                else {
                    DispatchQueue.main.async {
                        self.delegate?.addressInputViewDidScanAddress(address,
                                                                      amount: nil,
                                                                      assetID: assetID)
                    }
                }
                
                self.firstAvailableViewController().dismiss(animated: true, completion: nil)
            }
        }
        
        readerVC.modalPresentationStyle = .formSheet
        
        firstAvailableViewController().present(readerVC, animated: true)
    }
    
    func getDecimals(assetID: String?) -> Observable<Int> {
        if decimals > 0 && !canChangeAsset {
            return Observable.just(decimals)
        }
        
        guard let assetID = assetID else { return Observable.just(0) }
        DispatchQueue.main.async {
            self.delegate?.addressInputViewDidStartLoadingInfo()
        }
        
        return auth.authorizedWallet().flatMap({[weak self] (wallet) -> Observable<Int> in
            guard let owner = self else { return Observable.empty() }
            
            return owner.assetsRepositoryLocal.assets(by: [assetID], accountAddress: wallet.address)
                .flatMap({ (assets) -> Observable<Int> in
                    
                    if let asset = assets.first(where: {$0.id == assetID}) {
                        return Observable.just(asset.precision)
                    }
                    return Observable.just(0)
                })
                .catchError({ [weak self] (error) -> Observable<Int> in
                    
                    guard let owner = self else { return Observable.empty() }
                    return owner.assetInteractor.assets(by: [assetID], accountAddress: wallet.address, isNeedUpdated: false)
                        .flatMap({ (assets) -> Observable<Int> in
                            
                            if let asset = assets.first(where: {$0.id == assetID}) {
                                return Observable.just(asset.precision)
                            }
                            return Observable.just(0)
                        })
                })
            
        })
    }
}
