//
//  SpamView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let height: CGFloat = 16
}

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
    private var style: Model.Style = .soft

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        switch style {
        case .normal:
            backgroundColor = .blue
            layer.removeBorder()
        case .soft:
            backgroundColor = .red
            layer.border(cornerRadius: 10, borderWidth: 0.5, borderColor: .info500)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: Constants.height)
    }
}

extension TickerView: ViewConfiguration {

    func update(with model: TickerView.Model) {

        titleLabel.text = model.text
        titleLabel.textColor = .info500
        self.style = model.style
        setNeedsLayout()
    }
}
