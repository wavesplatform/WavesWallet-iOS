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

final class CheckboxViewController: UIViewController {
    
    var documentViewer: UIDocumentInteractionController!
    
    @IBOutlet weak var box: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var okButton: UIButton!
    var input: CheckboxModuleInput?
    
    @IBOutlet weak var firstCheckboxView: CheckboxControl!
    
    @IBOutlet weak var thirdCheckboxView: CheckboxControl!
    @IBOutlet weak var secondCheckboxView: CheckboxControl!
    
    var firstCheckboxValue: Bool = false
    var secondCheckboxValue: Bool = false
    var thirdCheckboxValue: Bool = false
    
    @IBOutlet weak var firstLabel: TTTAttributedLabel!
    @IBOutlet weak var secondLabel: TTTAttributedLabel!
    @IBOutlet weak var thirdLabel: TTTAttributedLabel!
    
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    var presenting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupBox()
        addGestureRecognizers()
        setupData()
        fillLabels()
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
        
        dismiss(animated: true) {
            
        }
        
    }
    
    // MARK: - Content
    
    private func fillLabels() {
        firstLabel.text = Localizable.Checkbox.Box.first
        secondLabel.text = Localizable.Checkbox.Box.second
        
        secondLabel.activeLinkAttributes = linkAttributes()
        secondLabel.linkAttributes = linkAttributes()
        firstLabel.activeLinkAttributes = linkAttributes()
        firstLabel.linkAttributes = linkAttributes()
 
        firstLabel.addLink(to: URL(string: "https://apple.com/"), with: .init(location: 0, length: firstLabel.text!.count))
        secondLabel.addLink(to: URL(string: "https://apple.com/"), with: .init(location: 0, length: secondLabel.text!.count))
        
        let termsString = Localizable.Checkbox.Box.termsOfUse
        let thirdString = Localizable.Checkbox.Box.third + " " + termsString

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
            okButton.backgroundColor = UIColor(31, 90, 246)
        } else {
            okButton.isEnabled = false
            okButton.backgroundColor = UIColor(186, 202, 244)
        }
    }
    
}

extension CheckboxViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
}

extension CheckboxViewController: UIViewControllerAnimatedTransitioning {
    
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

extension CheckboxViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
    
}

extension CheckboxViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        if url.absoluteString == Constants.termsAndConditionsUrl {
            let browser = BrowserViewController(url: url)
            let navigationController = UINavigationController(rootViewController: browser)
            
            present(navigationController, animated: true)
            return
        }
        
        if label == firstLabel {
            firstCheckboxTap(self)
        } else if label == secondLabel {
            secondCheckboxTap(self)
        } else if label == thirdLabel {
            thirdCheckboxTap(self)
        }
       
        
    }
    
}


