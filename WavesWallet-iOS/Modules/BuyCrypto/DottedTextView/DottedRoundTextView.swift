//
//  DottedRoundTextView.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 11.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UITools
import UIKit

final class DottedRoundTextView: UIView, ResetableView {
    private let dottedShapeLayer = CAShapeLayer()
    private let textView = UITextView()
    
    private var didTapLink: ((URL) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        resetToEmptyState()
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        resetToEmptyState()
        initialSetup()
    }
    
    private func initialSetup() {
        dottedShapeLayer.fillColor = UIColor.clear.cgColor
        dottedShapeLayer.lineWidth = 2
        dottedShapeLayer.lineDashPattern = [4, 4]
        dottedShapeLayer.strokeColor = UIColor.basic300.cgColor
        layer.addSublayer(dottedShapeLayer)
        
        backgroundColor = .clear
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = nil
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.delegate = self
        addStretchToBounds(textView, insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
    }
    
    func resetToEmptyState() {
        textView.attributedText = nil
    }
    
    func setAttiributedStringWithLink(_ text: NSAttributedString,
                                      didTapLink: @escaping (URL) -> Void) {
        textView.attributedText = text
        self.didTapLink = didTapLink
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 10)
        dottedShapeLayer.path = path.cgPath
    }
}

extension DottedRoundTextView: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith url: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        didTapLink?(url)
        return false
    }
}
