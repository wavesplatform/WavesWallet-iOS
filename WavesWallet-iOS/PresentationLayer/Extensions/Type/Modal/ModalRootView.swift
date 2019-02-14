//
//  ModalRootView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 01/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private struct Constants {
    static let cornerRadius: CGFloat = 12
    static let headerHeight: CGFloat = 24
    static let dragElemTopMargin: CGFloat = 6
}

final class ModalRootView: UIView, ModalScrollViewRootView {

    @IBOutlet private(set) var tableView: ModalTableView!

    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let image = UIImageView(image: Images.dragElem.image)
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: image.topAnchor, constant: -Constants.dragElemTopMargin),
                                     view.centerXAnchor.constraint(equalTo: image.centerXAnchor, constant: 0)])

        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.layer.cornerRadius = Constants.cornerRadius
        setupHeaderView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let headerTopY = max(self.layoutInsets.top, -(self.tableView.contentOffset.y - self.layoutInsets.top))
        var frame = CGRect(x: 0,
                           y: headerTopY,
                           width: tableView.frame.size.width,
                           height: Constants.headerHeight)
        frame.origin.y = headerTopY

        self.headerView.frame = frame


        self.tableView.scrollIndicatorInsets.top = max(0, -(self.tableView.contentOffset.y))
    }

    private func setupHeaderView() {

        let fakeHeaderView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.frame = CGRect(x: 0, y: 0, width: 0, height: Constants.headerHeight)
            view.layer.cornerRadius = Constants.cornerRadius
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return view
        }()

        tableView.tableHeaderView = fakeHeaderView
        tableView.superview?.insertSubview(headerView, aboveSubview: tableView)
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }
}
