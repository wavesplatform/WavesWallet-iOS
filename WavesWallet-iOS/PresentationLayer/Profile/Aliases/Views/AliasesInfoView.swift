//
//  AliasesInfoView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let height: CGFloat = 258
}

final class AliasesInfoView: UIView {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var secondSubTitleLabel: UILabel!
    @IBOutlet private var feeTitleLabel: UILabel!
    @IBOutlet private var createButton: UIButton!
    @IBOutlet var arrayButton: UIButton!

    var createButtonDidTap: (() -> Void)?
    var infoButtonDidTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
    }

    @IBAction func handlerTapCreateButton(sender: Any) {
        createButtonDidTap?()
    }

    @IBAction func handlerTapInfoButton(sender: Any) {
        infoButtonDidTap?()
    }
}

// MARK: Localization

extension AliasesInfoView: Localization {

    func setupLocalization() {
        self.titleLabel.text = "Aliases"
    }
}
