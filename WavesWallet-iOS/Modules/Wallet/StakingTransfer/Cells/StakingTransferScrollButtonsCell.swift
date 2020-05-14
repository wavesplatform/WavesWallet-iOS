//
//  StakingTransferPortionsBar.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit
import UITools

final class StakingTransferScrollButtonsCell: UITableViewCell, NibReusable {
    struct Model: Hashable {
        let buttons: [String]
    }

    @IBOutlet private var inputScrollButtonsView: InputScrollButtonsView!

    var didTapView: ((_ index: Int) -> Void)?

    func value(for index: Int) -> String? {
        return inputScrollButtonsView.value(for: index)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        inputScrollButtonsView.inputDelegate = self
    }
}

// MARK: ViewConfiguration

extension StakingTransferScrollButtonsCell: ViewConfiguration {
    func update(with model: StakingTransferScrollButtonsCell.Model) {
        inputScrollButtonsView.update(with: model.buttons)
    }
}

// MARK: InputScrollButtonsViewDelegate

extension StakingTransferScrollButtonsCell: InputScrollButtonsViewDelegate {
    func inputScrollButtonsViewDidTapAt(index: Int) {
        didTapView?(index)
    }
}
