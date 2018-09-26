//
//  PasscodeDorsView.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class PasscodeDotView: UIView {

    enum Kind: Int {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
    }

    @IBInspectable var kind: Int = -1
}

final class PasscodeTopBarView: UIView {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailLabel: UILabel!
    @IBOutlet private var dots: [PasscodeDotView]!
    @IBOutlet private var indicatorView: UIActivityIndicatorView!

    private var counter: Int = 0
    private var isInvalidateState: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        resetDots()
    }

    private func updateColorsForDots() {
        dots.forEach {

            guard isInvalidateState == false else {
                $0.backgroundColor = .error400
                return
            }

            if $0.kind <= counter {
                $0.backgroundColor = UIColor.submit400
            } else {
                $0.backgroundColor = UIColor.basic100
            }
        }
    }

    private func cancelInvalidateState() {
        guard isInvalidateState == true else { return }
        isInvalidateState = false        
        updateColorsForDots()
    }

    func fillDots(count: Int, animated: Bool = true) {
        counter = min(count, PasscodeDotView.Kind.four.rawValue)

        if animated {
            UIView.animateKeyframes(withDuration: 0.24, delay: 0, options: .calculationModeCubicPaced, animations: {
                self.updateColorsForDots()
            }, completion: nil)
        } else {
            updateColorsForDots()
        }
    }

    func addOneDot() {
        cancelInvalidateState()
        counter = min(counter + 1, PasscodeDotView.Kind.four.rawValue)
        updateColorsForDots()
    }

    func removeOneDot() {
        cancelInvalidateState()
        counter = max(counter - 1, 0)
        updateColorsForDots()
    }

    func resetDots() {
        cancelInvalidateState()
        counter = 0
        updateColorsForDots()
    }

    func changeDetail(_ text: String?) {
        detailLabel.text = text
    }

    func changeText(_ text: String) {

        UIView.animate(withDuration: 0.24, delay: 0, options: .transitionCrossDissolve, animations: {
            self.titleLabel.text = text
        }, completion: nil)
    }

    func showInvalidateState() {
        isInvalidateState = true
        updateColorsForDots()
        ImpactFeedbackGenerator.impactOccurredOrVibrate()
        dots.forEach { $0.shake() }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.cancelInvalidateState()
        }
    }

    func startLoadingIndicator() {
        indicatorView.startAnimating()
    }

    func stopLoadingIndicator() {
        indicatorView.stopAnimating()
    }
}
