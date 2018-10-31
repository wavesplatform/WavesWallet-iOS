//
//  CopyButton.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class PasteboardButton: UIButton {

    @IBInspectable var isBlack: Bool = true {
        didSet {
            if isBlack {
                setImage(Images.copy18Black.image, for: .normal)
            } else {
                setImage(Images.copy18Submit400.image, for: .normal)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isBlack = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(copyTapped(_:)), for: .touchUpInside)
    }

    var copiedText: (() -> String?)?

    @IBAction func copyTapped(_ sender: UIButton) {

        ImpactFeedbackGenerator.impactOccurred()
        UIPasteboard.general.string = copiedText?()

        setImage(Images.checkSuccess.image, for: .normal)
        isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

            if self.isBlack {
                self.setImage(Images.copy18Black.image, for: .normal)
            } else {
                self.setImage(Images.copy18Submit400.image, for: .normal)
            }
            
            self.isUserInteractionEnabled = true
        }
    }
}
