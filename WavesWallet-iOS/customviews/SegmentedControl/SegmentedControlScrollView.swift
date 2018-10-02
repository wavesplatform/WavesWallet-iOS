//
//  SegmentedControlScrollView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum Constants {
    static let cornerRadius: CGFloat = 2
    static let padding: CGFloat = 10
}

final class SegmentedControlScrollView: UIScrollView {
    private(set) var selectedButtonIndex: Int = 0
    private var isInvalidateButtonsConstraints: Bool = true
    private var buttons: [UIButton] = [UIButton]()
    private var selectedView: UIView = UIView(frame: .zero)

    var changedValue: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        isScrollEnabled = true

        selectedView.backgroundColor = .submit400
        selectedView.layer.cornerRadius = Constants.cornerRadius
        addSubview(selectedView)
    }

    override func updateConstraints() {
        if isInvalidateButtonsConstraints {
            isInvalidateButtonsConstraints = false
            updateButtonConstraints()
        }

        super.updateConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let element = buttons.enumerated().first { selectedButtonIndex == $0.offset }
        guard let selectedButton = element?.element else { return }
        selectedView.frame = selectedButton.frame
    }

    private func updateButtonConstraints() {
        var lastButton: UIButton?
        buttons.forEach { button in

            button.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            if let lastButton = lastButton {
                button.leftAnchor.constraint(equalTo: lastButton.rightAnchor, constant: Constants.padding).isActive = true
                button.topAnchor.constraint(equalTo: topAnchor).isActive = true
                button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            } else {
                button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                button.topAnchor.constraint(equalTo: topAnchor).isActive = true
                button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            }

            lastButton = button
        }

        if let button = lastButton {
            button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }

    // MARK: Methods Handler

    @objc private func tapButton(sender: UIButton) {
        let element = buttons.enumerated().first { sender == $0.element }
        guard let index = element?.offset else { return }

        selectedWith(index: index, animated: true)
        changedValue?(index)
    }

    private func buttonAt(index: Int) -> UIButton? {
        let element = buttons.enumerated().first { index == $0.offset }
        return element?.element
    }
}

// MARK: Public

extension SegmentedControlScrollView {
    func selectedWith(index: Int, animated: Bool) {
        let element = buttons.enumerated().first { index == $0.offset }
        guard let selectedButton = element?.element else { return }
        selectedButton.isUserInteractionEnabled = false

        if let prevButton = buttonAt(index: selectedButtonIndex) {
            prevButton.isUserInteractionEnabled = true
            prevButton.isSelected = false
        }
        selectedButtonIndex = index
        selectedButton.isSelected = true

        if contentSize.width > frame.size.width {
            var offset = selectedButton.frame.origin.x - selectedButton.frame.size.width
            let contentWidth = contentSize.width - frame.size.width
            if offset > contentWidth {
                offset = contentWidth
            } else if offset < 0 {
                offset = 0
            }

            setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        }

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.selectedView.frame = selectedButton.frame
            }
        } else {
            selectedView.frame = selectedButton.frame
        }
    }

    func addButton(_ button: UIButton) {
        button.addTarget(self, action: #selector(tapButton(sender:)), for: .touchUpInside)
        buttons.append(button)
        addSubview(button)
        isInvalidateButtonsConstraints = true
        setNeedsUpdateConstraints()
    }

    func removeAllButtons() {
        buttons.removeAll()
    }
}
