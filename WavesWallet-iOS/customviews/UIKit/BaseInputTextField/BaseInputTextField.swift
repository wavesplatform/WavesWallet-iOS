//
//  PlaceHolderTextField.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
}

protocol BaseInputTextFieldDelegate: AnyObject {
    func baseInputTextField(_ textField: BaseInputTextField, didChange text: String)
}

final class BaseInputTextField: UIView, NibOwnerLoadable {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var textFieldRightOffset: NSLayoutConstraint!
    
    private var isShowTopLabel = false
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var viewSeparator: UIView!
    weak var delegate: BaseInputTextFieldDelegate?

    var text: String {
        return textField.text ?? ""
    }
    
    var trimmingText: String {
        return text.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.alpha = 0
        updateButtonCenterConstraints()
    }
    
    @IBAction private func textFieldDidChange(_ sender: Any) {
        delegate?.baseInputTextField(self, didChange: text)
        setupTopLabel(animation: true)
    }
    
    private func updateButtonCenterConstraints() {

        if let superView = self.superview {
            for constraint in superView.constraints {
                if constraint.firstItem as? UIButton != nil, constraint.firstAttribute == .centerY {
                    constraint.constant += textField.frame.origin.y / 2
                }
            }
        }
    }
}

//MARK: - Methods
extension BaseInputTextField {

    func setupPlaceholder(_ title: String) {
        label.text = title
        textField.placeholder = title
    }
    
    func setupTextFieldRightOffset(_ offset: CGFloat) {
        textFieldRightOffset.constant = offset 
    }
    
    func setupText(_ text: String, animation: Bool = false) {
        textField.text = text
        setupTopLabel(animation: animation)
    }
}

//MARK: - Setup

private extension BaseInputTextField {
    
    func setupTopLabel(animation: Bool) {
        
        if text.count > 0 {
            if !isShowTopLabel {
                isShowTopLabel = true
                UIView.animate(withDuration: animation ? Constants.animationDuration : 0) {
                    self.label.alpha = 1
                }
            }
          
        }
        else {
            if isShowTopLabel {
                isShowTopLabel = false
                UIView.animate(withDuration: animation ? Constants.animationDuration : 0) {
                    self.label.alpha = 0
                }
            }
        }
    }
}
