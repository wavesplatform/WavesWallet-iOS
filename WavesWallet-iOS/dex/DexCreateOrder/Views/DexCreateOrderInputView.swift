//
//  DexCreateInputView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
}

protocol DexCreateOrderInputViewDelegate: AnyObject {
    
    func dexCreateOrder(inputView: DexCreateOrderInputView, didChangeValue value: Double)
}

final class DexCreateOrderInputView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textField: InputNumericTextField!
    @IBOutlet private weak var inputScrollView: DexInputScrollView!
    @IBOutlet private weak var viewTextField: UIView!
    
    weak var delegate: DexCreateOrderInputViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        inputScrollView.input = ["dsad", "daddadadfda", "0.000", "dsad", "dsadasd", "dsad", "dasdad", "dsxx", "sdsd"]
        inputScrollView.inputDelegate = self
        
        textField.inputNumericDelegate = self
        showInputScrollView(animation: false)
    }
}



//MARK: - InputNumericTextFieldDelegate
extension DexCreateOrderInputView: InputNumericTextFieldDelegate {
  
    func inputNumericTextField(_ textField: InputNumericTextField, didChangeValue value: Double) {
        
        delegate?.dexCreateOrder(inputView: self, didChangeValue: textField.value)

        updateViewHeight(inputValue: value)
    }
}

//MARK: - DexInputScrollViewDelegate
extension DexCreateOrderInputView: DexInputScrollViewDelegate {
    
    func dexInputScrollViewDidTapAt(index: Int) {
        hideInputScrollView(animation: true)
    }
}

//MARK: - Actions
private extension DexCreateOrderInputView {
   
    @IBAction func plusTapped(_ sender: Any) {
        textField.addPlusValue()
        
        delegate?.dexCreateOrder(inputView: self, didChangeValue: textField.value)
        updateViewHeight(inputValue: textField.value)
    }
    
    @IBAction func minusTapped(_ sender: Any) {
        textField.addMinusValue()
        
        delegate?.dexCreateOrder(inputView: self, didChangeValue: textField.value)
        updateViewHeight(inputValue: textField.value)
    }
}

//MARK: - SetupUI

extension DexCreateOrderInputView {
    
    func setupTitle(title: String, input: DexCreateOrder.DTO.Input) {
        labelTitle.text = title + " " + input.amountAsset.name
    }
}

//MARK: - Change frame
private extension DexCreateOrderInputView {
    
    func updateViewHeight(inputValue: Double) {
        if inputValue > 0 {
            hideInputScrollView(animation: true)
        }
        else {
            showInputScrollView(animation: true)
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
            UIView.animate(withDuration: Constants.animationDuration) {
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
