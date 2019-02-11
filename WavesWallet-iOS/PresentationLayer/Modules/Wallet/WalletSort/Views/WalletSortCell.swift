//
//  WalletSortCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import RxSwift
import UIKit

fileprivate enum Constants {
    static let height: CGFloat = 56
    static let icon: CGSize = CGSize(width: 28,
                                     height: 28)
}

final class WalletSortCell: UITableViewCell, Reusable {
    @IBOutlet var buttonFav: UIButton!
    @IBOutlet private var imageIcon: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var iconMenu: UIImageView!
    @IBOutlet private var switchControl: UISwitch!
    @IBOutlet private var viewContent: UIView!

    private var isDragging: Bool = false

    private var taskForAssetLogo: DispatchWorkItem?
    private(set) var disposeBag = DisposeBag()
    private var isHiddenAsset: Bool = false
    var changedValueSwitchControl: ((Bool) -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        taskForAssetLogo?.cancel()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
        backgroundColor = .basic50
        contentView.backgroundColor = .basic50
        iconMenu.isHidden = true
        viewContent.addTableCellShadowStyle()        
        switchControl.addTarget(self, action: #selector(changedValueSwitchAction), for: .valueChanged)
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }

     @objc private func changedValueSwitchAction() {
        changedValueSwitchControl?(switchControl.isOn)

        isHiddenAsset = !switchControl.isOn
        updateBackground()
    }

    
    func beginMove() {
        self.viewContent.removeShadow()
    }

    func endMove() {
        updateBackground()
    }

    func updateBackground() {
        if self.isHiddenAsset {
            viewContent.backgroundColor = .clear
            viewContent.removeShadow()
        } else {
            viewContent.backgroundColor = .white
            viewContent.addTableCellShadowStyle()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.alpha <= 0.9 && !isDragging {
            isDragging = true
            beginMove()
        }

        if self.alpha <= 0.9 && isDragging {
            isDragging = false
            endMove()
        }

    }
}

// MARK: ViewConfiguration
extension WalletSortCell: ViewConfiguration {
    struct Model {
        let name: String
        let isMyWavesToken: Bool
        let isVisibility: Bool
        let isHidden: Bool
        let isGateway: Bool
        let icon: DomainLayer.DTO.Asset.Icon
    }

    func update(with model: Model) {

        labelTitle.attributedText = NSAttributedString.styleForMyAssetName(assetName: model.name,
                                                                           isMyAsset: model.isMyWavesToken)
        switchControl.isHidden = model.isVisibility
        switchControl.isOn = !model.isHidden

        isHiddenAsset = model.isHidden
        if model.isHidden {
            viewContent.backgroundColor = .clear
            viewContent.removeShadow()
        } else {
            viewContent.backgroundColor = .white
            viewContent.addTableCellShadowStyle()
        }

        taskForAssetLogo = AssetLogo.logo(url: model.icon,
                                          style: AssetLogo.Style(size: Constants.icon,
                                                                 font: UIFont.systemFont(ofSize: 15),
                                                                 border: nil)) { [weak self] image in
                                                                    self?.imageIcon.image = image
        }
    }
}
