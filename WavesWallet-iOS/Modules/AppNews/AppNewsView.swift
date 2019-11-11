//
//  AppNewsView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 2/15/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//
import Foundation
import UIKit
import Down
import TTTAttributedLabel

private struct AppNewsFontCollection: FontCollection {

    public var heading1 = DownFont.boldSystemFont(ofSize: 25)
    public var heading2 = DownFont.boldSystemFont(ofSize: 21)
    public var heading3 = DownFont.boldSystemFont(ofSize: 17)
    public var body = DownFont.systemFont(ofSize: 13)
    public var code = DownFont(name: "menlo", size: 13) ?? .systemFont(ofSize: 13)
    public var listItemPrefix = DownFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
}

private struct AppNewsColorCollection: ColorCollection {

    public var heading1 = DownColor.black
    public var heading2 = DownColor.black
    public var heading3 = DownColor.black
    public var body = DownColor.black
    public var code = DownColor.black
    public var link = UIColor.submit400
    public var quote = DownColor.darkGray
    public var quoteStripe = DownColor.darkGray
    public var thematicBreak = DownColor(white: 0.9, alpha: 1)
    public var listItemPrefix = DownColor.lightGray
    public var codeBlockBackground = DownColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
}


final class AppNewsView: PopupActionView<AppNewsView.Model> {

    struct Model {
        let title: String
        let subtitle: String
        let image: UIImage
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
        buttonOkey.setTitle(Localizable.Waves.Appnews.Button.okey, for: .normal)
        
    }
        
    @IBAction private func okeyTapped(_ sender: Any) {
        tapDismiss?()
        dismiss()
    }
    
    override func update(with model: Model) {
        
        labelTitle.text = model.title
                
        var downStyler = DownStylerConfiguration()
        downStyler.colors = AppNewsColorCollection()
        downStyler.fonts = AppNewsFontCollection()
        
        if let subtitle = try? Down.init(markdownString: model.subtitle).toAttributedString(.default,
                                                                                            styler: DownStyler(configuration: downStyler)) {
            labelSubtitle.attributedText = subtitle
            
            subtitle.enumerateAttributes(in: NSMakeRange(0, subtitle.length),
                                                          options: .longestEffectiveRangeNotRequired)
            { (attributes, range, _) in

                if let subAttribute = attributes.first(where: { $0.key == NSAttributedString.Key.link }) {
                                        
                    if let url = subAttribute.value as? URL {
                        labelSubtitle.addLink(to: url, with: range)
                    } else if let string = subAttribute.value as? String,
                        let url = URL(string: string) {
                        labelSubtitle.addLink(to: url, with: range)
                    }
                }
            }
            
        } else {
            labelSubtitle.text = model.subtitle
        }
        
        imageView.image = model.image
    }
}

extension AppNewsView: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        guard let url = url else { return }
        
        self.didSelectLinkWith?(url)
    }
}


