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
    static let height: CGFloat = 170
    static let tickerViewContentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
}

final class TransactionHistoryGeneralCell: UITableViewCell, NibReusable {

    weak var delegate: TransactionHistoryGeneralCellDelegate?
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var tickerView: TickerView!
    @IBOutlet private weak var valueLabelXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tickerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var spamTicker: TickerView!
    @IBOutlet private weak var labelSubtitle: UILabel!
    
 
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
            image = Images.tSpamMassreceived48
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
            
            if let asset = model.asset, balance.currency.ticker == nil {
                
                valueLabel.attributedText = .styleForBalance(text: balance.displayText(sign: model.sign ?? .none, withoutCurrency: true) + " " + asset.displayName, font: valueLabel.font)
                
            } else {
                
                valueLabel.attributedText = .styleForBalance(text: balance.displayText(sign: model.sign ?? .none, withoutCurrency: true), font: valueLabel.font)
                
            }
            
            tickerView.update(with: TickerView.Model(text: balance.currency.ticker ?? "", style: .soft))
            
        }
        
        iconImageView.image = icon(for: model.kind)
        nextButton.isHidden = model.canGoForward == false
        previousButton.isHidden = model.canGoBack == false
        labelSubtitle.text = model.exchangeSubtitle

        updateTag(with: model)
    }
    
    func updateTag(with model: TransactionHistoryTypes.ViewModel.General) {
        
        let tickerSize = tickerView.titleLabel.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        let tickerInsets = Constants.tickerViewContentInset
        let tickerWidth = tickerSize.width + tickerInsets.left + tickerInsets.right
        
        tickerViewWidthConstraint.constant = tickerWidth
        
        spamTicker.isHidden = true
        
        if model.isSpam {
            spamTicker.isHidden = false
            spamTicker.update(with: .init(text: Localizable.Waves.General.Ticker.Title.spam, style: .normal))
            tickerView.isHidden = true
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
        return Constants.height
    }
    
}


