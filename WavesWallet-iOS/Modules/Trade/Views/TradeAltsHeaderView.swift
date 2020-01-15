//
//  TradeAltsHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 15.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 46
    
    static let startOffset: CGFloat = 16
    static let offset: CGFloat = 8
    static let cornerRadius: CGFloat = 4
    static let buttonHeight: CGFloat = 30
    
    static let deltaWidth: CGFloat = 12
    
    enum Shadow {
        static let height: CGFloat = 4
        static let opacity: Float = 0.1
        static let shadowRadius: Float = 3
    }
}

protocol TradeAltsHeaderViewDelegate: AnyObject {

    func tradeAltsHeaderViewDidTapAt(index: Int)
}

final class TradeAltsHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var scrollView: UIScrollView!

    private var items: [String] = []
    private var selectedIndex: Int = 0
    
    weak var delegate: TradeAltsHeaderViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupItems()
    }
    
    private func setupItems() {
        scrollView.subviews.forEach{ $0.removeFromSuperview() }
        
        var offset: CGFloat = Constants.startOffset
        let font = UIFont.systemFont(ofSize: 13)

        for (index, title) in items.enumerated() {
            let button = UIButton(type: .system)
            let width = title.maxWidth(font: font) + Constants.deltaWidth
            button.frame = .init(x: offset, y: 0, width: width, height: Constants.buttonHeight)
            button.layer.cornerRadius = Constants.cornerRadius
            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
            button.backgroundColor = index == selectedIndex ? .basic200 : .basic100
            button.tag = index
            button.contentVerticalAlignment = .center
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.setTitleColor(.basic500, for: .normal)
            scrollView.addSubview(button)
            
            offset = button.frame.origin.x + button.frame.size.width + Constants.offset
        }
        
        if let subView = subviews.last {
            scrollView.contentSize.width = subView.frame.origin.x + subView.frame.size.width + Constants.startOffset
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }
        selectedIndex = sender.tag
        setupItems()
        delegate?.tradeAltsHeaderViewDidTapAt(index: selectedIndex)
    }
}

extension TradeAltsHeaderView: ViewConfiguration {

    func update(with model: [String]) {
        
        if items != model {
            items = model
            setupItems()
        }
        
        if layer.shadowColor == nil {
            layer.setupShadow(options: .init(offset: CGSize(width: 0, height: Constants.Shadow.height),
                                        color: .black,
                                        opacity: Constants.Shadow.opacity,
                                        shadowRadius: Constants.Shadow.shadowRadius,
                                        shouldRasterize: true))
        }
    }
}

extension TradeAltsHeaderView: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
