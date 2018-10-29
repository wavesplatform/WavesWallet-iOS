//
//  CreateAliasInputCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let height: CGFloat = 60
}

final class CreateAliasInputCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var inputTextField: InputTextField!

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

    lazy var textFieldShouldReturn: Observable<Void> = {

        return Observable.create({ [weak self] observer -> Disposable in
            guard let owner = self else { return Disposables.create() }
            owner.inputTextField.textFieldShouldReturn = { [weak self] _ in
                observer.onNext(())
            }
            return Disposables.create()
        })
    }()

    lazy var textFieldChangedValue: Observable<String?> = {

        return Observable.create({ [weak self] observer -> Disposable in
            guard let owner = self else { return Disposables.create() }
            owner.inputTextField.changedValue = { [weak self] isValidData, text in
                observer.onNext(text)
            }
            return Disposables.create()
        })
    }()

    private func setupTextField() {

        inputTextField.autocapitalizationType = .none

        inputTextField.update(with: InputTextField.Model(title: "Symbolic name",
                                                           kind: .text,
                                                           placeholder: "Symbolic name"))

        inputTextField.returnKey = .done

        inputTextField.valueValidator = { text -> String? in
            return nil
        }
    }

//    private func continueChangePassword() {
//
//    }
//
//    @IBAction func handlerConfirmButton() {
//        continueChangePassword()
//    }
}

// MARK: ViewConfiguration

extension CreateAliasInputCell: ViewConfiguration {

    struct Model {
        let text: String?
    }

    func update(with model: CreateAliasInputCell.Model) {
        inputTextField.value = model.text
    }
}

// MARK: ViewCalculateHeight

extension CreateAliasInputCell: ViewCalculateHeight {

    static func viewHeight(model: Model, width: CGFloat) -> CGFloat {
        return Constants.height
    }
}


// MARK: Localization

extension CreateAliasInputCell: Localization {

    func setupLocalization() {
//        self.titleLabel.text = "Aliases"
    }
}
