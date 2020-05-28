//
//  WalletView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let heightSeparator: CGFloat = 40
}

final class WalletView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var topLayoutConstraint: NSLayoutConstraint!

    let walletSearchView = WalletSearchView.loadFromNib()
    let smartBarView = SmartBarView()

    private var hasAddingViewBanners: Bool = false

    private var isContentInsetInit: Bool = false

    private var hasNeedAnimatedNextTime: Bool = false

    var updateAppViewTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.addArrangedSubview(walletSearchView)
        stackView.addArrangedSubview(smartBarView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isContentInsetInit {
            return
        }
        isContentInsetInit = true
        tableView.contentInset = .init(top: ceil(stackView.frame.height + 24), left: 0, bottom: 0, right: 0)
    }

    func showAppStoreBanner() {
        guard hasAddingViewBanners == false else { return }
        hasAddingViewBanners = true

        let view = UpdateAppView.loadFromNib()
        stackView.insertArrangedSubview(view, at: 0)

        view.viewTapped = { [weak self] in
            self?.updateAppViewTapped?()
        }
    }

    private func finish(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.y + scrollView.adjustedContentInset.top

        var percent: CGFloat = 0.0

        if value - Constants.heightSeparator > 0 {
            percent = (value - Constants.heightSeparator) / smartBarView.maxHeighBeetwinImageAndDownSide()
        }

        percent = min(1.0, percent)
        percent = max(0, percent)

        // Если преждевремено закрыли бар, то мы в следущем движенем пальцем должны про анимировать
        hasNeedAnimatedNextTime = percent != 0 && percent != 1

        let animations = {
            if percent > 0.34 {
                self.smartBarView.percent = 1
            } else {
                self.smartBarView.percent = 0
            }
        }

        UIView.animate(withDuration: 0.18,
                       delay: 0, options: [],
                       animations: animations) { _ in }
    }

    func scrollViewDidScroll(scrollView: UIScrollView, viewController _: UIViewController) {
        let value = ceil(scrollView.contentOffset.y) + ceil(scrollView.adjustedContentInset.top)

        let height = smartBarView.maxHeighBeetwinImageAndDownSide()

        var percent: CGFloat = 0.0

        if value - Constants.heightSeparator > 0 {
            percent = (value - Constants.heightSeparator) / height
        }
        percent = min(1.0, percent)
        percent = max(0.0, percent)

        let animations = {
            self.smartBarView.percent = percent
        }

        if hasNeedAnimatedNextTime {
            UIView.animate(withDuration: 0.18,
                           delay: 0, options: [],
                           animations: animations) { _ in }
        } else {
            animations()
        }

        if value < 0 {
            topLayoutConstraint.constant = abs(value)
        }

        hasNeedAnimatedNextTime = false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView, viewController _: UIViewController) {
        finish(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool, viewController _: UIViewController) {
        if willDecelerate {
            return
        }

        finish(scrollView)
    }

    func scrollViewWillBeginDragging(_: UIScrollView, viewController _: UIViewController) {}

    func scrollViewWillBeginDecelerating(_: UIScrollView, viewController _: UIViewController) {}
}
