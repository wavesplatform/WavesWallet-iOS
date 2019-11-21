//
//  DexCreateOrderInfoViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 14.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

final class DexCreateOrderInfoViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var labelOrderType: UILabel!
    @IBOutlet private weak var labelMarket: UILabel!
    @IBOutlet private weak var labelMarketDescription: UILabel!
    @IBOutlet private weak var labelLimit: UILabel!
    @IBOutlet private weak var labelLimitDescription: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    
    weak var output: DexCreateOrderInfoModuleBuilderOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalization()
    }

    private func setupLocalization() {
        labelOrderType.text = Localizable.Waves.Dexcreateorderinfo.Label.orderTypes
        labelMarket.text = Localizable.Waves.Dexcreateorderinfo.Label.market
        labelMarketDescription.text = Localizable.Waves.Dexcreateorderinfo.Label.marketDescription
        labelLimit.text = Localizable.Waves.Dexcreateorderinfo.Label.limit
        labelLimitDescription.text = Localizable.Waves.Dexcreateorderinfo.Label.limitDescription
        buttonOkey.setTitle(Localizable.Waves.Dexcreateorderinfo.Button.gotIt, for: .normal)

    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        output?.dexCreateOrderInfoDidTapClose()
    }
    
    func calculateHeight() -> CGFloat {
        view.layoutIfNeeded()
        view.frame.size.height = scrollView.contentSize.height
        return view.frame.size.height
    }
}
