//
//  MarketPulseWidgetCell.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import Extensions

private enum Constants {
    static let height: CGFloat = 38

    static let redTickerColor: UIColor = .error500
    static let greenTickerColor: UIColor = .successLime
    static let tickerRightOffsetDefault: CGFloat = 10
    static let tickerRightOffsetDark: CGFloat = 4
}

final class MarketPulseWidgetCell: UITableViewCell, Reusable {
    
    @IBOutlet private weak var iconLogo: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelPercent: UILabel!
    @IBOutlet private weak var viewTicker: UIView!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var tickerRightOffset: NSLayoutConstraint!
    
    private var disposeBag: DisposeBag = DisposeBag()

    
    private static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = " "
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconLogo.image = nil
        disposeBag = DisposeBag()
    }
}

extension MarketPulseWidgetCell: ViewConfiguration {
    
    func update(with model: MarketPulse.DTO.UIAsset) {

        AssetLogo.logo(icon: model.icon,
                       style: .litle)
            .observeOn(MainScheduler.instance)
            .bind(to: iconLogo.rx.image)
            .disposed(by: disposeBag)
        
        labelTitle.text = model.name
        
        let numberFormatter = MarketPulseWidgetCell.numberFormatter
        let price = model.currency.ticker + (numberFormatter.string(from: NSNumber(value: model.price)) ?? "")
        
        let attr = NSMutableAttributedString(string: price, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
      
        let separatorRange = (price as NSString).range(of: numberFormatter.decimalSeparator)
        attr.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold)],
                           range: NSMakeRange(0, separatorRange.location))
  
        labelPrice.attributedText = attr
        
        if model.percent == 0 {
            labelPercent.text = String(format: "%.0f", model.percent) + "%"
        }
        else if model.percent > 0 {
            labelPercent.text = "+" + String(format: "%.02f", model.percent) + "%"
        }
        else {
            labelPercent.text = "-" + String(format: "%.02f", model.percent * -1) + "%"
        }
        
        tickerRightOffset.constant = model.isDarkMode ? Constants.tickerRightOffsetDark : Constants.tickerRightOffsetDefault
        
        labelTitle.textColor = model.isDarkMode ? .white : .black
        labelPrice.textColor = model.isDarkMode ? .white : .black
      
        if model.isDarkMode {
            viewTicker.backgroundColor = .clear
            
            if model.percent == 0 {
                labelPercent.textColor = .disabled700
            }
            else if model.percent > 0 {
                labelPercent.textColor = Constants.greenTickerColor
            }
            else {
                labelPercent.textColor = Constants.redTickerColor
            }
        }
        else {
            labelPercent.textColor = .white
            
            if model.percent == 0 {
                viewTicker.backgroundColor = .basic700
            }
            else if model.percent > 0 {
                viewTicker.backgroundColor = Constants.greenTickerColor
            }
            else {
                viewTicker.backgroundColor = Constants.redTickerColor
            }
        }
    }
   
}

extension MarketPulseWidgetCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}

extension AssetLogo.Style {
        
    static var litle: AssetLogo.Style = {
        return AssetLogo.Style.init(size: CGSize(width: 20, height: 20),
                                    font: UIFont.systemFont(ofSize: 13),
                                    specs: .init(sponsoredImage: Images.sponsoritem18White.image,
                                                 scriptImage: Images.scriptasset18White.image,
                                                 size: CGSize(width: 8,
                                                              height: 8)))
    }()
}

