//
//  TransactionImageView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 07/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

final class TransactionImageView: UIView, NibOwnerLoadable {
    typealias Model = UIImage

    @IBOutlet private var imageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
}

// MARK: ViewConfiguration

extension TransactionImageView: ViewConfiguration {
    func update(with model: TransactionImageView.Model) {
        imageView.image = model
    }
}
