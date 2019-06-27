//
//  WalletHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 48
}

final class WalletHeaderView: UITableViewHeaderFooterView, NibReusable {
    @IBOutlet private var buttonTap: UIButton!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var iconArrow: UIImageView!

    var arrowDidTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        buttonTap.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)
    }

    func setupArrow(isExpanded: Bool, animation: Bool) {
        let transform = isExpanded ? CGAffineTransform(rotationAngle: CGFloat.pi) : CGAffineTransform.identity

        if animation {
            UIView.animate(withDuration: 0.3) {
                self.iconArrow.transform = transform
            }
        } else {
            iconArrow.transform = transform
        }
    }

    @objc private func tapHandler() {
        arrowDidTap?()
    }
    
    class func viewHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: ViewConfiguration

extension WalletHeaderView: ViewConfiguration {
    func update(with model: String) {
        labelTitle.text = model
    }
}
