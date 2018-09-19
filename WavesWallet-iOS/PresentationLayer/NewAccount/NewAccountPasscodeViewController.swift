//
//  LightPasscodeViewController.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

//final class

final class NewAccountPasscodeViewController: UIViewController {

    enum State: Hashable {
        case newPassword
        case repeatPassword
    }

    struct Result {
        let state: State
        let numbers: [Int]
    }

    @IBOutlet private var passcodeView: PasscodeView!

    private var state: State = .newPassword
    private var result: [State: [Int]] = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passcodeView.hiddenButton(by: .biometric, isHidden: true)
        passcodeView.delegate = self

        applyState(state)

        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Images.btnBack.image, style: .plain, target: self, action: #selector(backButtonDidTap))
    }

    private func applyState(_ state: State) {
        self.state = state
        let numbers = result[state] ?? []

        switch state {
        case .newPassword:
            passcodeView.update(with: PasscodeView.Model.init(numbers: numbers, text: "newPassword"))

        case .repeatPassword:
            passcodeView.update(with: PasscodeView.Model.init(numbers: numbers, text: "repeat"))
        }
    }

    @objc private func backButtonDidTap() {
        applyState(.newPassword)
    }
}

extension NewAccountPasscodeViewController: PasscodeViewDelegate {

    func completedInput(with numbers: [Int]) {

        switch state {
        case .newPassword:
            result[state] = numbers
            applyState(.repeatPassword)

        case .repeatPassword:
            passcodeView.showInvalidateState()
        }
    }

    func biometricButtonDidTap() {
        
    }
}
