//
//  DexInputScrollView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/12/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let fontSize: CGFloat = 13
    static let buttonCorner: CGFloat = 2
    static let buttonHeight: CGFloat = 30
    static let buttonSpace: CGFloat = 8
    static let startOffset: CGFloat = 16
}

protocol DexInputScrollViewDelegate: AnyObject {
    func dexInputScrollViewDidTapAt(index: Int)
}

final class DexInputScrollView: UIScrollView {

    weak var inputDelegate: DexInputScrollViewDelegate?
    
    struct Input {
        let text: String
        let value: Money
    }
    
    var input: [Input] = [] {
        
        didSet {
            subviews.forEach( {$0.removeFromSuperview()})
            
            var scrollWidth: CGFloat = Constants.startOffset
            
            for (index, value) in input.enumerated() {
                let button = createButton(title: value.text)
                button.addTarget(self, action: #selector(amountTapped(_:)), for: .touchUpInside)
                button.tag = index
                button.frame.origin.x = scrollWidth
                addSubview(button)
                scrollWidth += button.frame.size.width + Constants.buttonSpace
            }
            
            contentSize.width = scrollWidth + Constants.buttonSpace
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showsHorizontalScrollIndicator = false
    }
    
    @objc func amountTapped(_ sender: UIButton) {
        let index = sender.tag
        inputDelegate?.dexInputScrollViewDidTapAt(index: index)
    }
}

private extension DexInputScrollView {

    func createButton(title: String) -> UIButton {
        
        let buttonDeltaWidth: CGFloat = 20
        
        let font = UIFont.systemFont(ofSize: Constants.fontSize)
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: title.maxWidth(font: font) + buttonDeltaWidth, height: Constants.buttonHeight)
        button.layer.cornerRadius = Constants.buttonCorner
        button.setTitle(title, for: .normal)
        button.setTitleColor(.basic500, for: .normal)
        button.titleLabel?.font = font
        button.backgroundColor = .basic100
        return button
    }
}
