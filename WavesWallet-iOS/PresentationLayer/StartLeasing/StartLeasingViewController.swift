//
//  StartLeasingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/27/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class StartLeasingViewController: UIViewController {

    @IBOutlet private weak var labelBalanceTitle: UILabel!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var iconAssetBalance: UIImageView!
    @IBOutlet private weak var labelAssetAmount: UILabel!
    @IBOutlet private weak var iconFavourite: UIImageView!
    
    private var isValidLease: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        createBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
    }
}

private extension StartLeasingViewController {
    func setupLocalization() {
        title = Localizable.StartLeasing.Label.startLeasing
        labelBalanceTitle.text = Localizable.StartLeasing.Label.balance
        
    }
}

//MARK: - UIScrollViewDelegate
extension StartLeasingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
