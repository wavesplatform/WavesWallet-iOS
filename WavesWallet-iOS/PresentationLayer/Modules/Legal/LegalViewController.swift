//
//  CheckboxViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 10/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import TTTAttributedLabel

private enum Constants {
    static let containerTopConstraint: CGFloat = 20
    static let termsAndConditionsUrl: String = "https://wavesplatform.com/files/docs/Waves_terms_and_conditions.pdf"
    
    enum Animation {
        static let durationTransition: TimeInterval = 0.4
        static let springWithDamping: CGFloat = 0.94
        static let initialSpringVelocity: CGFloat = 15
    }
}


final class LegalViewController: UIViewController {
    
    var documentViewer: UIDocumentInteractionController!
    
    @IBOutlet weak var box: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var okButton: UIButton!
    weak var output: LegalModuleOutput?
    
    @IBOutlet weak var firstCheckboxView: CheckboxControl!
    @IBOutlet weak var thirdCheckboxView: CheckboxControl!
    @IBOutlet weak var secondCheckboxView: CheckboxControl!
    
    var firstCheckboxValue: Bool = false
    var secondCheckboxValue: Bool = false
    var thirdCheckboxValue: Bool = false

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var firstLabel: TTTAttributedLabel!
    @IBOutlet weak var secondLabel: TTTAttributedLabel!
    @IBOutlet weak var thirdLabel: TTTAttributedLabel!
    
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    
    var presenting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    okButton.setTitle(Localizable.Waves.Legal.Checkbox.Box.Button.confirm, for: .normal)
        titleLabel.text = Localizable.Waves.Legal.Checkbox.Box.title
        subTitleLabel.text = Localizable.Waves.Legal.Checkbox.Box.subtitle

        setupBox()
        addGestureRecognizers()
        
