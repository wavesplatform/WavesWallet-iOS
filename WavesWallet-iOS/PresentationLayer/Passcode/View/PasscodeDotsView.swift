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

final class PasscodeDotsView: UIView {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dots: [PasscodeDotView]!

    var buttonDidTap: ((Kind) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

//        addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
    }


    private func update(by kind: Int) {
        guard let kind = Kind(rawValue: kind) else { return }
        update(by: kind)
    }

    private func update(by kind: Kind) {
//        if kind == .minus {
//            setTitle("\(kind)", for: .normal)
//        } else {
//            setImage(Images.backspace48Disabled900.image, for: .normal)
//        }
    }


    @objc private func buttonDidTap(_ sender: PasscodeNumberButton) {
        guard let kind = Kind(rawValue: kind) else { return }
        buttonDidTap?(kind)
    }

    func addOneDot() {

    }

    func removeOneDot() {

    }

    func resetDots() {

    }

    func changeText(_ text: String) {
        
    }
}

