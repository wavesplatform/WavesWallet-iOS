//
//  TransactionHistoryGeneralCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol TransactionHistoryGeneralCellDelegate: class {
    func transactionGeneralCellDidPressNext(cell: TransactionHistoryGeneralCell)
    func transactionGeneralCellDidPressPrevious(cell: TransactionHistoryGeneralCell)
}

private enum Constants {
    static let tickerViewContentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
}

final class TransactionHistoryGeneralCell: UITableViewCell, NibReusable {

    weak var delegate: TransactionHistoryGeneralCellDelegate?
    
    @IBOutlet fileprivate weak var iconImageView: UIImageView!
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    @IBOutlet fileprivate weak var currencyLabel: UILabel!
    
    @IBOutlet fileprivate weak var nextButton: UIButton!
    @IBOutlet fileprivate weak var previousButton: UIButton!
    
    @IBOutlet weak var tickerView: TickerView!
    
   @IBOutlet fileprivate weak var valueLabelXConstraint: NSLayoutConstraint!
    @IBOutlet weak var tickerViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
 
    fileprivate func icon(for kind: DomainLayer.DTO.SmartTransaction.Kind) -> UIImage {
        
        var image: ImageAsset!
        
        switch kind {
        case .sent:
            image = Images.tSend48
        case .receive:
            image = Images.assetReceive
        case .startedLeasing:
            image = Images.walletStartLease
        case .exchange:
            image = Images.tExchange48
        case .selfTransfer:
            image = Images.tSelftrans48
        case .tokenGeneration:
            image = Images.tTokengen48
        case .tokenReissue:
            image = Images.tTokenreis48
        case .tokenBurn:
            image = Images.tTokenburn48
        case .createdAlias:
            image = Images.tAlias48
        case .canceledLeasing:
            image = Images.tCloselease48
        case .incomingLeasing:
            image = Images.tIncominglease48
        case .massSent:
            image = Images.tMasstransfer48
        case .massReceived:
            image = Images.tMassreceived48
        case .spamReceive:
            image = Images.tSpamReceive48
        case .spamMassReceived:
            image = Images.tSpamReceive48
        case .data:
            image = Images.tData48
        case .unrecognisedTransaction:
            image = Images.tAlias48
        }
        
        return UIImage(asset: image)
        
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        delegate?.transactionGeneralCellDidPressPrevious(cell: self)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        delegate?.transactionGeneralCellDidPressNext(cell: self)
    }
}

extension TransactionHistoryGeneralCell: ViewConfiguration {
    func update(with model: TransactionHistoryTypes.ViewModel.General) {
        
        // ставим кастомный тайтл без тэгов
        if let customTitle = model.customTitle {
          
            valueLabel.text = customTitle
            
        } else if let balance = model.balance {
            
            if let asset = model.asset, balance.currency.ticker == nil, (model.isSpam == false || model.isSpam == nil) {
                
                valueLabel.attributedText = .styleForBalance(text: balance.displayText(sign: model.sign ?? .none, withoutCurrency: true) + " " + asset.displayName, font: valueLabel.font)
                
            } else {
                
                valueLabel.attributedText = .styleForBalance(text: balance.displayText(sign: model.sign ?? .none, withoutCurrency: true), font: valueLabel.font)
                
            }
            
            tickerView.update(with: TickerView.Model(text: balance.currency.ticker ?? "", style: .normal))
            
        }
        
        iconImageView.image = icon(for: model.kind)
        currencyLabel.text = model.currencyConversion
        nextButton.isHidden = model.canGoForward == false
        previousButton.isHidden = model.canGoBack == false
        
        updateTag(with: model)
    }
    
    func updateTag(with model: TransactionHistoryTypes.ViewModel.General) {
        
        if model.isSpam == true {
            tickerView.update(with: TickerView.Model(text: Localizable.General.Ticker.Title.spam, style: .soft))
            tickerView.isHidden = false
        }
        
        let tickerSize = tickerView.titleLabel.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        let tickerInsets = Constants.tickerViewContentInset
        let tickerWidth = tickerSize.width + tickerInsets.left + tickerInsets.right
        
        tickerViewWidthConstraint.constant = tickerWidth
        
        if model.isSpam == true {
            tickerView.isHidden = false
            valueLabelXConstraint.constant = tickerWidth / -2
        } else if model.balance?.currency.ticker == nil {
            tickerView.isHidden = true
            valueLabelXConstraint.constant = 0
        } else {
            tickerView.isHidden = false
            valueLabelXConstraint.constant = tickerWidth / -2
        }
        
        setNeedsUpdateConstraints()
        
    }
    
}

extension TransactionHistoryGeneralCell: ViewCalculateHeight {
    
    static func viewHeight(model: TransactionHistoryTypes.ViewModel.General, width: CGFloat) -> CGFloat {
        if model.currencyConversion == nil {
            return 170
        }
        
        return 192
    }
    
}


