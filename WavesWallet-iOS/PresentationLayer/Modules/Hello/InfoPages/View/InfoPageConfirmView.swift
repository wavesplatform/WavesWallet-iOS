//
//  InfoPageConfirmView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/6/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

protocol InfoPageConfirmViewDelegate: AnyObject {
    func infoPageConfirmView(isActive: Bool)
    func infoPageContirmViewDidTapURL(_ url: URL)
}

private enum Constants {
    static let termsOfUse = "https://wavesplatform.com/files/docs/Privacy%20Policy_SW.pdf"
    static let termsOfConditions = "https://wavesplatform.com/files/docs/Waves_terms_and_conditions.pdf"

    static let buttonDeltaWidth: CGFloat = 24
}


final class InfoPageConfirmView: UIView {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var checkBox1: UIImageView!
    @IBOutlet private weak var checkBox2: UIImageView!
    @IBOutlet private weak var checkBox3: UIImageView!
    @IBOutlet private weak var label1: UILabel!
    @IBOutlet private weak var label2: UILabel!
    @IBOutlet private weak var label3: UILabel!
    @IBOutlet private weak var buttonTermsUse: HighlightedButton!
    @IBOutlet private weak var buttonTermsConditions: HighlightedButton!
    @IBOutlet private weak var termsOfUseWidth: NSLayoutConstraint!
    @IBOutlet private weak var termsConditionsWidth: NSLayoutConstraint!
    @IBOutlet private weak var scrollView: UIScrollView!

    weak var delegate: InfoPageConfirmViewDelegate?
    
    private var isCheck1 = false
    private var isCheck2 = false
    private var isCheck3 = false
   
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
        setupCheckBoxes()
    }
    
    @IBAction private func check1Tapped(_ sender: Any) {
        isCheck1 = !isCheck1
        setupCheckBoxes()
        delegate?.infoPageConfirmView(isActive: isActive)
    }
    
    @IBAction private func check2Tapped(_ sender: Any) {
        isCheck2 = !isCheck2
        setupCheckBoxes()
        delegate?.infoPageConfirmView(isActive: isActive)
    }
    
    @IBAction private func check3Tapped(_ sender: Any) {
        isCheck3 = !isCheck3
        setupCheckBoxes()
        delegate?.infoPageConfirmView(isActive: isActive)
    }
    
    @IBAction private func termsOfUseTapped(_ sender: Any) {
        delegate?.infoPageContirmViewDidTapURL(URL(string: Constants.termsOfUse)!)
    }
    
    @IBAction private func termsOfConditionsTapped(_ sender: Any) {
        delegate?.infoPageContirmViewDidTapURL(URL(string: Constants.termsOfConditions)!)
    }
    
    private var isActive: Bool {
        return isCheck1 && isCheck2 && isCheck3
    }
    
    func setupContentInset(_ inset: UIEdgeInsets) {
        scrollView.contentInset = inset
    }
}

private extension InfoPageConfirmView {
    
    var on: UIImage {
        return Images.checkboxOn.image
    }
    
    var off: UIImage {
        return Images.checkboxOff.image
    }
    
    func setupCheckBoxes() {
        checkBox1.image = isCheck1 ? on : off
        checkBox2.image = isCheck2 ? on : off
        checkBox3.image = isCheck3 ? on : off
    }
    
    func setupLocalization() {
        labelTitle.text = Localizable.Waves.Hello.Page.Confirm.title
        labelSubtitle.text = Localizable.Waves.Hello.Page.Confirm.subtitle
        label1.text = Localizable.Waves.Hello.Page.Confirm.description1
        label2.text = Localizable.Waves.Hello.Page.Confirm.description2
        label3.text = Localizable.Waves.Hello.Page.Confirm.description3
        
        let privacyPolicyText = Localizable.Waves.Hello.Page.Confirm.Button.privacyPolicy
        let termsOfConditions = Localizable.Waves.Hello.Page.Confirm.Button.termsAndConditions
        
        buttonTermsUse.setTitle(privacyPolicyText, for: .normal)
        buttonTermsConditions.setTitle(termsOfConditions, for: .normal)
        
        guard let font = buttonTermsUse.titleLabel?.font else { return }
        termsOfUseWidth.constant = privacyPolicyText.maxWidth(font: font) + Constants.buttonDeltaWidth
        termsConditionsWidth.constant = termsOfConditions.maxWidth(font: font) + Constants.buttonDeltaWidth
    }
    
}
