//
//  RoundedTextField.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 14.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import UITools

final class RoundedTextField: UIView, ResetableView {
    private let textField = UITextField()

    private let errorLine = UIView()
    private var errorLineLeadingConstraint: NSLayoutConstraint?
    private var errorLineTrailingConstraint: NSLayoutConstraint?
    
    private let errorLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        resetToEmptyState()
        initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        resetToEmptyState()
        initialSetup()
    }

    func resetToEmptyState() {
        textField.placeholder = nil
        textField.text = nil
        errorLabel.text = nil
    }

    func setPlaceholder(_ text: String) {
        textField.placeholder = text
    }
    
    func setError(_ text: String?) {
        if let text = text {
            errorLine.isHidden = false
            errorLabel.isHidden = false
            errorLabel.text = text
        } else {
            errorLine.isHidden = true
            errorLabel.isHidden = true
            errorLabel.text = nil
        }
    }
    
    private func initialSetup() {
        backgroundColor = .clear
        
        setupTextField()
        setupErrorLabel()
        setupErrorLine()
    }
    
    private func setupTextField() {
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 8
        textField.borderStyle = .none
        textField.clipsToBounds = true
        textField.backgroundColor = .basic100
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupErrorLabel() {
        errorLabel.isHidden = true
        errorLabel.textColor = .error500
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 6),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    private func setupErrorLine() {
        errorLine.isHidden = true
        errorLine.translatesAutoresizingMaskIntoConstraints = false
        errorLine.backgroundColor = .error500
        textField.addSubview(errorLine)
        
        NSLayoutConstraint.activate([
            errorLine.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            errorLine.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            errorLine.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            errorLine.heightAnchor.constraint(equalToConstant: 2),
            errorLine.centerXAnchor.constraint(equalTo: textField.centerXAnchor)
        ])
    }
}

extension RoundedTextField {
    var text: ControlProperty<String?> {
        textField.rx.text
    }
}
