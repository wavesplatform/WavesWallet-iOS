//
//  StartLeasingCancelConfirmationViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/20/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class StartLeasingCancelConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

//MARK: - StartLeasingErrorDelegate

extension StartLeasingCancelConfirmationViewController: StartLeasingErrorDelegate {
    func startLeasingDidFail() {
        //TODO: need to show error
    }
}
