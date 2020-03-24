//
//  ModalTableView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 01/02/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit

private struct Constants {
    static let cornerRadius: CGFloat = 12
}

class ModalTableView: UITableView {

    private(set) lazy var backgroundModalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Constants.cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundModalView.frame = CGRect(x: 0,
                                           y: 0,
                                           width: bounds.width,
                                           height: max(contentSize.height, bounds.height) * 2)

        insertSubview(backgroundModalView, at: 0)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let tableHeaderView = tableHeaderView {
            let headerViewFrame = tableHeaderView.convert(tableHeaderView.frame, to: self)

            if headerViewFrame.contains(point) {
                return self
            }
        }

        return super.hitTest(point, with: event)
    }
}
