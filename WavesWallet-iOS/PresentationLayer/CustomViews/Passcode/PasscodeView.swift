//
//  PasscodeView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let delayRemovedNumberSmall: TimeInterval = 0.15
    static let delayRemovedNumberMedium: TimeInterval = 0.2
}

protocol PasscodeViewDelegate: AnyObject {
    func completedInput(with numbers: [Int])
    func biometricButtonDidTap()
}

final class PasscodeView: UIView, NibOwnerLoadable {

    struct Model {
        let numbers: [Int]
        let text: String
        let detail: String?
    }

    @IBOutlet private var buttons: [PasscodeNumberButton]!
    @IBOutlet private var topBarView: PasscodeTopBarView!

    weak var delegate: PasscodeViewDelegate?

    private var numbers: [Int?] = .init(repeating: nil, count: 4)    
    private var isLockedRemoveNumber: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        loadNibContent()
        
        let buttonDidTap: ((PasscodeNumberButton.Kind) -> Void) = { [weak self] kind in

            guard let owner = self else { return }

            if kind != .minus {
                owner.updateState(by: kind)
            } else {
                NSObject.cancelPreviousPerformRequests(withTarget: owner, selector: #selector(owner.removedNumerWithDelay), object: nil)
                if owner.isLockedRemoveNumber == false {
                    owner.updateState(by: kind)
                }
                owner.isLockedRemoveNumber = false
            }
        }
        buttons.forEach {
            $0.buttonDidTap = buttonDidTap
            if $0.kind == PasscodeNumberButton.Kind.minus.rawValue {
                $0.addTarget(self, action: #selector(handlerTouchDownForMinusButton), for: .touchDown)
            }
        }
    }

    @objc func handlerTouchDownForMinusButton() {
        perform(#selector(removedNumerWithDelay), with: nil, afterDelay: Constants.delayRemovedNumberMedium)
    }


    @objc func removedNumerWithDelay() {

        isLockedRemoveNumber = true
        updateState(by: .minus)
        perform(#selector(removedNumerWithDelay), with: nil, afterDelay: Constants.delayRemovedNumberSmall)
    }

    private func updateState(by kind: PasscodeNumberButton.Kind) {

        switch kind {
        case .minus:

            topBarView.removeOneDot()
            removeNumber()

        case .biometric:
            delegate?.biometricButtonDidTap()

        default:
            topBarView.addOneDot()
            addNumber(kind.rawValue)
        }

        if isCompletedInput {
            delegate?.completedInput(with: numbers.compactMap { $0 })
        }
    }

    private func addNumber(_ number: Int) {
        let element = numbers.enumerated().first { $0.element == nil }
        guard let index = element?.offset else {
            return
        }

        numbers[index] = number
    }

    private func removeNumber() {
        let element = numbers.enumerated().filter( { $0.element != nil }).last
        guard let index = element?.offset else {
            return
        }
        numbers[index] = nil
    }

    private var isCompletedInput: Bool {
        return numbers.compactMap { $0 }.count == 4
    }

    func hiddenButton(by kind: PasscodeNumberButton.Kind, isHidden: Bool) {
        let button = buttons.first(where: { $0.kind == kind.rawValue })
        button?.isHidden = isHidden
        button?.update()
    }

    func showInvalidateState() {
        topBarView.showInvalidateState()
    }

    func startLoadingIndicator() {
        topBarView.startLoadingIndicator()
    }

    func stopLoadingIndicator() {
        topBarView.stopLoadingIndicator()
    }
}

// MARK: ViewConfiguration
extension PasscodeView: ViewConfiguration {

    func update(with model: PasscodeView.Model) {

        self.topBarView.changeText(model.text)
        self.topBarView.changeDetail(model.detail)
        self.numbers = self.numbers.enumerated().map {
            if $0.offset < model.numbers.count {
                return model.numbers[$0.offset]
            } else {
                return nil
            }
        }
        self.topBarView.fillDots(count: self.numbers.compactMap { $0 }.count)

    }
}
