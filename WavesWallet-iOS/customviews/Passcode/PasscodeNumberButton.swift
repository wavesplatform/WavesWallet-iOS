//
//  PasscodeNumberButton.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class PasscodeNumberButton: UIButton {
    
    enum Kind: Int {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        case zero = 0
        case minus = -1
        case biometric = -2
    }

    @IBInspectable var kind: Int = -1 {
        didSet {
            update(by: kind)
        }
    }

    var buttonDidTap: ((Kind) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setBackgroundImage(UIColor.basic50.image, for: .highlighted)
        setTitleColor(.black, for: .highlighted)
        addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = Float(frame.height * 0.5)
    }

    private func update(by kind: Int) {
        guard let kind = Kind(rawValue: kind) else { return }
        update(by: kind)
    }

    private func update(by kind: Kind) {
        switch kind {
        case .minus:
            setImage(Images.backspace48Disabled900.image, for: .normal)
            setTitle(nil, for: .normal)
            
        case .biometric:
            let current = BiometricType.current
            isHidden = false

            switch current {
            case .touchID, .faceID:
                setImage(current.icon, for: .normal)
                
            case .none:
                isHidden = true
            }
            setTitle(nil, for: .normal)

        default:
            setTitle("\(kind.rawValue)", for: .normal)
        }
    }

    @objc private func buttonDidTap(_ sender: PasscodeNumberButton) {
        guard let kind = Kind(rawValue: kind) else { return }
        buttonDidTap?(kind)
    }
}
