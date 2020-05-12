//
//  SendFeeIndicatorCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/02/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import RxSwift
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 56
}

final class SendFeeIndicatorCell: UITableViewCell, Reusable {}

extension SendFeeIndicatorCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
