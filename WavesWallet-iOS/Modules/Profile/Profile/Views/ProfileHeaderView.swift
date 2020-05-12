//
//  ProfileHeader.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 44
}

final class ProfileHeaderView: UITableViewHeaderFooterView, NibReusable {
    @IBOutlet private var labelTitle: UILabel!

    class func viewHeight() -> CGFloat { Constants.height }
}

// MARK: ViewConfiguration

extension ProfileHeaderView: ViewConfiguration {
    func update(with model: String) {
        labelTitle.text = model
    }
}
