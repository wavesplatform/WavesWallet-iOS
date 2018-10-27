//
//  CopyButton.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class PasteboardButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setImage(Images.copy18Black.image, for: .normal)
        self.addTarget(self, action: #selector(copyTapped(_:)), for: .touchUpInside)
    }

    var copiedText: (() -> String?)?

    @IBAction func copyTapped(_ sender: UIButton) {

        ImpactFeedbackGenerator.impactOccurred()
        UIPasteboard.general.string = copiedText?()

        setImage(Images.checkSuccess.image, for: .normal)
        isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.setImage(Images.copy18Black.image, for: .normal)
            self.isUserInteractionEnabled = true
        }
    }
}
