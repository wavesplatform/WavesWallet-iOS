//
//  LightPasscodeViewController.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class LightPasscodeViewController: UIViewController {

    enum Kind {
        case new
        case change
        case approve
    }

    struct Passcode {
        let numbers: [String]
    }

    @IBOutlet private var buttons: [PasscodeNumberButton]!
    @IBOutlet private var dotsView: [PasscodeDotsView]!

    private var dots


    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonDidTap: ((PasscodeNumberButton.Kind) -> Void) = { [weak self] kind in
            self?.updateState(by: kind)
        }
        buttons.forEach { $0.buttonDidTap = buttonDidTap }
    }

    private func updateState(by: PasscodeNumberButton.Kind) {

    }
}
