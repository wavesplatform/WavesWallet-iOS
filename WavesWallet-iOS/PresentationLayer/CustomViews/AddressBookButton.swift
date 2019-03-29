//
//  AddressBookButton.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class AddressBookButton: UIButton {

    enum Kind {
        case edit
        case add
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        setTitleColor(.white, for: .normal)
        setBackgroundImage(UIColor.submit300.image, for: .normal)
        setBackgroundImage(UIColor.submit200.image, for: .highlighted)

        imageEdgeInsets = UIEdgeInsets(top: 0,
                                       left: -4,
                                       bottom: 0,
                                       right: 0)

        contentEdgeInsets = UIEdgeInsets(top: 0,
                                         left: 8,
                                         bottom: 0,
                                         right: 8)

        imageView?.tintColor = .white
        layer.masksToBounds = true

        layer.cornerRadius = 4
        update(with: .edit)
    }
}

extension AddressBookButton: ViewConfiguration {

    func update(with model: AddressBookButton.Kind) {

        switch model {
        case .edit:
            setTitle(Localizable.Waves.Addressbookbutton.Title.editName, for: .normal)
            setImage(Images.editaddress24Submit300.image, for: .normal)
            setImage(Images.editaddress24Submit200.image, for: .highlighted)

        case .add:
            setTitle(Localizable.Waves.Addressbookbutton.Title.saveAddress, for: .normal)
            setImage(Images.addaddress24Submit300.image, for: .normal)
            setImage(Images.addaddress24Submit200.image, for: .highlighted)
        }
    }
}

