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
    func dexCreateOrder(inputView: DexCreateOrderInputView, didChangeValue value: Money)
}


final class DexCreateOrderInputView: UIView, NibOwnerLoadable {

    struct Input {
        let text: String
        let value: Money
    }
    
    private var isShowInputScrollView = false
    private var input: [Input] = []
    private var isHiddenErrorLabel = true
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: MoneyTextField!
    @IBOutlet private weak var inputScrollView: InputScrollButtonsView!
    @IBOutlet private weak var viewTextField: UIView!
    @IBOutlet private weak var labelError: UILabel!
    
    weak var delegate: DexCreateOrderInputViewDelegate?
    
    var maximumFractionDigits: Int = 0 {
        didSet {
            textField.setDecimals(maximumFractionDigits, forceUpdateMoney: false)
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
        textField.moneyDelegate = self
        hideInputScrollView(animation: false)
    }
    
    
    //MARK: - Methods
    func setupTitle(title: String) {
        labelTitle.text = title
    }

    
    func setupValue(_ value: Money) {
        textField.setValue(value: value)
        hideInputScrollView(animation: false)
    }
    
    func showErrorMessage(message: String, isShow: Bool) {
    
        if isShow {
            labelError.text = message
            
            if isHiddenErrorLabel {
                isHiddenErrorLabel = false
                UIView.animate(withDuration: Constants.animationErrorLabelDuration) {
                    self.labelError.alpha = 1
                }
            }
        }
        else {
            if !isHiddenErrorLabel {
                isHiddenErrorLabel = true
                
                UIView.animate(withDuration: Constants.animationErrorLabelDuration) {
                    self.labelError.alpha = 0
                }
            }
        }
    }
}

//MARK: - ViewConfiguration

extension DexCreateOrderInputView: ViewConfiguration {

    func update(with input: [Input]) {
        
        self.input = input
        
        isShowInputScrollView = input.count > 0
        inputScrollView.update(with: input.map({$0.text}))
        updateViewHeight(inputValue: textField.value, animation: false)
    }
}

//MARK: - InputNumericTextFieldDelegate
extension DexCreateOrderInputView: MoneyTextFieldDelegate {
  
    func moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money) {
        textFieldDidChangeNewValue()
    }
}

//MARK: - InputScrollButtonsViewDelegate
extension DexCreateOrderInputView: InputScrollButtonsViewDelegate {
    
    func inputScrollButtonsViewDidTapAt(index: Int) {
        hideInputScrollView(animation: true)
        
        let value = input[index].value
        textField.setValue(value: value)
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
        updateViewHeight(inputValue: textField.value, animation: true)
    }
}

//MARK: - Change frame
private extension DexCreateOrderInputView {
    
    func updateViewHeight(inputValue: Money, animation: Bool) {
        
        if isShowInputScrollView {
            if inputValue.isZero {
                showInputScrollView(animation: animation)
            }
            else {
                hideInputScrollView(animation: animation)
            }
        }
        else {
            hideInputScrollView(animation: animation)
        }
    }
    
    func showInputScrollView(animation: Bool) {
        
        let height = inputScrollView.frame.origin.y + inputScrollView.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        updateWithAnimationIfNeed(animation: animation, isShowInputScrollView: true)
    }
    
    func hideInputScrollView(animation: Bool) {
        
        let height = viewTextField.frame.origin.y + viewTextField.frame.size.height
        guard heightConstraint.constant != height else { return }

        heightConstraint.constant = height
        updateWithAnimationIfNeed(animation: animation, isShowInputScrollView: false)
    }
    
    func updateWithAnimationIfNeed(animation: Bool, isShowInputScrollView: Bool) {
        if animation {
            UIView.animate(withDuration: Constants.animationFrameDuration) {
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
