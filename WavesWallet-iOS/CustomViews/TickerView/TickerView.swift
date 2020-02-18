//
//  SpamView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit
import Extensions

fileprivate enum Constants {
    static let height: CGFloat = 16
    static let cornerRadius: CGFloat = 2
}

final class TickerView: UIView, NibOwnerLoadable {

    struct Model {
        
        //TODO: Rename
        enum Style {
            case soft //SPAM
            case normal //ticker
            case custom(backgroundColor: UIColor,
                        textColor: UIColor) //TICKER
        }

        let text: String
        let style: Style
    }

    @IBOutlet private(set) var titleLabel: UILabel!
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
        
        layer.removeBorder()
        
        switch style {
        case .normal:
            backgroundColor = .basic100
            titleLabel.textColor = .info500
            layer.clip(cornerRadius: Constants.cornerRadius)
                        
        case .soft:
            backgroundColor = .white
            titleLabel.textColor = .info500
            layer.border(cornerRadius: Constants.cornerRadius,
                         borderWidth: 0.5, borderColor: .info500)
            
        case .custom(let backgroundColor,
                     let textColor):
            
            self.backgroundColor = backgroundColor
            self.titleLabel.textColor = textColor
            layer.clip(cornerRadius: Constants.cornerRadius)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Constants.height)
    }
}

extension TickerView: ViewConfiguration {

    func update(with model: TickerView.Model) {

        titleLabel.text = model.text
        self.style = model.style
        setNeedsLayout()        
    }
}

extension TickerView {
    static var spamTicker: TickerView.Model {
        return .init(text: Localizable.Waves.General.Ticker.Title.spam,
                     style: .normal)
    }
}
