//
//  WalletSortFavCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

private enum Constants {
    static let height: CGFloat = 48
    static let icon: CGSize = CGSize(width: 28,
                                     height: 28)
}

final class WalletSortFavCell: UITableViewCell, Reusable {
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var buttonFav: UIButton!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var iconLock: UIImageView!
    @IBOutlet var arrowGreen: UIImageView!        
    @IBOutlet var viewContent: UIView!

    private var taskForAssetLogo: RetrieveImageDiskTask?
    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        taskForAssetLogo?.cancel()
        backgroundColor = .basic50
        contentView.backgroundColor = .basic50
        viewContent.backgroundColor = .basic50
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

extension WalletSortFavCell: ViewConfiguration {
    struct Model {
        let name: String
        let isMyAsset: Bool
        let isLock: Bool
        let isGateway: Bool
    }

    func update(with model: WalletSortFavCell.Model) {
        let cryptoName = model.name
        labelTitle.text = cryptoName
        iconLock.isHidden = !model.isLock
        arrowGreen.isHidden = !model.isGateway

        taskForAssetLogo = UIImage.assetLogoFromCache(name: cryptoName,
                                                      size: Constants.icon,
                                                      font: UIFont.systemFont(ofSize: 15)) { [weak self] image in
                                                        self?.imageIcon.image = image
        }
    }
}
