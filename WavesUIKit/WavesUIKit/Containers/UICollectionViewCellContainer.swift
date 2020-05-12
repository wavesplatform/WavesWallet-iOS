//
//  UICollectionViewCellContainer.swift
//  WavesUIKit
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import Extensions
import UIKit
import UITools

open class UICollectionViewXibContainerCell<T>: UICollectionViewContainerCell<T> where T: UIView & NibReusable {
    open override class func makeViewInstanse() -> T {
        T.loadFromNib()
    }
}

open class UICollectionViewContainerCell<T>: UICollectionViewCell, Reusable where T: UIView {
    public let view: T

    public var contentViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet { contentConstraints.updateWith(contentViewInsets) }
    }

    private let contentConstraints = ContainerContentConstraints()

    /// Do not call super when overriding this method
    open class func makeViewInstanse() -> T {
        T()
    }

    public override init(frame: CGRect) {
        view = type(of: self).makeViewInstanse()
        super.init(frame: frame)
        _initialSetup()
    }

    public required init?(coder aDecoder: NSCoder) {
        view = type(of: self).makeViewInstanse()
        super.init(coder: aDecoder)
        _initialSetup()
    }

    /// Override this method in subClasses for setup during init() time. It's not necessary to call super when overriding
    open func initialSetup() {}

    private func _initialSetup() {
        installView()
        initialSetup()
    }

    private func installView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        let superView: UIView = contentView
        superView.addSubview(view)

        let leading = view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: contentViewInsets.left)
        let trailing = superView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: contentViewInsets.right)
        let top = view.topAnchor.constraint(equalTo: superView.topAnchor, constant: contentViewInsets.top)
        let bottom = superView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: contentViewInsets.bottom)

        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        contentConstraints.leading = leading
        contentConstraints.trailing = trailing
        contentConstraints.top = top
        contentConstraints.bottom = bottom
    }
}
