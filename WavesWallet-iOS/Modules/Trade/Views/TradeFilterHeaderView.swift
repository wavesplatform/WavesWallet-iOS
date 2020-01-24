//
//  TradeAltsHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 15.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

private enum Constants {
    static let height: CGFloat = 48
    
    static let topOffet: CGFloat = 2
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

protocol TradeFilterHeaderViewDelegate: AnyObject {

    func tradeAltsHeaderViewDidTapFilter(filter: DomainLayer.DTO.TradeCategory.Filter, atCategory: Int)
}

final class TradeFilterHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var scrollView: UIScrollView!

    private var model: TradeTypes.DTO.Filter!
    
    weak var delegate: TradeFilterHeaderViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard model != nil else { return }
        setupFilters()
    }
    
    private func setupFilters() {
        scrollView.subviews.forEach{ $0.removeFromSuperview() }
        
        var offset: CGFloat = Constants.startOffset
        let font = UIFont.systemFont(ofSize: 13)

        for (index, filter) in model.filters.enumerated() {
            
            let title = filter.name
            let button = UIButton(type: .system)
            let width = title.maxWidth(font: font) + Constants.deltaWidth
            button.frame = .init(x: offset, y: Constants.topOffet, width: width, height: Constants.buttonHeight)
            button.layer.cornerRadius = Constants.cornerRadius
            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
            button.backgroundColor = filter == model.selectedFilter ? .basic200 : .basic100
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
        
        let filter = model.filters[sender.tag]
        delegate?.tradeAltsHeaderViewDidTapFilter(filter: filter, atCategory: model.categoryIndex)
    }
    
    func addShadow() {
        removeShadow()
        if layer.shadowColor == nil {
            layer.setupShadow(options: .init(offset: CGSize(width: 0, height: Constants.Shadow.height),
                                        color: .black,
                                        opacity: Constants.Shadow.opacity,
                                        shadowRadius: Constants.Shadow.shadowRadius,
                                        shouldRasterize: true))
        }
    }

}

extension TradeFilterHeaderView: ViewConfiguration {

    func update(with model: TradeTypes.DTO.Filter) {
        
        self.model = model
        setupFilters()
        addShadow()
    }
}

extension TradeFilterHeaderView: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}

