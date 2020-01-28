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
        
    static let buttonClearOffset: CGFloat = 40
    
    enum Shadow {
        static let height: CGFloat = 4
        static let opacity: Float = 0.1
        static let shadowRadius: Float = 3
    }
}

protocol TradeFilterHeaderViewDelegate: AnyObject {

    func tradeAltsHeaderViewDidTapFilter(filter: DomainLayer.DTO.TradeCategory.Filter, atCategory: Int)
    func tradeDidTapClear(atCategory: Int)
}

final class TradeFilterHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonClear: UIButton!
    @IBOutlet private weak var gradientView: GradientView!
    
    private var model: TradeTypes.DTO.Filter!
        
    weak var delegate: TradeFilterHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        
        gradientView.startColor = UIColor.basic50.withAlphaComponent(0.1)
        gradientView.endColor = UIColor.basic50
        gradientView.direction = .custom(GradientView.Settings.init(startPoint: CGPoint(x: 0.0, y: 0),
                                                                            endPoint: CGPoint(x: 1, y: 0),
                                                                            locations: [0.0, 0.4]))

    }
    
    
    @IBAction private func clearTapped(_ sender: Any) {
        delegate?.tradeDidTapClear(atCategory: model.categoryIndex)
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
            button.backgroundColor = model.selectedFilters.contains(filter) ? .basic200 : .basic100
            button.tag = index
            button.contentVerticalAlignment = .center
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.setTitleColor(.basic500, for: .normal)
            scrollView.addSubview(button)
            
            offset = button.frame.origin.x + button.frame.size.width + Constants.offset
        }
        
        scrollView.contentSize.width = model.selectedFilters.count > 0 ? offset + Constants.buttonClearOffset : offset
        
        if model.selectedFilters.count > 0 {
            gradientView.isHidden = false
            buttonClear.isHidden = false
        }
        else {
            gradientView.isHidden = true
            buttonClear.isHidden = true
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        let filter = model.filters[sender.tag]
        delegate?.tradeAltsHeaderViewDidTapFilter(filter: filter, atCategory: model.categoryIndex)
    }
    
    func addShadow() {
        if layer.shadowOpacity == 0 {
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
    }
}

extension TradeFilterHeaderView: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}

