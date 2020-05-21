//
//  ButtonView.swift
//  Tet
//
//  Created by rprokofev on 20.05.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit

private enum Constants {
    static let topImagePadding: CGFloat = 10
    static let bottomTitlePadding: CGFloat = 10
    static let bottomExpandTitlePadding: CGFloat = 4
    static let topTitlePadding: CGFloat = 6
    static let leftRightTitlePadding: CGFloat = 32
}

final class SmartBarButton: UIView {
    private let substrateView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    private var topImageConstraint: NSLayoutConstraint?
    private var leftImageConstraint: NSLayoutConstraint?
    private var rightImageConstraint: NSLayoutConstraint?
    private var bottomImageToButtonConstraint: NSLayoutConstraint?

    private var topTitleConstraint: NSLayoutConstraint?
    private var bottomTitleConstraint: NSLayoutConstraint?
    private var leftTitleConstraint: NSLayoutConstraint?
    private var rightTitleConstraint: NSLayoutConstraint?

    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))

    var percent: CGFloat = 0 {
        didSet {
            updateDraw()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: UIView.noIntrinsicMetric)
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
        updateDraw()
    }

    func setIcon(_ icon: UIImage) {
        imageView.image = icon
        updateDraw()
    }
    
    func heighBeetwinImageAndDownSide() -> CGFloat {
        return calculateHeightText() + Constants.topTitlePadding
    }

    @objc private func didTap(tap: UITapGestureRecognizer) {
        switch tap.state {
        case .began:
            titleLabel.textColor = .lightText
            substrateView.backgroundColor = .lightGray

        case .ended:
            ImpactFeedbackGenerator.impactOccurredOrVibrate()
            titleLabel.textColor = .black
            substrateView.backgroundColor = .white
        default:
            titleLabel.textColor = .black
            substrateView.backgroundColor = .white
        }
    }

    private func calculateHeightText() -> CGFloat {

        let maxSizeTitle = CGSize(width: frame.width - Constants.leftRightTitlePadding,
                                  height: CGFloat.greatestFiniteMagnitude)

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byWordWrapping

        let string = NSMutableAttributedString(string: titleLabel.text ?? "")

        string.addAttributes([NSAttributedString.Key.font: titleLabel.font ?? UIFont(),
                              .paragraphStyle: style], range: NSRange(location: 0, length: string.string.count))

        let size = titleLabel.attributedText?.boundingRect(with: maxSizeTitle,
                                                           options: [NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                     NSStringDrawingOptions.usesDeviceMetrics],
                                                           context: nil).height ?? 0

        return CGFloat(ceilf(Float(size)))
    }

    
    // В зависимочти от percent мы интерполируем значение для позиции и параметров view
    private func updateDraw() {
        let invertPercent = (1 - percent)

        let ceilSize = calculateHeightText()

        let topTitle = Constants.topTitlePadding - (ceilSize + Constants.topTitlePadding) * percent
        let bottomTitle = Constants.bottomTitlePadding + Constants.bottomExpandTitlePadding * invertPercent

        topTitleConstraint?.constant = topTitle
        bottomTitleConstraint?.constant = bottomTitle

        if percent == 0 {
            substrateView.transform = CGAffineTransform.identity
            titleLabel.transform = CGAffineTransform.identity
        } else {
            substrateView.transform = CGAffineTransform(scaleX: invertPercent, y: invertPercent)
                .concatenating(CGAffineTransform(translationX: 0,
                                                 y: -imageView.frame.size.height * 0.5 * percent))
            titleLabel.transform = CGAffineTransform(scaleX: invertPercent, y: invertPercent)
                .concatenating(CGAffineTransform(translationX: 0,
                                                 y: -imageView.frame.size.height * 0.5 * percent))
        }

        substrateView.alpha = CGFloat(1 - percent)
        titleLabel.alpha = invertPercent

        updateConstraintsIfNeeded()
        layoutIfNeeded()
    }

    private func setup() {
        addGestureRecognizer(tapGesture)

        substrateView.backgroundColor = .white
        substrateView.translatesAutoresizingMaskIntoConstraints = false
        substrateView.cornerRadius = 10
        substrateView.setupShadow(options: .init(offset: CGSize(width: 0, height: 2),
                                                 color: .black,
                                                 opacity: 0.10,
                                                 shadowRadius: 4,
                                                 shouldRasterize: true))
        addSubview(substrateView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        addSubview(titleLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        bringSubviewToFront(imageView)
//        imageView.layer.zPosition = 666

        substrateView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        substrateView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        substrateView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        substrateView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true

        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        leftImageConstraint = imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 28)
        rightImageConstraint = imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -28)
        topImageConstraint = topAnchor.constraint(equalTo: imageView.topAnchor, constant: -Constants.topImagePadding)
        bottomImageToButtonConstraint = bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0)

        leftImageConstraint?.isActive = true
        rightImageConstraint?.isActive = true
        topImageConstraint?.isActive = true

        leftTitleConstraint = titleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor, constant: 0)
        rightTitleConstraint = titleLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                                                 constant: -Constants.leftRightTitlePadding)

        topTitleConstraint = titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                                             constant: Constants.topTitlePadding)

        bottomTitleConstraint = bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                        constant: Constants.bottomTitlePadding)

        leftTitleConstraint?.isActive = true
        rightTitleConstraint?.isActive = true
        topTitleConstraint?.isActive = true
        bottomTitleConstraint?.isActive = true
    }
}
