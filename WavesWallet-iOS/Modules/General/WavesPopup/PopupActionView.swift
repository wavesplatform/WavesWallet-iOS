//
//  PopupActionView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 2/15/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let defaultBottomOffset: CGFloat = 24

    enum Shadow {
        static let offset = CGSize(width: 0, height: 4)
        static let opacity: Float = 0.2
        static let shadowRadius: Float = 4
    }
}

class PopupActionView<Model>: UIView, NibLoadable, ViewConfiguration {
    @IBOutlet private weak var viewBackground: UIView!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var bottomOffset: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        viewContainer.setupShadow(options: .init(offset: Constants.Shadow.offset,
                                                 color: .black,
                                                 opacity: Constants.Shadow.opacity,
                                                 shadowRadius: Constants.Shadow.shadowRadius,
                                                 shouldRasterize: true))
    }

    func setupInitialAnimationPoition() {
        viewBackground.alpha = 0
        bottomOffset.constant = initialViewPosition
        layoutIfNeeded()
        bottomOffset.constant = Constants.defaultBottomOffset
        UIView.animate(withDuration: Constants.animationDuration) {
            self.viewBackground.alpha = 1
            self.layoutIfNeeded()
        }
    }

    private var initialViewPosition: CGFloat {
        return -(viewContainer.frame.size.height + Constants.defaultBottomOffset)
    }

    func dismiss() {
        bottomOffset.constant = initialViewPosition

        UIView.animate(withDuration: Constants.animationDuration,
                       animations: {
                        self.viewBackground.alpha = 0
                        self.layoutIfNeeded()
        },
                       completion: { _ in self.removeFromSuperview() })
    }

    open func update(with _: Model) {}

    class func show(model: Model) -> Self {
        let view = loadFromNib()
        view.update(with: model)
        view.frame = UIScreen.main.bounds
        view.layoutIfNeeded()
        AppDelegate.shared().window?.addSubview(view)
        view.setupInitialAnimationPoition()
        return view
    }
}

extension PopupActionView where Model == Void {
    class func show() -> Self {
        return show(model: ())
    }
}
