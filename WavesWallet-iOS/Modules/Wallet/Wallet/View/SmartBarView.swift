//
//  SmartButtons.swift
//  Tet
//
//  Created by rprokofev on 20.05.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import UIKit

protocol SmartButtonsDelegate: AnyObject {
    func changeSize(animated: Bool)
}

final class SmartBarView: UIView {
    private let shadowView = UIView()
    private let stackView = UIStackView()
    let sendButton = SmartBarButton()
    let receiveButton = SmartBarButton()
    let cardButton = SmartBarButton()

    private lazy var buttons: [SmartBarButton] = [sendButton, receiveButton, cardButton]

    weak var delegate: SmartButtonsDelegate?

    var percent: CGFloat = 0 {
        didSet {
            buttons.forEach { $0.percent = percent }
            shadowView.alpha = percent
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

    func setup() {
        shadowView.alpha = 0
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowView)

        shadowView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        shadowView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        shadowView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true

        clipsToBounds = false
        shadowView.clipsToBounds = false
        stackView.clipsToBounds = false
        shadowView.setupShadow(options: .init(offset: CGSize(width: 0, height: 2),
                                              color: .black,
                                              opacity: 0.12,
                                              shadowRadius: 4,
                                              shouldRasterize: true))

        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(receiveButton)
        stackView.addArrangedSubview(cardButton)

        receiveButton.widthAnchor.constraint(equalTo: sendButton.widthAnchor, constant: 0).isActive = true
        cardButton.widthAnchor.constraint(equalTo: sendButton.widthAnchor, constant: 0).isActive = true

        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal

        sendButton.setIcon(Images.send.image)
        sendButton.setTitle(Localizable.Waves.Wallet.Bar.Button.send)
        sendButton.highlightBackgroundColor = UIColor(hex: "FFAF00").withAlphaComponent(0.1)

        receiveButton.highlightBackgroundColor = UIColor(hex: "81C926").withAlphaComponent(0.1)
        receiveButton.setIcon(Images.receive.image)
        receiveButton.setTitle(Localizable.Waves.Wallet.Bar.Button.receive)

        cardButton.highlightBackgroundColor = UIColor(hex: "5A81EA").withAlphaComponent(0.1)
        cardButton.setIcon(Images.buyWithCard.image)
        cardButton.setTitle(Localizable.Waves.Wallet.Bar.Button.card)

        addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
    }

    func maxHeighBeetwinImageAndDownSide() -> CGFloat {
        return buttons
            .map { $0.heighBeetwinImageAndDownSide() }
            .max() ?? 0
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: UIView.noIntrinsicMetric)
    }
}
