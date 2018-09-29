//
//  StartLeasingAmountView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationFrameDuration: TimeInterval = 0.3
    static let scrollViewInputHeight: CGFloat = 30
}

protocol StartLeasingAmountViewDelegate: AnyObject {
    func startLeasingAmountView(didChangeValue value: Money)
}

final class StartLeasingAmountView: UIView, NibOwnerLoadable {
    
    struct Input {
        let text: String
        let value: Money
    }
    
    private var isShowInputScrollView = false
    private var isHiddenErrorLabel = true
    private var input: [Input] = []
    
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var textFieldMoney: MoneyTextField!
    @IBOutlet private weak var scrollViewInput: InputScrollButtonsView!
    @IBOutlet private weak var viewTextField: UIView!
    @IBOutlet private weak var scrollViewInputHeight: NSLayoutConstraint!
    @IBOutlet private weak var labelError: UILabel!
    
    weak var delegate: StartLeasingAmountViewDelegate?
    
    var maximumFractionDigits: Int = 0 {
        didSet {
            textFieldMoney.decimals = maximumFractionDigits
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewTextField.addTableCellShadowStyle()
        scrollViewInput.inputDelegate = self
        labelError.alpha = 0
        textFieldMoney.inputNumericDelegate = self
    }
}

//MARK: - MoneyTextFieldDelegate
extension StartLeasingAmountView: MoneyTextFieldDelegate {
    
    func moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money) {
        delegate?.startLeasingAmountView(didChangeValue: value)
        updateViewHeight(inputValue: value, animation: true)
    }
}

//MARK: - ViewConfiguration
extension StartLeasingAmountView: ViewConfiguration {
    
    func update(with input: [Input]) {
        
        self.input = input
        isShowInputScrollView = input.count > 0
        scrollViewInput.update(with: input.map({$0.text}))
        updateViewHeight(inputValue: textFieldMoney.value, animation: false)
    }
}

//MARK: - InputScrollButtonsViewDelegate
extension StartLeasingAmountView: InputScrollButtonsViewDelegate {
    
    func inputScrollButtonsViewDidTapAt(index: Int) {
        
        let value = input[index].value
        textFieldMoney.setValue(value: value)
        delegate?.startLeasingAmountView(didChangeValue: value)
        updateViewHeight(inputValue: value, animation: true)
    }
}


//MARK: - Change frame
private extension StartLeasingAmountView {
    
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
        
        let height = scrollViewInput.frame.origin.y + Constants.scrollViewInputHeight
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        scrollViewInputHeight.constant = Constants.scrollViewInputHeight
        updateWithAnimationIfNeed(animation: animation)
    }
    
    func hideInputScrollView(animation: Bool) {
        
        let height = viewTextField.frame.origin.y + viewTextField.frame.size.height
        guard heightConstraint.constant != height else { return }
        
        heightConstraint.constant = height
        scrollViewInputHeight.constant = 0
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
