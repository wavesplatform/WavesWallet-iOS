//
//  AssetDetailCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let issueDateFormat = "dd.MM.yyyy 'at' hh:mm"
    static let height: CGFloat = 314
    static let pictureSize: CGFloat = 40
    static let pictureLeftPadding: CGFloat = 4
    static let padding: CGFloat = 16
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
}

extension AssetDetailCell: ViewConfiguration {

    func update(with model: AssetTypes.DTO.Asset.Info) {

        assetTitleLabel.text = Localizable.Asset.Cell.Assetinfo.title
        nameTitleLabel.text = Localizable.Asset.Cell.Assetinfo.name
        issuerTitleLabel.text = Localizable.Asset.Cell.Assetinfo.issuer
        idTitleLabel.text = Localizable.Asset.Cell.Assetinfo.id
        typeTitleLabel.text = Localizable.Asset.Cell.Assetinfo.Kind.title
        dateTitleLabel.text = Localizable.Asset.Cell.Assetinfo.issueDate
        descriptionTitleLabel.text = Localizable.Asset.Cell.Assetinfo.description

        nameLabel.text = model.name
        idLabel.text = model.id
        issuerLabel.text = model.issuer
        descriptionLabel.text = model.description

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = Constants.issueDateFormat
        dateLabel.text = dateFormatter.string(from: Date())

        if model.isReissuable {
            typeLabel.text = Localizable.Asset.Cell.Assetinfo.Kind.reissuable
        } else {
            typeLabel.text = Localizable.Asset.Cell.Assetinfo.Kind.notReissuable
        }
    }
}

extension AssetDetailCell: ViewCalculateHeight {

    static func viewHeight(model: AssetTypes.DTO.Asset.Info, width: CGFloat) -> CGFloat {

        let nameHeight =  model.name.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13), forWidth: width - Constants.padding * 2)
        let issuerHeight = model.issuer.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13),
                                                           forWidth: width - Constants.padding * 2 - Constants.pictureSize - Constants.pictureLeftPadding)
        let idHeight = model.id.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13),
                                                   forWidth: width - Constants.padding * 2  - Constants.pictureSize - Constants.pictureLeftPadding)
        let descriptionHeight = model.description.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13), forWidth: width - Constants.padding * 2)

        let height = Constants.height + nameHeight + issuerHeight + idHeight + descriptionHeight
        return height
    }
}
