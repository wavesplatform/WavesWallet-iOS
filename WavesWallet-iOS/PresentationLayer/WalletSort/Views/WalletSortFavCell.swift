//
//  WalletSortFavCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Kingfisher
import RxSwift
import UIKit

fileprivate enum Constants {
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
        let isMyWavesToken: Bool
        let isLock: Bool
        let isGateway: Bool
        let icon: String
    }

    func update(with model: WalletSortFavCell.Model) {
        let cryptoName = model.name
        labelTitle.text = cryptoName
        iconLock.isHidden = !model.isLock
        arrowGreen.isHidden = !model.isGateway

        taskForAssetLogo = AssetLogo.logoFromCache(name: model.icon,
                                                   style: AssetLogo.Style(size: Constants.icon,
                                                                          font: UIFont.systemFont(ofSize: 15),
                                                                          border: nil)) { [weak self] image in
            self?.imageIcon.image = image
        }
    }
}
