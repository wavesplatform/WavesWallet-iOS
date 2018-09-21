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
    static let startOffset: CGFloat = 16
    static let buttonCorner: CGFloat = 2
    static let buttonHeight: CGFloat = 30
    static let buttonSpace: CGFloat = 8
    static let buttonAdditionalWidth: CGFloat = 20
}

protocol InputScrollButtonsViewDelegate: AnyObject {
    func inputScrollButtonsViewDidTapAt(index: Int)
}

final class InputScrollButtonsView: UIScrollView {

    weak var inputDelegate: InputScrollButtonsViewDelegate?
   
    private var input: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        showsHorizontalScrollIndicator = false
    }
}

extension InputScrollButtonsView: ViewConfiguration {
    
    func update(with input: [String]) {
        
        self.input = input
        setupView()
    }
}

private extension InputScrollButtonsView {

    func setupView() {
        subviews.forEach( {$0.removeFromSuperview()})
        
        var scrollWidth: CGFloat = Constants.startOffset
        
        for (index, value) in input.enumerated() {
            let button = createButton(title: value)
            button.addTarget(self, action: #selector(amountTapped(_:)), for: .touchUpInside)
            button.tag = index
            button.frame.origin.x = scrollWidth
            addSubview(button)
            scrollWidth += button.frame.size.width + Constants.buttonSpace
        }
        
        contentSize.width = scrollWidth + Constants.buttonSpace
    }
    
    @objc func amountTapped(_ sender: UIButton) {
        let index = sender.tag
        inputDelegate?.inputScrollButtonsViewDidTapAt(index: index)
    }
    
    func createButton(title: String) -> UIButton {
                
        let font = UIFont.systemFont(ofSize: Constants.fontSize)
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: title.maxWidth(font: font) + Constants.buttonAdditionalWidth, height: Constants.buttonHeight)
        button.layer.cornerRadius = Constants.buttonCorner
        button.setTitle(title, for: .normal)
        button.setTitleColor(.basic500, for: .normal)
        button.titleLabel?.font = font
        button.backgroundColor = .basic100
        return button
    }
}
