//
//  ModalTableView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 01/02/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit

class ModalTableView: UITableView {

    private(set) lazy var backgroundModalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundModalView.isUserInteractionEnabled = false
        backgroundModalView.frame = CGRect(x: 0,
                                           y: contentSize.height,
                                           width: bounds.width,
                                           height: max(contentSize.height, bounds.height))

        insertSubview(backgroundModalView, at: 0)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        if let tableHeaderView = tableHeaderView {
            let headerViewFrame = tableHeaderView.convert(tableHeaderView.frame, to: self)

            if headerViewFrame.contains(point) {
                return self
            }
        }
        
        let backgroundModalFrame = backgroundModalView.convert(backgroundModalView.frame, to: self)
        
        if backgroundModalFrame.contains(point) {
            return self
        }

        return super.hitTest(point, with: event)
    }
}
