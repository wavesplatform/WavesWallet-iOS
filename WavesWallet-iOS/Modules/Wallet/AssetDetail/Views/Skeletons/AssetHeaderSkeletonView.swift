//
//  AssetHeaderSkeletonView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

fileprivate enum Constants {
    static var height: CGFloat = 56
}

final class AssetHeaderSkeletonView: SkeletonTableHeaderFooterView, NibReusable {
    @IBOutlet private var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .basic50
        viewContent.backgroundColor = .basic50
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}
