//
//  WelcomeScreenInfoView.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import UITools

final class WelcomeScreenTermOfConditionsView: UIView, NibLoadable, ResetableView {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!

    @IBOutlet private weak var privacyPolicyCheckbox: CheckboxButton!
    @IBOutlet private weak var privacyPolicyTextView: UITextView!

    @IBOutlet private weak var termOfConditionCheckbox: CheckboxButton!
    @IBOutlet private weak var termOfConditionTextView: UITextView!

    private var didScroll: ((CGPoint) -> Void)?
    private var didTapUrl: ((URL) -> Void)?
    private var didHasReadPolicyAndTerms: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        resetToEmptyState()
        initialSetup()
    }

    ///
    public func setTitleText(_ titleText: String, detailsText: String, image: UIImage) {
        titleLabel.text = titleText
        detailsLabel.text = detailsText
        imageView.image = image
    }

    ///
    public func setPrivacyPolicyText(_ privacyPolicyText: NSAttributedString?,
                                     termOfConditionText: NSAttributedString?,
                                     didTapUrl: @escaping (URL) -> Void,
                                     didHasReadPolicyAndTerms: @escaping (Bool) -> Void) {
        if let privacyPolicyText = privacyPolicyText, let termOfConditionText = termOfConditionText {
            privacyPolicyTextView.attributedText = privacyPolicyText
            termOfConditionTextView.attributedText = termOfConditionText
        } else {
            privacyPolicyCheckbox.isHidden = true
            privacyPolicyTextView.isHidden = true
            
            termOfConditionCheckbox.isHidden = true
            termOfConditionTextView.isHidden = true
        }
        
        self.didTapUrl = didTapUrl
        self.didHasReadPolicyAndTerms = didHasReadPolicyAndTerms
    }
    
    /// Костыльный способ узнать насколько вниз спустился скролл чтобы подвинуть круг
    public func setScrollViewDidScroll(_ didScroll: @escaping (CGPoint) -> Void) {
        self.didScroll = didScroll
    }

    func resetToEmptyState() {
        imageView.image = nil
        titleLabel.text = nil
        detailsLabel.text = nil
        privacyPolicyCheckbox.resetToEmptyState()
        privacyPolicyTextView.text = nil
        termOfConditionCheckbox.resetToEmptyState()
        termOfConditionTextView.text = nil
        
        privacyPolicyCheckbox.isHidden = false
        privacyPolicyTextView.isHidden = false
        
        termOfConditionCheckbox.isHidden = false
        termOfConditionTextView.isHidden = false

        didTapUrl = nil
        didHasReadPolicyAndTerms = nil
        
        scrollView.contentInset.bottom = 0
    }

    private func initialSetup() {
        scrollView.isScrollEnabled = false
        scrollView.delegate = self
        
        imageView.contentMode = .scaleAspectFit

        titleLabel.font = .titleH1
        titleLabel.textColor = .submit400
        titleLabel.numberOfLines = 0

        detailsLabel.font = .bodyRegular // 16 нет в дизайн системе, ее надо привести в порядок
        detailsLabel.textColor = .black
        detailsLabel.numberOfLines = 0

        privacyPolicyTextView.delegate = self
        privacyPolicyTextView.isScrollEnabled = false
        privacyPolicyTextView.isEditable = false
        privacyPolicyTextView.showsVerticalScrollIndicator = false
        privacyPolicyTextView.showsHorizontalScrollIndicator = false

        termOfConditionTextView.delegate = self
        termOfConditionTextView.isScrollEnabled = false
        termOfConditionTextView.isEditable = false
        termOfConditionTextView.showsVerticalScrollIndicator = false
        termOfConditionTextView.showsHorizontalScrollIndicator = false

        privacyPolicyCheckbox.addTarget(self, action: #selector(didTapCheckbox), for: .touchUpInside)
        termOfConditionCheckbox.addTarget(self, action: #selector(didTapCheckbox), for: .touchUpInside)
    }

    @objc private func didTapCheckbox() {
        didHasReadPolicyAndTerms?(privacyPolicyCheckbox.isChecked && termOfConditionCheckbox.isChecked)
    }
}

extension WelcomeScreenTermOfConditionsView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll?(scrollView.contentOffset)
    }
}

extension WelcomeScreenTermOfConditionsView: UITextViewDelegate {
    func textView(_: UITextView,
                  shouldInteractWith URL: URL,
                  in _: NSRange,
                  interaction _: UITextItemInteraction) -> Bool {
        didTapUrl?(URL)
        return false
    }
}
