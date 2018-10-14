//
//  PasscodeDorsView.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let durationDotsAnimation: TimeInterval = 0.6
    static let durationDotsError: TimeInterval = 0.5
}

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
    @IBOutlet private var dotsView: UIView!
    @IBOutlet private var dots: [PasscodeDotView]!

    private var counter: Int = 0
    private var isInvalidateState: Bool = false
    private var isStartLoadingIndicator: Bool = false

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
            UIView.animate(withDuration: UIView.fastDurationAnimation, delay: 0, options: [.curveEaseInOut], animations: {
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

        UIView.animate(withDuration: UIView.fastDurationAnimation, delay: 0, options: .transitionCrossDissolve, animations: {
            self.titleLabel.text = text
        }, completion: nil)
    }

    func showInvalidateState() {
        isInvalidateState = true
        updateColorsForDots()
        ImpactFeedbackGenerator.impactOccurredOrVibrate()
        dotsView.shake()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Constants.durationDotsError) {
            self.cancelInvalidateState()
        }
    }

    func startLoadingIndicator() {
        startAnimationDots()
    }

    func stopLoadingIndicator() {
        dots.forEach { view in
            view.layer.removeAllAnimations()
            self.updateColorsForDots()
        }
    }

    private func startAnimationDots() {
        let duration = Constants.durationDotsAnimation
        let iterations = 7
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: [.beginFromCurrentState,
                                          .overrideInheritedDuration],
                                animations: {

                                    for row in 1...iterations {
                                        let relativeDuration = (duration / Double(iterations)) / duration
                                        let relativeStartTime = Double((row - 1)) * relativeDuration
                                        self.animationDots(row: row,
                                                           withRelativeStartTime: relativeStartTime,
                                                           relativeDuration: relativeDuration)
                                    }

                                },
                                completion: { completed in

                                    if completed == false {
                                        return
                                    }
                                    self.dots.forEach { view in
                                        view.backgroundColor = UIColor.basic100
                                    }
                                    self.startAnimationDots()
                                })
    }

    private func animationDots(row: Int,
                               withRelativeStartTime: TimeInterval,
                               relativeDuration: TimeInterval) {

        UIView.addKeyframe(withRelativeStartTime: withRelativeStartTime, relativeDuration: relativeDuration) {
            self.dots
                .enumerated()
                .forEach { view in

                    let colorKey = row - view.element.kind

                    switch colorKey {
                    case 0:
                        view.element.backgroundColor = UIColor.submit400

                    case 1:
                        view.element.backgroundColor = UIColor.submit400.withAlphaComponent(0.6)

                    case 2:
                        view.element.backgroundColor = UIColor.submit400.withAlphaComponent(0.6)

                    default:
                        view.element.backgroundColor = UIColor.basic100
                    }
                }
        }
    }
}
