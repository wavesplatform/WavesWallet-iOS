//
//  CopyButton.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let duration: TimeInterval = 1
}

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
        if let copiedText = copiedText?() {
            UIPasteboard.general.string = copiedText
        }
        setTitleColor(.success400, for: .normal)
        setImage(Images.checkSuccess.image, for: .normal)
        isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.duration) {

            if self.isBlack {
                self.setTitleColor(.black, for: .normal)
                self.setImage(Images.copy18Black.image, for: .normal)
            } else {
                self.setTitleColor(.submit400, for: .normal)
                self.setImage(Images.copy18Submit400.image, for: .normal)
            }
            
            self.isUserInteractionEnabled = true
        }
    }
}
