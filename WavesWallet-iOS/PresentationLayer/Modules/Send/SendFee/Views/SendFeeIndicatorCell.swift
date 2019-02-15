//
//  SendFeeIndicatorCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let height: CGFloat = 56
    static let icon = CGSize(width: 28, height: 28)
    static let sponsoredIcon = CGSize(width: 12, height: 12)
    static let noneActiveAlpha: CGFloat = 0.3
}

final class SendFeeIndicatorCell: UITableViewCell, Reusable {}

extension SendFeeIndicatorCell: ViewHeight {

    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}

