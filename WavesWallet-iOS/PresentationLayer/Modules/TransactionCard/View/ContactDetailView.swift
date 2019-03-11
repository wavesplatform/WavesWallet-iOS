//
//  ContactDetailView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 07/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class ContactDetailView: UIView, NibOwnerLoadable {

    struct Model {
        let title: String
        let address: DomainLayer.DTO.Address
    }

    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var nameLabel: UILabel!

    @IBOutlet private var addressLabel: UILabel!

    @IBOutlet private var stackView: UIStackView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: UIView.noIntrinsicMetric)
    }
}

// MARK: ViewConfiguration

extension ContactDetailView: ViewConfiguration {

    func update(with model: Model) {

        self.titleLabel.text = model.title

        if let contact = model.address.contact {
            self.nameLabel.text = contact.name
            self.nameLabel.isHidden = true
        } else {
            self.nameLabel.isHidden = false
        }

        self.addressLabel.text = model.address.address
    }
}
