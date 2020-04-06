//
//  AppNewsView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 2/15/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Down
import Foundation
import TTTAttributedLabel
import UIKit

private struct AppNewsFontCollection: FontCollection {
    var heading1 = DownFont.boldSystemFont(ofSize: 25)
    var heading2 = DownFont.boldSystemFont(ofSize: 21)
    var heading3 = DownFont.boldSystemFont(ofSize: 17)
    var body = DownFont.systemFont(ofSize: 13)
    var code = DownFont(name: "menlo", size: 13) ?? .systemFont(ofSize: 13)
    var listItemPrefix = DownFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
}

private struct AppNewsColorCollection: ColorCollection {
    var heading1 = DownColor.black
    var heading2 = DownColor.black
    var heading3 = DownColor.black
    var body = DownColor.black
    var code = DownColor.black
    var link = UIColor.submit400
    var quote = DownColor.darkGray
    var quoteStripe = DownColor.darkGray
    var thematicBreak = DownColor(white: 0.9, alpha: 1)
    var listItemPrefix = DownColor.lightGray
    var codeBlockBackground = DownColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
}

final class AppNewsView: PopupActionView<AppNewsView.Model> {
    struct Model {
        let title: String
        let subtitle: String
        let image: UIImage
        let buttonTitle: String

        public init(title: String,
                    subtitle: String,
                    image: UIImage,
                    buttonTitle: String = Localizable.Waves.Appnews.Button.okey) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.buttonTitle = buttonTitle
        }
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: TTTAttributedLabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!

    var tapDismiss: (() -> Void)?
    var didSelectLinkWith: ((URL) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        labelSubtitle.delegate = self
    }

    @IBAction private func okeyTapped(_ sender: Any) {
        tapDismiss?()
        dismiss()
    }

    override func update(with model: Model) {
        labelTitle.text = model.title

        buttonOkey.setTitle(model.buttonTitle,
                            for: .normal)
        
        var downStylerConfigurator = DownStylerConfiguration()
        downStylerConfigurator.colors = AppNewsColorCollection()
        downStylerConfigurator.fonts = AppNewsFontCollection()
        
        let downStyler = DownStyler(configuration: downStylerConfigurator)
        if let subtitle = try? Down(markdownString: model.subtitle).toAttributedString(.default, styler: downStyler) {
            labelSubtitle.attributedText = subtitle
            labelSubtitle.addLinks(from: subtitle)
        } else {
            labelSubtitle.text = model.subtitle
        }

        imageView.image = model.image
    }
}

extension AppNewsView: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        guard let url = url else { return }

        didSelectLinkWith?(url)
    }
}
