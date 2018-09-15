//
//  DexCreateInputView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationFrameDuration: TimeInterval = 0.3
    static let animationErrorLabelDuration: TimeInterval = 0.3
}

protocol DexCreateOrderInputViewDelegate: AnyObject {
    func dexCreateOrder(inputView: DexCreateOrderInputView, didChangeValue value: Double)
}


final class DexCreateOrderInputView: UIView, NibOwnerLoadable {

    struct Input {
        let text: String
        let value: Double
    }
    
    private var isShowInputScrollView = false {
        didSet {
            if isShowInputScrollView {
                showInputScrollView(animation: false)
            }
            else {
                hideInputScrollView(animation: false)
            }
        }
    }
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: InputNumericTextField!
    @IBOutlet private weak var inputScrollView: InputScrollButtonsView!
    @IBOutlet private weak var viewTextField: UIView!
    @IBOutlet private weak var labelError: UILabel!
    
    weak var delegate: DexCreateOrderInputViewDelegate?
  
    var maximumFractionDigits: Int = 0 {
        didSet {
            textField.maximumFractionDigits = maximumFractionDigits
        }
    }
    
    var input: [Input] = [] {
        didSet {
            isShowInputScrollView = input.count > 0
            inputScrollView.input = input.map({$0.text})
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelError.alpha = 0
        inputScrollView.inputDelegate = self
        textField.inputNumericDelegate = self
        hideInputScrollView(animation: false)
    }
    
    
    //MARK: - Methods
    func setupTitle(title: String, errorTitle: String?) {
        labelTitle.text = title
        labelError.text = errorTitle
    }
    
    func setupValue(_ value: Double) {
          
        let formatter = DexCreateOrder.ViewModel.numberFormatter(maximumFractionDigits: maximumFractionDigits)
        
        if let string = formatter.string(from: NSNumber(value: value)) {
            textField.setStringValue(value: string)
        }
        hideInputScrollView(animation: false)
    }
    
    func showErrorMessage(show: Bool) {
        
        if show {
            if labelError.alpha == 0 {
                UIView.animate(withDuration: Constants.animationErrorLabelDuration) {
                    self.labelError.alpha = 1
                }
            }
        }
        else {
            if labelError.alpha == 1 {
                UIView.animate(withDuration: Constants.animationErrorLabelDuration) {
                    self.labelError.alpha = 0
                }
            }
        }
    }
}

//MARK: - InputNumericTextFieldDelegate
extension DexCreateOrderInputView: InputNumericTextFieldDelegate {
  
    func inputNumericTextField(_ textField: InputNumericTextField, didChangeValue value: Double) {
        textFieldDidChangeNewValue()
    }
}

//MARK: - InputScrollButtonsViewDelegate
extension DexCreateOrderInputView: InputScrollButtonsViewDelegate {
    
    func inputScrollButtonsViewDidTapAt(index: Int) {
        hideInputScrollView(animation: true)
        
        let value = input[index].value

        let formatter = DexCreateOrder.ViewModel.numberFormatter(maximumFractionDigits: maximumFractionDigits)

        if let string = formatter.string(from: NSNumber(value: value)) {
            textField.setStringValue(value: string)
        }
        
        textFieldDidChangeNewValue()
    }
}

//MARK: - Actions
private extension DexCreateOrderInputView {
   
    @IBAction func plusTapped(_ sender: Any) {
        textField.addPlusValue()
        
        textFieldDidChangeNewValue()
    }
    
    @IBAction func minusTapped(_ sender: Any) {
        textField.addMinusValue()
        textFieldDidChangeNewValue()
    }
    
    func textFieldDidChangeNewValue() {
        
        delegate?.dexCreateOrder(inputView: self, didChangeValue: textField.value)
        if isShowInputScrollView {
            updateViewHeight(inputValue: textField.value)
        }
    }
}

//MARK: - Change frame
private extension DexCreateOrderInputView {
    
    func updateViewHeight(inputValue: Double) {
        
        if isShowInputScrollView {
            if inputValue > 0 {
                hideInputScrollView(animation: true)
            }
            else {
                showInputScrollView(animation: true)
            }
        }
    }
    
    func showInputScrollView(animation: Bool) {
        
        let height = inputScrollView.frame.origin.y + inputScrollView.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        updateWithAnimationIfNeed(animation: animation)
    }
    
    func hideInputScrollView(animation: Bool) {
        
        let height = viewTextField.frame.origin.y + viewTextField.frame.size.height
        guard heightConstraint.constant != height else { return }

        heightConstraint.constant = height
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
