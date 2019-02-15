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
}

protocol ModalRootViewDelegate {

    func modalHeaderView() -> UIView

    func modalHeaderHeight() -> CGFloat
}

final class ModalRootView: UIView, ModalScrollViewRootView {

    @IBOutlet private(set) var tableView: ModalTableView!

    private var headerView: UIView?

    private var headerHeight: CGFloat = 0

    var delegate: ModalRootViewDelegate? {
        didSet {
            setupHeaderView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.layer.cornerRadius = Constants.cornerRadius
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let headerTopY = max(self.layoutInsets.top, -(self.tableView.contentOffset.y - self.layoutInsets.top))
        var frame = CGRect(x: 0,
                           y: headerTopY,
                           width: tableView.frame.size.width,
                           height: self.headerHeight)
        frame.origin.y = headerTopY

        self.headerView?.frame = frame


        self.tableView.scrollIndicatorInsets.top = max(0, -(self.tableView.contentOffset.y))
    }

    private func setupHeaderView() {

        guard let headerView = self.delegate?.modalHeaderView() else { return }
        self.headerHeight = self.delegate?.modalHeaderHeight() ?? 0
        self.headerView = headerView

        let fakeHeaderView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.frame = CGRect(x: 0, y: 0, width: 0, height: self.headerHeight)
            view.layer.cornerRadius = headerView.layer.cornerRadius
            view.layer.maskedCorners = headerView.layer.maskedCorners
            return view
        }()

        tableView.tableHeaderView = fakeHeaderView
        tableView.superview?.insertSubview(headerView, aboveSubview: tableView)
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }
}
