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
    var shadowView = UIView()
    var stackView = UIStackView()
    var sendButton = SmartBarButton()
    var receiveButton = SmartBarButton()
    var cardButton = SmartBarButton()

    private lazy var buttons: [SmartBarButton] = [sendButton, receiveButton, cardButton]
    
    weak var delegate: SmartButtonsDelegate?

    var percent: CGFloat = 0 {
        didSet {
            buttons.forEach { $0.percent = percent }
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
        
//        addSubview(shadowView)
        
//        spaceView.heightAnchor.constraint
        
        let spaceView = UIView()
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        let spaceViewSecond = UIView()
        spaceViewSecond.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(spaceView)
        stackView.addArrangedSubview(receiveButton)
        stackView.addArrangedSubview(spaceViewSecond)
        stackView.addArrangedSubview(cardButton)
        
        spaceView.widthAnchor.constraint(equalTo: spaceViewSecond.widthAnchor, constant: 0).isActive = true

        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.addArrangedSubview(UIView())

        sendButton.setIcon(Images.send.image)
        sendButton.setTitle("Receive")
        receiveButton.setIcon(Images.receive.image)
        receiveButton.setTitle("Send")
        cardButton.setIcon(Images.buyWithCard.image)
        cardButton.setTitle("Card")

        addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
    }

    func setPercent(percent: CGFloat) {
        buttons.forEach { $0.percent = percent }

        updateConstraintsIfNeeded()
        layoutIfNeeded()
    }
    
    func maxHeighBeetwinImageAndDownSide() -> CGFloat {
        return buttons
            .map { $0.heighBeetwinImageAndDownSide() }
            .max() ?? 0
    }

    func close() {
        UIView.animate(withDuration: 0.24) {
            self.buttons.forEach { $0.percent = 1 }
            self.updateConstraintsIfNeeded()
            self.layoutIfNeeded()
        }
    }

    func open() {
        UIView.animate(withDuration: 0.24) {
            self.buttons.forEach { $0.percent = 0 }
            self.updateConstraintsIfNeeded()
            self.layoutIfNeeded()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: UIView.noIntrinsicMetric)
    }
}
