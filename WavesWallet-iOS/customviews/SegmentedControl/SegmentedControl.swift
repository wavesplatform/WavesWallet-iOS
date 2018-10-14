//
//  WalletSegmentedView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum Constants {
    static let imageEdgeInsetsForButtonWithIcon = UIEdgeInsetsMake(0, -8, 0, 8)
    static let contentEdgeInsetsForButtonWithIcon = UIEdgeInsetsMake(0, 16, 0, 8)
    static let contentEdgeInsetsForButtonOnlyText = UIEdgeInsetsMake(0, 24, 0, 24)
    static let cornerRadius: CGFloat = 2
    static let height: CGFloat = 30
}

final class SegmentedControl: UIControl, NibOwnerLoadable {
    struct Button {
        struct Icon {
            let normal: UIImage
            let selected: UIImage
        }

        let name: String
        let icon: Icon?

        init(name: String, icon: Icon? = nil) {
            self.name = name
            self.icon = icon
        }
    }

    @IBOutlet var scrollView: SegmentedControlScrollView!
    private var model: [Button] = [Button]()

    var selectedIndex: Int {
        get {
            return scrollView.selectedButtonIndex
        } set (newValue) {
            scrollView.selectedWith(index: newValue, animated: false)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.backgroundColor = .basic50
        scrollView.changedValue = { _ in
            self.sendActions(for: .valueChanged)
            
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: Constants.height)
    }
    
    
    func setSelectedIndex(_ index: Int, animation: Bool) {
        guard selectedIndex != index else { return }
        scrollView.selectedWith(index: index, animated: true)
    }
}

// MARK: - ViewAnimatableConfiguration

extension SegmentedControl: ViewAnimatableConfiguration {
    typealias Model = [SegmentedControl.Button]

    func update(with model: [SegmentedControl.Button], animated: Bool) {
        self.model = model

        scrollView.removeAllButtons()

        model.forEach { model in
            let button = SegmentedControlButton(type: .custom)
            button.update(with: model)
            scrollView.addButton(button)
        }

        scrollView.selectedWith(index: 0, animated: false)
    }
}

// MARK: - Private Button

fileprivate final class SegmentedControlButton: UIButton, ViewConfiguration {
    private var model: SegmentedControl.Button?

    func update(with model: SegmentedControl.Button) {
        self.model = model
        setTitle(model.name, for: .normal)
        setBackgroundImage(UIColor.clear.image, for: .normal)
        setBackgroundImage(UIColor.basic100.image, for: .highlighted)
        setTitleColor(.basic500, for: .normal)
        setTitleColor(.white, for: .selected)
        titleLabel?.textAlignment = .center
        titleLabel?.font = .captionRegular

        if let icon = model.icon {
            setImage(icon.normal, for: .normal)
            setImage(icon.selected, for: .selected)
            imageEdgeInsets = Constants.imageEdgeInsetsForButtonWithIcon
            contentEdgeInsets = Constants.contentEdgeInsetsForButtonWithIcon
        } else {
            setImage(nil, for: .normal)
            setImage(nil, for: .selected)
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            contentEdgeInsets = Constants.contentEdgeInsetsForButtonOnlyText
        }

        layer.cornerRadius = Constants.cornerRadius
        autoresizingMask = .flexibleWidth
        translatesAutoresizingMaskIntoConstraints = false
    }
}
