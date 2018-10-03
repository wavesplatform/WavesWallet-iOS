//
//  EnterStartBlockCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


private enum Constants {
    static let imageSize = CGSize(width: 80, height: 80)
    static let imageToTitle: CGFloat = 24
    static let titleToText: CGFloat = 8
    static let contentInset: UIEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24)
    
    static let titleAttributes: [NSAttributedStringKey: Any] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = 5
        
        let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        return [.font: font, .paragraphStyle: style]
    }()
    
    static let textAttributes: [NSAttributedStringKey: Any] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = 1
        
        let font = UIFont.systemFont(ofSize: 13)
        
        return [.font: font, .paragraphStyle: style]
    }()
}

class EnterStartBlockCell: UICollectionViewCell, NibReusable {
    
    @IBOutlet weak var textLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        let height = textLabel.attributedText?.boundingRect(with: .init(width: bounds.width - 24 - 24, height: CGFloat.greatestFiniteMagnitude)).height
//        textLabelConstraint.constant = height
    }

    class func cellHeight(model: EnterStartTypes.Block, width: CGFloat)-> CGFloat {
        let insets = Constants.contentInset
        let imageSize = Constants.imageSize
        let imageToTitle = Constants.imageToTitle
        let titleToText = Constants.titleToText
        let titleHeight = NSAttributedString(string: model.title, attributes: Constants.titleAttributes).boundingRect(with: .init(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)).height
        let textHeight = NSAttributedString(string: model.text, attributes: Constants.textAttributes).boundingRect(with: .init(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)).height
        
        return imageSize.height + imageToTitle + titleToText + titleHeight + textHeight
    }
    
}

extension EnterStartBlockCell: ViewConfiguration {
    
    func update(with model: EnterStartTypes.Block) {
        imageView.image = model.image
        titleLabel.text = model.title
        textLabel.text = model.text
    }
    
}
