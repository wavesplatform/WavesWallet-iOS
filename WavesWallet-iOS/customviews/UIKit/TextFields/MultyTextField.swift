//
//  NewAccountInputTextField.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constans {
    static let animationDuration: TimeInterval = 0.24
}

private extension UITextView {

    func alignTextVerticallyInContainer() {
        guard let font = font else { return }

        if self.contentSize.height < self.bounds.size.height {
            return
        }

        let text = (self.text.count == 0 ? "" : self.text) ?? ""
        let height = text.maxHeightMultiline(font: font, forWidth: self.bounds.size.width)
        var topCorrect = (self.bounds.size.height - height) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.textContainerInset.top = topCorrect
    }
}

final class MultyTextView: UITextView {

    override func layoutSubviews() {
        super.layoutSubviews()
        alignTextVerticallyInContainer()
    }
}

final class MultyTextField: UIView, NibOwnerLoadable {

    struct Model {
        let title: String
        let placeholder: String?
    }

    @IBOutlet private var placeHolder: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var textViewValue: MultyTextView!
    private var originalText: String?

    var value: String? {
        return originalText
    }

    private var isHiddenTitleLabel: Bool = true

    var valueValidator: ((String?) -> String?)?
    var changedValue: ((Bool,String?) -> Void)?
    var textFieldShouldReturn: ((MultyTextField) -> Void)?

    var returnKey: UIReturnKeyType? {
        didSet {
            textViewValue.returnKeyType = returnKey ?? .done
        }
    }

    private(set) var isValidValue: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textViewValue.textContainerInset = .zero
        textViewValue.textContainer.lineFragmentPadding = 0
        textViewValue.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }


    @discardableResult override func becomeFirstResponder() -> Bool {
        return textViewValue.becomeFirstResponder()
    }

    @objc func keyboardWillHide() {
        checkValidValue()
    }

    @objc private func textFieldChanged() {

        if isValidValue == false {
            checkValidValue()
        }

        changedValue?(isValidValue, value)

        let isShow = (textViewValue.text?.count ?? 0) > 0

        let isHiddenTitleLabel = !isShow
        guard isHiddenTitleLabel != self.isHiddenTitleLabel else { return }
        self.isHiddenTitleLabel = isHiddenTitleLabel
        titleLabel.isHidden = isHiddenTitleLabel

        if !self.isHiddenTitleLabel {
            self.titleLabel.alpha = 0
        } else {
            self.titleLabel.alpha = 1
        }

        UIView.animate(withDuration: Constans.animationDuration) {
            if self.isHiddenTitleLabel {
                self.titleLabel.alpha = 0
            } else {
                self.titleLabel.alpha = 1
            }
        }
    }

    private func checkValidValue() {
        checkValidValue(value)
    }

    private func checkValidValue(_ value: String?) {
        var error: String? = nil
        var isValidValue: Bool = false

        if let value = value, value.count > 0 {
            error = valueValidator?(value)
            isValidValue = error == nil
        }

        errorLabel.isHidden = isValidValue
        errorLabel.text = error
        self.isValidValue = isValidValue
    }
}

// MARK: ViewConfiguration
extension MultyTextField: ViewConfiguration {
    func update(with model: MultyTextField.Model) {
        titleLabel.text = model.title
        placeHolder.text = model.placeholder
        titleLabel.isHidden = isHiddenTitleLabel
        checkValidValue()
        textViewValue.autocorrectionType = .no
        textViewValue.autocapitalizationType = .none
    }
}

// MARK: UITextViewDelegate

extension MultyTextField: UITextViewDelegate {

    private func updateTextView(_ text: String?) {
        self.originalText = text
        checkValidValue(text)
        let count = text?.count ?? 0
        placeHolder.isHidden = count != 0
        textViewValue.text = text
        textViewValue.alignTextVerticallyInContainer()
        textFieldChanged()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.alignTextVerticallyInContainer()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if text == "\n" {
            checkValidValue()
            if isValidValue {
                textFieldShouldReturn?(self)
            }
            return false
        }

        if let originalText = originalText,
            let textRange = Range(range, in: originalText) {
            let updatedText = originalText.replacingCharacters(in: textRange, with: text)
            updateTextView(updatedText)
        } else {
            updateTextView(text)
        }
        
        return false
    }
}
