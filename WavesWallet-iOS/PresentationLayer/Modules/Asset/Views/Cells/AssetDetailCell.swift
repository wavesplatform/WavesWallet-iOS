//
//  AssetDetailCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let issueDateFormat = "dd.MM.yyyy 'at' HH:mm"
    static let pictureSize: CGFloat = 40
    static let pictureLeftPadding: CGFloat = 4
    static let padding: CGFloat = 16
    
    static let titleBlockOffset: CGFloat = 24
    static let titleOffset: CGFloat = 8
    static let titleDefaultHeight: CGFloat = 16
    
    static let nameTopOffset: CGFloat = 110
    static let totalAmountDecimalsBlockHeight: CGFloat = 104
    static let typeBlockHeight: CGFloat = 40
}

final class AssetDetailCell: UITableViewCell, Reusable {

    @IBOutlet private var assetTitleLabel: UILabel!

    @IBOutlet private var nameTitleLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!

    @IBOutlet private var issuerTitleLabel: UILabel!
    @IBOutlet private var issuerLabel: UILabel!

    @IBOutlet private var idTitleLabel: UILabel!
    @IBOutlet private var idLabel: UILabel!

    @IBOutlet private var typeTitleLabel: UILabel!
    @IBOutlet private var typeLabel: UILabel!

    @IBOutlet private var dateTitleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    @IBOutlet private var descriptionTitleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
 
    @IBOutlet private weak var labelTotalAmountTitle: UILabel!
    @IBOutlet private weak var labelTotalAmount: CopyableLabel!
    
    @IBOutlet private weak var labelDecimalPointTitle: UILabel!
    @IBOutlet private weak var labelDecimalPoint: CopyableLabel!
    
    @IBOutlet private weak var viewDescription: UIView!
    @IBOutlet private weak var viewIssuer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
    }

    @IBAction func copyIssuerTapped(_ sender: Any) {

        UIPasteboard.general.string = issuerLabel.text

        let button = sender as! UIButton
        button.setImage(Images.checkSuccess.image, for: .normal)
        button.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            button.setImage(Images.copyBlack.image, for: .normal)
            button.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func copyIDTapped(_ sender: Any) {
        
            UIPasteboard.general.string = idLabel.text
        
        let button = sender as! UIButton
        button.setImage(Images.checkSuccess.image, for: .normal)
        button.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            button.setImage(Images.copyBlack.image, for: .normal)
            button.isUserInteractionEnabled = true
        }
    }

    private func setupLocalization() {
        assetTitleLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.title
        nameTitleLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.name
        issuerTitleLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.issuer
        idTitleLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.id
        typeTitleLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.Kind.title
        dateTitleLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.issueDate
        descriptionTitleLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.description
        labelTotalAmountTitle.text = Localizable.Waves.Asset.Cell.Assetinfo.totalAmount
        labelDecimalPointTitle.text = Localizable.Waves.Asset.Cell.Assetinfo.decimalPoints
    }
}

extension AssetDetailCell: ViewConfiguration {

    func update(with model: AssetTypes.DTO.Asset.Info) {
        
        nameLabel.text = model.name
        idLabel.text = model.id
        issuerLabel.text = model.issuer
        descriptionLabel.text = model.description
        
        let decimals = model.assetBalance.asset.precision
        labelDecimalPoint.text = String(decimals)
        
        let totalAmount = Money(model.assetBalance.asset.quantity, decimals)
        labelTotalAmount.text = totalAmount.displayText

        let dateFormatter = DateFormatter.sharedFormatter
        dateFormatter.dateFormat  = Constants.issueDateFormat
        dateLabel.text = dateFormatter.string(from: model.issueDate)

        if model.isReusable {
            typeLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.Kind.reissuable
        } else {
            typeLabel.text = Localizable.Waves.Asset.Cell.Assetinfo.Kind.notReissuable
        }
        viewIssuer.isHidden = model.issuer.count == 0
        viewDescription.isHidden = model.description.count == 0
    }
}

extension AssetDetailCell: ViewCalculateHeight {

    static func viewHeight(model: AssetTypes.DTO.Asset.Info, width: CGFloat) -> CGFloat {
        
        var offset: CGFloat = Constants.nameTopOffset
        let nameHeight = model.name.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13), forWidth: width - Constants.padding * 2)
        offset += nameHeight
        offset += Constants.titleBlockOffset
        
        if model.issuer.count > 0 {
            offset += Constants.titleDefaultHeight
            offset += Constants.titleOffset
            let issuerHeight = model.issuer.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13),
                                                               forWidth: width - Constants.padding * 2 - Constants.pictureSize - Constants.pictureLeftPadding)
            offset += issuerHeight
            offset += Constants.titleBlockOffset
        }
        
        offset += Constants.titleDefaultHeight
        offset += Constants.titleOffset
        let idHeight = model.id.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13),
                                                   forWidth: width - Constants.padding * 2  - Constants.pictureSize - Constants.pictureLeftPadding)
        offset += idHeight
        offset += Constants.titleBlockOffset
        
        offset += Constants.totalAmountDecimalsBlockHeight
        offset += Constants.titleBlockOffset
        
        offset += Constants.typeBlockHeight
        
        if model.description.count > 0 {
            offset += Constants.titleBlockOffset

            offset += Constants.titleDefaultHeight
            offset += Constants.titleOffset
            let descriptionHeight = model.description.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13), forWidth: width - Constants.padding * 2)
            offset += descriptionHeight
        }

        return offset
    }
}
