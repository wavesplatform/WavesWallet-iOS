//
//  CenteringContentButton.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class CenteringContentButton: UIButton {

    private enum Constants {
        static let titleTopPadding: CGFloat = 8
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {

        let iconSize = super.imageRect(forContentRect: contentRect).size
        let titleSize = super.titleRect(forContentRect: contentRect).size

        var height = iconSize.height


            height += titleSize.height + Constants.titleTopPadding


        return CGRect(x: (contentRect.size.width - iconSize.width) * 0.5,
                      y: ((contentRect.height - height) * 0.5),
                      width: iconSize.width,
                      height: iconSize.height)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {

        let titleSize = super.titleRect(forContentRect: contentRect).size
        let iconSize = super.imageRect(forContentRect: contentRect).size

        var height = titleSize.height

        if iconSize.height > 0 {
            height += iconSize.height + Constants.titleTopPadding
        }

        return CGRect(x: (contentRect.size.width - titleSize.width) * 0.5,
                      y: contentRect.height - ((contentRect.height - height) * 0.5) - titleSize.height,
                      width: titleSize.width,
                      height: titleSize.height)
    }
}
