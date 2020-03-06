//
//  UITableViewCellContainer.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 05.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import UIKit

/// Позволяет использовать NibLoadable View'шки внутри TableView
/// Нужно создать сабкласс и в качестве Generic-параметра указывать тип View которую хочется переиспользовать
open class UITableViewXibContainerCell<T>: UITableViewContainerCell<T> where T: UIView & NibLoadable {
    open override class func makeViewInstance() -> T { T.loadFromNib() }
}

/// Позволяет использовать View'шки внутри TableView
/// Нужно создать дочерний класс и в качестве Generic-параметра указать тип View которую хочется переиспользовать
open class UITableViewContainerCell<T: UIView>: UITableViewCell, Reusable {
    public let view: T

    public var contentViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet { contentConstraints.updateWith(contentViewInsets) }
    }

    private let contentConstraints = ContainerContentConstraints()

    /// Нет необходимости вызывать super.makeViewInstance
    open class func makeViewInstance() -> T {
        T()
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        view = type(of: self).makeViewInstance()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _initialSetup()
    }

    public required convenience init?(coder _: NSCoder) {
        /// super.init(coder: aDecoder)
        /// При назначении дочерних классов в сториборде не забывать корректно указывать reuseIdentifier
        /// в качестве reuseIdentifier – название класса
        self.init(style: .default, reuseIdentifier: type(of: self).reuseIdentifier)
    }

    /// Можно опционально(если необходима какая-то настройка) перегружать этот метод для настройки.
    /// Вызывать метод Super.initialSetup нет необходимости
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
