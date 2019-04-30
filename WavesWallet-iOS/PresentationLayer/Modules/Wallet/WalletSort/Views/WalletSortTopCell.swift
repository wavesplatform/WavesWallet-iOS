//
//  WalletSortTopCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/18/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import WavesSDKExtension

private enum Constants {
    static let height: CGFloat = 60
    static let deltaButtonWidth: CGFloat = 50
}

protocol WalletSortTopCellDelegate: AnyObject {
    
    func walletSortDidUpdateStatus(_ status: WalletSort.Status)
}

final class WalletSortTopCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var buttonPosition: UIButton!
    @IBOutlet private weak var buttonVisibility: UIButton!
    @IBOutlet private weak var buttonPositionWidth: NSLayoutConstraint!
    @IBOutlet private weak var buttonVisibilityWidth: NSLayoutConstraint!
    
    weak var delegate: WalletSortTopCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        let positionTitle = Localizable.Waves.Walletsort.Button.position
        buttonPosition.setTitle(positionTitle, for: .normal)
        
        let visibilityTitle = Localizable.Waves.Walletsort.Button.visibility
        buttonVisibility.setTitle(visibilityTitle, for: .normal)
        
        guard let font = buttonPosition.titleLabel?.font else { return }
        buttonPositionWidth.constant = positionTitle.maxWidth(font: font) + Constants.deltaButtonWidth
        buttonVisibilityWidth.constant = visibilityTitle.maxWidth(font: font) + Constants.deltaButtonWidth
    }

    @IBAction private func positionTapped(_ sender: Any) {
        delegate?.walletSortDidUpdateStatus(.position)
    }
    
    @IBAction private func visibilityTapped(_ sender: Any) {
        delegate?.walletSortDidUpdateStatus(.visibility)
    }
}

extension WalletSortTopCell: ViewConfiguration {
    
    func update(with model: WalletSort.Status) {
        
        if model == .position {
            buttonPosition.tintColor = .black
            buttonVisibility.tintColor = .basic500
        }
        else {
            buttonPosition.tintColor = .basic500
            buttonVisibility.tintColor = .black
        }
    }
}

extension WalletSortTopCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
