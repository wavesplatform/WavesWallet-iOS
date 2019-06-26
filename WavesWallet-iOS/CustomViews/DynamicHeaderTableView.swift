//
//  DynamicHeaderTableView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let offsetHeight: CGFloat = 0.5
}

class DynamicHeaderTableView: UITableView {

    @IBOutlet private weak var tableView: DynamicHeaderTableView!
    @IBOutlet private weak var contentView: UIView! {
        didSet {
            tableHeaderView = contentView
        }
    }

    var initialLayoutInsets: UIEdgeInsets?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableFooterView = UIView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let headerView = tableHeaderView {

            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            let top = (initialLayoutInsets?.top ?? 0)
            let bottom = (initialLayoutInsets?.bottom ?? 0)

            var newHeight = frame.height - top - bottom - Constants.offsetHeight
            newHeight =  max(height, newHeight)
            
            if headerView.frame.height != newHeight {
                headerFrame.size.height = newHeight
                headerView.frame = headerFrame
                tableHeaderView = headerView
            }
        }
    }
}
