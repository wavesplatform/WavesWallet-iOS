//
//  TransactionImageView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 07/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionImageView: UIView, NibOwnerLoadable {

    typealias Model = DomainLayer.DTO.SmartTransaction.Kind

    @IBOutlet private var imageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
}

// MARK: ViewConfiguration

extension TransactionImageView: ViewConfiguration {

    func update(with model: TransactionImageView.Model) {
        imageView.image = model.image
    }
}
