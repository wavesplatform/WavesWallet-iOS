//
//  WalletSortFavCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import RxSwift
import UIKit

fileprivate enum Constants {
    static let height: CGFloat = 48
    static let icon: CGSize = CGSize(width: 28, height: 28)
    static let sponsoredIcon = CGSize(width: 12, height: 12)
}

final class WalletSortFavCell: UITableViewCell, Reusable {
    @IBOutlet private var imageIcon: UIImageView!
    @IBOutlet var buttonFav: UIButton!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var iconLock: UIImageView!
    @IBOutlet private var viewContent: UIView!

    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
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
        let icon: DomainLayer.DTO.Asset.Icon
        let isSponsored: Bool
    }

    func update(with model: WalletSortFavCell.Model) {
        let cryptoName = model.name
        labelTitle.text = cryptoName
        iconLock.isHidden = !model.isLock

        let sponsoredSize = model.isSponsored ? Constants.sponsoredIcon : nil

        AssetLogo.logo(icon: model.icon,
                       style: AssetLogo.Style(size: Constants.icon,
                                              sponsoredSize: sponsoredSize,
                                              font: UIFont.systemFont(ofSize: 15),
                                              border: nil))
            .bind(to: imageIcon.rx.imageAnimationFadeIn)
            .disposed(by: disposeBag)        

    }
}
