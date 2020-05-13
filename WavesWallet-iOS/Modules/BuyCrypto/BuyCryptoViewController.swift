// 
//  BuyCryptoViewController.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import RxCocoa
import RxSwift
import UIKit
import UITools

final class BuyCryptoViewController: UIViewController, BuyCryptoViewControllable {
    var interactor: BuyCryptoInteractable?
    
    private var presenterOutput: BuyCryptoPresenterOutput?
    private let viewOutput = VCOutput()

    private var underlyingView: View { view as! View }

    override func loadView() {
        view = View()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindIfNeeded()
    }
}

// MARK: - Underlying view

extension BuyCryptoViewController {
    private final class View: UIView {
        let disposeBag = DisposeBag()

        override init(frame: CGRect) {
            super.init(frame: frame)
            initialSetup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            initialSetup()
        }

        private func initialSetup() {}
    }
}

// MARK: - BindableView

extension BuyCryptoViewController: BindableView {
    func getOutput() -> BuyCryptoViewOutput {
        BuyCryptoViewOutput()
    }

    func bindWith(_ input: BuyCryptoPresenterOutput) {
        presenterOutput = input
        bindIfNeeded()
    }

    private func bindIfNeeded() {
        guard let input = presenterOutput, isViewLoaded else { return }
        // ...
    }
}

// MARK: - ViewOutput

extension BuyCryptoViewController {
    private struct VCOutput {}
}

// MARK: - StoryboardInstantiatable

extension BuyCryptoViewController: StoryboardInstantiatable {}
