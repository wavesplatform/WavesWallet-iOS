//
//  WelcomeScreenInfoView.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import UITools

final class WelcomeScreenInfoView: UIView, NibLoadable, ResetableView {
    public static let cacheNib = WelcomeScreenInfoView.nib

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        resetToEmptyState()
        initialSetup()
    }
    
    public func setTitleText(_ titleText: String, detailsText: String, image: UIImage) {
        titleLabel.text = titleText
        detailsLabel.text = detailsText
        imageView.image = image
    }

    func resetToEmptyState() {
        imageView.image = nil
        titleLabel.text = nil
        detailsLabel.text = nil
    }

    private func initialSetup() {
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .titleH1
        titleLabel.textColor = .submit400
        
        detailsLabel.font = .bodyRegular // 16 нет в дизайн системе, ее надо привести в порядок
        detailsLabel.textColor = .black
    }
}
