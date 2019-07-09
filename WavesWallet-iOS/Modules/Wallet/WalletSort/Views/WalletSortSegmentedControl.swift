//
//  WalletSortHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import WavesSDKExtensions

private enum Constants {
    static let deltaButtonWidth: CGFloat = 50
}

protocol WalletSortSegmentedControlDelegate: AnyObject {
    
    func walletSortSegmentedControlDidChangeStatus(_ status: WalletSort.Status)
}

final class WalletSortSegmentedControl: UIView, NibOwnerLoadable {

    @IBOutlet private weak var buttonPosition: UIButton!
    @IBOutlet private weak var buttonVisibility: UIButton!
    @IBOutlet weak var buttonPositionWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonVisibilityWidth: NSLayoutConstraint!
    
    weak var delegate: WalletSortSegmentedControlDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        addShadow()
        
        let positionTitle = Localizable.Waves.Walletsort.Button.position
        buttonPosition.setTitle(positionTitle, for: .normal)
        
        let visibilityTitle = Localizable.Waves.Walletsort.Button.visibility
        buttonVisibility.setTitle(visibilityTitle, for: .normal)
        
        guard let font = buttonPosition.titleLabel?.font else { return }
        buttonPositionWidth.constant = positionTitle.maxWidth(font: font) + Constants.deltaButtonWidth
        buttonVisibilityWidth.constant = visibilityTitle.maxWidth(font: font) + Constants.deltaButtonWidth
    }
    
    @IBAction private func visibilityTapped(_ sender: Any) {
        delegate?.walletSortSegmentedControlDidChangeStatus(.visibility)
    }
    
    @IBAction private func positionTapped(_ sender: Any) {
        delegate?.walletSortSegmentedControlDidChangeStatus(.position)
    }
    
    func addShadow() {
        if layer.shadowColor == nil {
            setupShadow(options: .init(offset: CGSize(width: 0, height: 4),
                                       color: .black,
                                       opacity: 0.10,
                                       shadowRadius: 3,
                                       shouldRasterize: true))
            
        }
    }
    
}

extension WalletSortSegmentedControl: ViewConfiguration {
    
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
