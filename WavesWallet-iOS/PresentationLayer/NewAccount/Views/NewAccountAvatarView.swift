//
//  NewAccountAvatarView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class NewAccountAvatarView: DottedRoundView, NibOwnerLoadable  {

    enum State {
        case none
        case selected
        case unselected
    }

    struct Model {
        let icon: UIImage
        let key: String
    }

    @IBOutlet private var iconImageView: UIImageView!

    private(set) var key: String?
    var avatarDidTap: ((NewAccountAvatarView, String) -> Void)?
    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(recognizer:)))

    var state: State = .none {
        didSet {
            lineWidth = 1.0 / UIScreen.main.scale
            switch state {
            case .none:
                isHiddenDottedLine = false
                lineColor = .accent100
                iconImageView.backgroundColor = UIColor.basic200.withAlphaComponent(0.3)
                iconImageView.alpha = 1

            case .selected:
                isHiddenDottedLine = false
                lineColor = .submit400
                iconImageView.backgroundColor = UIColor.basic200
                iconImageView.alpha = 1

            case .unselected:
                isHiddenDottedLine = true
                iconImageView.backgroundColor = UIColor.basic200
                iconImageView.alpha = 0.3
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
        loadNibContent()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.cornerRadius = Float(iconImageView.frame.width * 0.5)
    }

    var iconSize: CGSize {
        return iconImageView.frame.size
    }

    @objc private func tapHandler(recognizer: UIGestureRecognizer) {
        guard state != .selected else { return }
        guard let key = key else { return }

        state = .selected
        avatarDidTap?(self, key)
    }
}

// MARK: UIGestureRecognizerDelegate
extension NewAccountAvatarView: UIGestureRecognizerDelegate {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: ViewConfiguration

extension NewAccountAvatarView: ViewConfiguration {
    func update(with model: Model) {
        iconImageView.image = model.icon
        key = model.key
    }
}
