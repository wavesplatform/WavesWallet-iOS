//
//  WalletQuickNoteCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let padding: CGFloat = 16
    static let pictureSize: CGFloat = 28
    static let paddingPictureRight: CGFloat = 14
    static let separatorHeight: CGFloat = 1
    static let paddingSeparatorTop: CGFloat = 14
    static let paddingSecondTitleTop: CGFloat = 13
    static let paddingThirdTitleTop: CGFloat = 13
    static let paddingThirdTitleBottom: CGFloat = 8
}

final class WalletQuickNoteCell: UITableViewCell, Reusable {

    @IBOutlet var viewContent: UIView!
    @IBOutlet var firstTitle: UILabel!
    @IBOutlet var secondTitle: UILabel!
    @IBOutlet var thirdTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.backgroundColor = UIColor.basic50
        backgroundColor = UIColor.basic50
    }

    class func cellHeight(with width: CGFloat) -> CGFloat {

        //TODO: Localized
        let font = UIFont.systemFont(ofSize: 13)
        let text1 = "You can only transfer or trade WAVES that aren’t leased. The leased amount cannot be transferred or traded by you or anyone else."
        let text2 = "You can cancel a leasing transaction as soon as it appears in the blockchain which usually occurs in a minute or less."
        let text3 = "The generating balance will be updated after 1000 blocks."

        var height = text1.maxHeightMultiline(font: font, forWidth: width - Constants.padding * 2)
        height += Constants.paddingSeparatorTop + Constants.separatorHeight + Constants.paddingSecondTitleTop
        height += text2.maxHeightMultiline(font: font, forWidth: width - Constants.padding * 2 - Constants.pictureSize - Constants.paddingPictureRight)
        height += Constants.paddingSeparatorTop + Constants.separatorHeight + Constants.paddingThirdTitleTop
        height += text3.maxHeightMultiline(font: font, forWidth: width - Constants.padding * 2)
        return height + Constants.paddingThirdTitleBottom
    }
}
