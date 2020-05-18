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

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollContainerView: UIView!
    @IBOutlet private weak var spentLabel: UILabel!
    @IBOutlet private weak var fiatCollectionView: UICollectionView!
    @IBOutlet private weak var fiatAmountTextField: RoundedTextField!
    @IBOutlet private weak var fiatSeparatorImageView: UIImageView!
    @IBOutlet private weak var buyLabel: UILabel!
    @IBOutlet private weak var cryptoCollectionView: UICollectionView!
    @IBOutlet private weak var buyButton: BlueButton!
    @IBOutlet private weak var infoTextView: UITextView!

    private var presenterOutput: BuyCryptoPresenterOutput?
    private let viewOutput = VCOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindIfNeeded()
        initialSetup()
    }

    private func initialSetup() {
        navigationItem.largeTitleDisplayMode = .never
        
        scrollContainerView.backgroundColor = .basic50
        fiatCollectionView.backgroundColor = .basic50
        cryptoCollectionView.backgroundColor = .basic50
        
        do {
            fiatSeparatorImageView.contentMode = .scaleAspectFill
            fiatSeparatorImageView.image = Images.separateLineWithArrow.image
        }

        fiatAmountTextField.setError("Error!!!!")
        fiatAmountTextField.setPlaceholder("Amount")

        do {
            infoTextView.layer.borderColor = UIColor.basic300.cgColor
            infoTextView.layer.borderWidth = 1
        }
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
