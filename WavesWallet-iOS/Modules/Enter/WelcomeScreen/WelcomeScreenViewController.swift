//
//  WelcomeScreenViewController.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import RxCocoa
import RxSwift
import UIKit
import UITools

final class WelcomeScreenViewController: UIViewController, WelcomeScreenViewControllable {
    var interactor: WelcomeScreenInteractable?

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!

    private var presenterOutput: WelcomeScreenPresenterOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        bindIfNeeded()
    }
}

// MARK: - BindableView

extension WelcomeScreenViewController: BindableView {
    func getOutput() -> WelcomeScreenViewOutput {
        WelcomeScreenViewOutput()
    }

    func bindWith(_ input: WelcomeScreenPresenterOutput) {
        presenterOutput = input
        bindIfNeeded()
        
        
    }

    private func bindIfNeeded() {
        guard let input = presenterOutput, isViewLoaded else { return }
        // ...
    }
}

// MARK: - StoryboardInstantiatable

extension WelcomeScreenViewController: StoryboardInstantiatable {}
