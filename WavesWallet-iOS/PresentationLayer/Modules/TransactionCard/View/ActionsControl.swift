//
//  ActionsControl.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private struct Constants {
    static let spacingBetweenButtons: CGFloat = 8
    static let scrollViewContentEdgeInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    static let contentEdgeInsets: UIEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 12)
    static let imageEdgeInsets: UIEdgeInsets = .init(top: 0, left: -16, bottom: 0, right: 0)
    static let buttonCornerRadius: CGFloat = 4
}

final class ActionsControl: UIView, NibOwnerLoadable {

    struct Model {

        enum Effect {
            case changeIconForTime(UIImage, TimeInterval)
            case impactOccurred
        }

        struct Button {
            let backgroundColor: UIColor
            let textColor: UIColor
            let text: String
            let icon: UIImage
            let effectsOnTap: [Effect]
            let tapHanler: (() -> Void)
        }

        let buttons: [Button]
    }

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: UIView.noIntrinsicMetric)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.spacing = Constants.spacingBetweenButtons
        scrollView.contentInset = Constants.scrollViewContentEdgeInsets
    }
}

private final class ActionButton: UIButton {

    private var effectsOnTap: [ActionsControl.Model.Effect] = []
    private var tapHanler: (() -> Void)?

    init(_ model: ActionsControl.Model.Button) {
        super.init(frame: CGRect.zero)

        self.effectsOnTap = model.effectsOnTap
        self.tapHanler = model.tapHanler
        self.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        setImage(model.icon, for: .normal)
        setTitle(model.text, for: .normal)
        setTitleColor(model.textColor, for: .normal)
        setBackgroundImage(model.backgroundColor.image, for: .normal)
        layer.cornerRadius = Constants.buttonCornerRadius
        layer.masksToBounds = true
        contentEdgeInsets = Constants.contentEdgeInsets
        imageEdgeInsets = Constants.imageEdgeInsets

        addTarget(self, action: #selector(handlerTapAction), for: .touchUpInside)
    }

    @objc func handlerTapAction() {

        for effect in effectsOnTap {
            switch effect {
            case .changeIconForTime(let image, let interval):

                let oldImage = self.imageView?.image
                self.setImage(image, for: .normal)
                self.isUserInteractionEnabled = false

                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {

                    self.setImage(oldImage, for: .normal)
                    self.isUserInteractionEnabled = true
                }

            case .impactOccurred:
                ImpactFeedbackGenerator.impactOccurred()
            }
        }
        tapHanler?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ActionsControl: ViewConfiguration {

    func update(with model: ActionsControl.Model) {

        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
        model.buttons.forEach { stackView.addArrangedSubview(ActionButton($0)) }
        stackView.addArrangedSubview(UIView())
    }
}
