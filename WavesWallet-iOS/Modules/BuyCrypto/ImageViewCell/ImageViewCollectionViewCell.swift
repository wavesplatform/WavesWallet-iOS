//
//  ImageViewCollectionViewcell.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 21.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import WavesUIKit

final class ImageViewCollectionViewCell: UICollectionViewContainerCell<UIImageView> {
    
    override func initialSetup() {
        view.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        view.image = nil
    }
}