        setupData()
        fillLabels()
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        if Platform.isIphone5 {
            contentWidthConstraint.constant = Platform.ScreenWidth - 32
        } else {
            contentWidthConstraint.constant = 343
        }
    }
    
    private func setupBox() {
        box.layer.shadowColor = UIColor(white: 0, alpha: 0.14).cgColor
        box.layer.shadowOffset = .init(width: 0, height: 6)
        box.layer.shadowRadius = 6
        box.layer.shadowOpacity = 1
        box.layer.masksToBounds = false
    }
    
    private func setupData() {
        firstCheckboxView.on = firstCheckboxValue
        secondCheckboxView.on = secondCheckboxValue
        thirdCheckboxView.on = thirdCheckboxValue
        updateButton()
    }
    
    private func addGestureRecognizers() {
        let firstGesture = UITapGestureRecognizer(target: self, action: #selector(firstCheckboxTap(_:)))
        firstGesture.cancelsTouchesInView = false
        firstGesture.delegate = self
        firstLabel.addGestureRecognizer(firstGesture)
        
        let secondGesture = UITapGestureRecognizer(target: self, action: #selector(secondCheckboxTap(_:)))
        secondGesture.cancelsTouchesInView = false
        secondGesture.delegate = self
        secondLabel.addGestureRecognizer(secondGesture)
        
        let thirdGesture = UITapGestureRecognizer(target: self, action: #selector(thirdCheckboxTap(_:)))
        thirdGesture.cancelsTouchesInView = false
        thirdGesture.delegate = self
        thirdLabel.addGestureRecognizer(thirdGesture)
    }
    
    // MARK: - Actions
    
    @IBAction func firstCheckboxTap(_ sender: Any) {
        firstCheckboxView.on = !firstCheckboxView.on
        firstCheckboxValue = firstCheckboxView.on
        
        updateButton()
    }
    
    @IBAction func secondCheckboxTap(_ sender: Any) {
        secondCheckboxView.on = !secondCheckboxView.on
        secondCheckboxValue = secondCheckboxView.on
        
        updateButton()
    }
    
    @IBAction func thirdCheckboxTap(_ sender: Any) {
        thirdCheckboxView.on = !thirdCheckboxView.on
        thirdCheckboxValue = thirdCheckboxView.on
        
        updateButton()
    }
    
    @IBAction func buttonTap(_ sender: Any) {
        dismiss(animated: true)
        output?.legalConfirm()    
    }
    
    // MARK: - Content
    
    private func fillLabels() {
        firstLabel.text = Localizable.Waves.Legal.Checkbox.Box.first
        secondLabel.text = Localizable.Waves.Legal.Checkbox.Box.second
        
        secondLabel.activeLinkAttributes = linkAttributes()
        secondLabel.linkAttributes = linkAttributes()
        firstLabel.activeLinkAttributes = linkAttributes()
        firstLabel.linkAttributes = linkAttributes()

        let firstCount = firstLabel.attributedText.string.count
        let secondCount = secondLabel.attributedText.string.count

        firstLabel.addLink(to: URL(string: "https://apple.com/"), with: NSRange.init(location: 0, length: firstCount))
        secondLabel.addLink(to: URL(string: "https://apple.com/"), with: NSRange.init(location: 0, length: secondCount))
        
        let termsString = Localizable.Waves.Legal.Checkbox.Box.termsOfUse
        let thirdString = Localizable.Waves.Legal.Checkbox.Box.third + " " + termsString

        thirdLabel.text = thirdString
        
        thirdLabel.linkAttributes = [NSAttributedStringKey.underlineColor.rawValue: UIColor.black.cgColor,
            NSAttributedStringKey.underlineStyle.rawValue: true]
        
        let range = (thirdString as NSString).range(of: termsString)
        thirdLabel.addLink(to: URL(string: Constants.termsAndConditionsUrl), with: range)
    
        firstLabel.delegate = self
        secondLabel.delegate = self
        thirdLabel.delegate = self
    }
    
    private func updateButton() {
        if firstCheckboxValue && secondCheckboxValue && thirdCheckboxValue {
            okButton.isEnabled = true
            okButton.backgroundColor = .submit400
        } else {
            okButton.isEnabled = false
            okButton.backgroundColor = .submit200
        }
    }
    
}

extension LegalViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
}

extension LegalViewController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.Animation.durationTransition
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        
        let containerFrame = containerView.frame
        
        if let toView = toView {
            containerView.addSubview(toView)
            toView.frame = containerFrame
        }
        
        if presenting {
            grayView.alpha = 0
            self.containerView.alpha = 0
            containerTopConstraint.constant = -containerFrame.height
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: Constants.Animation.springWithDamping, initialSpringVelocity: Constants.Animation.initialSpringVelocity, options: [.curveEaseOut], animations: {
            
            if self.presenting {
                self.containerTopConstraint.constant = Constants.containerTopConstraint
                self.view.layoutIfNeeded()
            }
            
        })
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseOut], animations: {

            if self.presenting {
                self.grayView.alpha = 1
                self.containerView.alpha = 1
            } else {
                self.grayView.alpha = 0
                self.containerView.alpha = 0
                self.containerTopConstraint.constant = -containerFrame.height
            }
            self.view.layoutIfNeeded()
            
        }) { (success) in
            
            if !self.presenting && success {
                toView?.removeFromSuperview()
            }
            
            transitionContext.completeTransition(success)
        }
        
    }
    
    // Helpers
    
    private func linkAttributes() -> [AnyHashable: Any]{
        return
            [
            NSAttributedStringKey.underlineColor.rawValue: UIColor.black.cgColor,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.black.cgColor,
            NSAttributedStringKey.underlineStyle.rawValue: false
            ]
    }
    
}


extension LegalViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        if url.absoluteString == Constants.termsAndConditionsUrl {
            output?.showViewController(viewController: BrowserViewController(url: url))
            return
        }
        
        if label == firstLabel {
            firstCheckboxTap(self)
        } else if label == secondLabel {
            secondCheckboxTap(self)
        }
        
    }
    
}

// MARK: - Gesture

extension LegalViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer.view == thirdLabel {
            return (thirdLabel.link(at: touch.location(in: thirdLabel)) == nil)
        }
        
        return true
        
    }
    
}
