//
//  CreateAliasInputCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import RxSwift
import Extensions

private enum Constants {
    static let height: CGFloat = 62
    static let errorFeeHeight: CGFloat = 50
}

final class CreateAliasInputCell: UITableViewCell, Reusable {

    @IBOutlet private var inputTextField: InputTextField!
    @IBOutlet private weak var viewFeeError: UIView!
    @IBOutlet private weak var labelFeeError: UILabel!
    
    var disposeBag: DisposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
        setupTextField()
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        return inputTextField.becomeFirstResponder()
    }

    lazy var textFieldShouldReturn: Observable<Void> = {

        return Observable.create({ [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            self.inputTextField.textFieldShouldReturn = { [weak self] _ in
                observer.onNext(())
            }
            return Disposables.create()
        })
    }()

    lazy var textFieldChangedValue: Observable<String?> = {

        return Observable.create({ [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            self.inputTextField.changedValue = { [weak self] isValidData, text in
                observer.onNext(text)
            }
            return Disposables.create()
        })
    }()

    var error: String? {

        get {
            return self.inputTextField.error
        }

        set {
            self.inputTextField.error = newValue
        }
    }

    private func setupTextField() {

        inputTextField.autocapitalizationType = .none

        let title = Localizable.Waves.Createalias.Cell.Input.Textfiled.Input.title
        let placeholder = Localizable.Waves.Createalias.Cell.Input.Textfiled.Input.placeholder

        inputTextField.update(with: InputTextField.Model(title: title,
                                                         kind: .text,
                                                         placeholder: placeholder))

        inputTextField.returnKey = .done
    }
}

// MARK: ViewConfiguration

extension CreateAliasInputCell: ViewConfiguration {

    struct Model {
        let text: String?
        let error: String?
        let isValidFee: Bool
    }

    func update(with model: CreateAliasInputCell.Model) {
        inputTextField.value = model.text
        inputTextField.error = model.error
        viewFeeError.isHidden = model.isValidFee
    }
}

// MARK: ViewCalculateHeight

extension CreateAliasInputCell: ViewCalculateHeight {

    static func viewHeight(model: Model, width: CGFloat) -> CGFloat {
        
        return Constants.height + (model.isValidFee ? 0 : Constants.errorFeeHeight)
    }
}


// MARK: Localization

extension CreateAliasInputCell: Localization {

    func setupLocalization() {
        labelFeeError.text = Localizable.Waves.Send.Label.Error.notFundsFee
    }
}
