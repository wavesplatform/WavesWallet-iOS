//
//  AssetBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AssetBalanceCell: UITableViewCell, NibReusable {

    private struct Options {
        var isHiddenLeased: Bool
        var isHiddenInOrder: Bool
    }

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var viewLeased: AssetBalanceMoneyInfoView!
    @IBOutlet private var viewTotal: AssetBalanceMoneyInfoView!
    @IBOutlet private var viewInOrder: AssetBalanceMoneyInfoView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var balanceLabel: UILabel!

    @IBOutlet private(set) var sendButton: UIButton!
    @IBOutlet private(set) var receiveButton: UIButton!
    @IBOutlet private(set) var exchangeButton: UIButton!

    private var options: Options?

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight(isLeased: Bool, inOrder: Bool) -> CGFloat {
        var height : CGFloat = 210
        
        if isLeased {
            height += 44
        }
        if inOrder {
            height += 44
        }
        
        if isLeased || inOrder {
            height += 44
        }
        else {
            height += 10
        }
        
        return height
    }
    
    func setupCell(isLeased: Bool, inOrder: Bool) {
        
//        let text = "000.0000000"
//
//        labelBalance.attributedText = NSAttributedString.styleForBalance(text: text, font: labelBalance.font)
//
//
//        if isLeased {
//            heightLeased.constant = 44
//            viewLeased.isHidden = false
//        }
//        else {
//            heightLeased.constant = 0
//            viewLeased.isHidden = true
//        }
//
//        if inOrder {
//            heightInOrder.constant = 44
//            viewInOrder.isHidden = false
//        }
//        else {
//            heightInOrder.constant = 0
//            viewInOrder.isHidden = true
//        }
//
//        if isLeased || inOrder {
//            viewDotterLine.isHidden = true
//            heightTotal.constant = 44
//            viewTotal.isHidden = false
//        }
//        else {
//            viewDotterLine.isHidden = false
//            heightTotal.constant = 10
//            viewTotal.isHidden = true
//        }
    }
}

extension AssetBalanceCell: ViewConfiguration {

    func update(with model: AssetTypes.DTO.Asset.Balance) {

        options = Options(isHiddenLeased: model.leasedMoney.isZero, isHiddenInOrder: model.inOrderMoney.isZero)

        titleLabel.text = ""
        balanceLabel.attributedText = NSAttributedString.styleForBalance(text: model.avaliableMoney.displayTextFull, font: balanceLabel.font)
        viewLeased.update(with: .init(name: "1", money: model.leasedMoney))
        viewInOrder.update(with: .init(name: "2", money: model.inOrderMoney))
        viewTotal.update(with: .init(name: "3", money: model.totalMoney))
        updateConstraints()
    }
}

extension AssetBalanceCell: ViewCalculateHeight {

    static func viewHeight(model: AssetTypes.DTO.Asset.Balance) -> CGFloat {

        return 400
    }
}
