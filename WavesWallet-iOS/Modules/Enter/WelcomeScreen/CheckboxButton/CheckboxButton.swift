//
//  CheckboxButton.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 25.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import UITools

/**

 */
public class CheckboxButton: UIButton, ResetableView {
    public var isChecked: Bool { isSelected }

    public override var isSelected: Bool {
        didSet {
            updateCheckboxAppearance()
        }
    }

    private var didClickCheckboxAction: ((Bool) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }

    public func resetToEmptyState() {
        isSelected = false
        isEnabled = true
        didClickCheckboxAction = nil
    }

    public func setDidClickCheckbox(_ didClickCheckbox: @escaping (Bool) -> Void) {
        didClickCheckboxAction = didClickCheckbox
    }

    public override func setImage(_: UIImage?, for state: UIControl.State) {
        super.setImage(nil, for: state)
    }

    public override func setTitle(_: String?, for state: UIControl.State) {
        super.setTitle(nil, for: state)
    }

    private func initialSetup() {
        setTitle(nil, for: .normal)
        updateCheckboxAppearance()

        addTarget(self, action: #selector(didClickCheckbox), for: .touchUpInside)
    }

    @objc private func didClickCheckbox() {
        isSelected.toggle()

        didClickCheckboxAction?(isSelected)
    }

    private func updateCheckboxAppearance() {
        guard isEnabled else {
            setBackgroundImage(Images.checkboxOff.image, for: .normal)
            return
        }

        if isSelected {
            setBackgroundImage(Images.checkboxOn.image, for: .normal)
        } else {
            setBackgroundImage(Images.checkboxOff.image, for: .normal)
        }
    }
}
