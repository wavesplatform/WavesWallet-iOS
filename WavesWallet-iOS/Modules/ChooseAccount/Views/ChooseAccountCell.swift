//
//  ChouseAccountCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Extensions

final class ChooseAccountCell: MGSwipeTableCell, NibReusable {

    enum Kind {
        case chooseAccount(ChooseAccountModel)
        case migrateAccount(MigrateAccountModel)
        case myAccount(MyAccountModel)
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var iconLock: UIImageView!
    @IBOutlet private weak var leftContainerOffset: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.addTableCellShadowStyle()
    }
    
    var imageSize: CGSize {
        return imageIcon.frame.size
    }
}

extension ChooseAccountCell: ViewConfiguration {
    
    func update(with model: Kind) {
        
        
        switch model {
            
        case .chooseAccount(let model):
            labelTitle.text = model.title
            labelAddress.text = model.address
            imageIcon.image = model.image
            
        case .migrateAccount(let model):
            labelTitle.text = model.title
            labelAddress.text = model.address
            imageIcon.image = model.image
            iconLock.image = model.isLock ? Images.draglock22Disabled400.image : Images.verified14Multy.image
            
        case .myAccount(let model):

            containerView.backgroundColor = .clear
            containerView.removeTableCellShadowStyle()
            leftContainerOffset.constant = 0
            
            labelTitle.text = model.title
            labelAddress.text = model.address
            imageIcon.image = model.image
            
            if model.isSelected {
                labelTitle.font = UIFont.systemFont(ofSize: 17)
                backgroundColor = .submit4007
                iconLock.image = Images.shape.image
                iconLock.contentMode = .center
            }
            else {
                labelTitle.font = UIFont.systemFont(ofSize: 13)
                backgroundColor = .clear
                iconLock.image = model.isLock ? Images.draglock22Disabled400.image : nil
                iconLock.contentMode = .scaleAspectFit
            }
        }
    }
    
}

extension ChooseAccountCell {
    
    struct ChooseAccountModel {
        let title: String
        let address: String
        let image: UIImage?
    }
    
    struct MigrateAccountModel {
        let title: String
        let address: String
        let image: UIImage?
        let isLock: Bool
    }
    
    struct MyAccountModel {
        let title: String
        let address: String
        let image: UIImage?
        let isLock: Bool
        let isSelected: Bool
    }
}
