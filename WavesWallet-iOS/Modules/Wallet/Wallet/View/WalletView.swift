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
    static let distanceForRefreshInset: CGFloat = 100
}

final class WalletView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var topLayoutConstraint: NSLayoutConstraint!

    let walletSearchView = WalletSearchView.loadFromNib()
    let smartBarView = SmartBarView()
    
    private var lastHeight: CGFloat?

    // Был ли добавлен баннер
    private var hasAddingViewBanners: Bool = false

    // инициализация Inset
    private var initUpdateContentInset: Bool = false
    // Нужна ли анимация после завершение scrollView
    private var hasNeedAnimatedNextTime: Bool = false

    var updateAppViewTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.addArrangedSubview(walletSearchView)
        stackView.addArrangedSubview(smartBarView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if initUpdateContentInset {
            return
        }
        initUpdateContentInset = true
        ifNeedUpdateContentInset()
    }

    private func ifNeedUpdateContentInset(animated: Bool = false) {
        let height = stackView.frame.height

        if let lastHeight = self.lastHeight, lastHeight == height {
            return
        }

        lastHeight = height

        let animations = {
            self.tableView.contentInset = .init(top: height, left: 0, bottom: 0, right: 0)
            self.tableView.scrollIndicatorInsets = .init(top: height, left: 0, bottom: 0, right: 0)
        }

        if animated {
            UIView.animate(withDuration: 0.18,
                           delay: 0, options: [],
                           animations: animations) { _ in }
        } else {
            animations()
        }
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

        ifNeedUpdateContentInset(animated: false)

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

    func scrollViewDidScroll(scrollView: UIScrollView, viewController: UIViewController) {
        let value = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
    
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
                           delay: 0, options: [.beginFromCurrentState],
                           animations: animations) { _ in }
        } else {
            animations()
        }

        if value < 0 {
            topLayoutConstraint.constant = abs(value)
        }

        // Если контента меньше чем экран мы не обноляем inset, а то будет прыгать offset
        if scrollView.contentSize.height > scrollView.frame.height {
            // Обновляем inset после сварачивание.
            // Зищата от частого обновление inset, так как будешь скакать как Москаль
            if value > Constants.distanceForRefreshInset {
                ifNeedUpdateContentInset(animated: false)
            }
        }

        hasNeedAnimatedNextTime = false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView, viewController _: UIViewController) {
        finish(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool, viewController _: UIViewController) {
        if willDecelerate {
            ifNeedUpdateContentInset()
            return
        }

        finish(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView, viewController _: UIViewController) {}

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView, viewController _: UIViewController) {}
}
