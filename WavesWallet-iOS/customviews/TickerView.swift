//
//  SpamView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TickerView: UIView, NibOwnerLoadable {

    struct Model {

        enum Style {
            case soft // Example Money Ticker
            case normal // Example Spam Ticker
        }

        let text: String
        let style: Style
    }

    @IBOutlet private var titleLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension TickerView: ViewConfiguration {

    func update(with model: TickerView.Model) {

        titleLabel.text = model.text
        titleLabel.textColor = .info500
        switch model.style {
        case .normal:
            backgroundColor = .basic100
            layer.removeBorder()
        case .soft:
            backgroundColor = .white
            layer.border(cornerRadius: 2, borderWidth: 0.5, borderColor: .info500)
        }        
    }
}
