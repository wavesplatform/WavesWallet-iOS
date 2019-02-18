//
//  ModalTableView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 01/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class ModalTableView: UITableView {

    private(set) lazy var backgroundModalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundModalView.frame = CGRect(x: 0,
                                           y: contentSize.height,
                                           width: bounds.width,
                                           height: max(contentSize.height, bounds.height))

        insertSubview(backgroundModalView, at: 0)
    }
}
