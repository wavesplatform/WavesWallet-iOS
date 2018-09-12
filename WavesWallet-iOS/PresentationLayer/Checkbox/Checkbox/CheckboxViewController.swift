//
//  CheckboxViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 10/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let containerTopConstraint: CGFloat = 20
    
    enum Animation {
        static let durationTransition: TimeInterval = 0.4
        static let springWithDamping: CGFloat = 0.94
        static let initialSpringVelocity: CGFloat = 15
    }
}

final class CheckboxViewController: UIViewController {
    
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
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdTextView: UITextView!
    
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    var presenting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupTextView()
        addGestureRecognizers()
        setupData()
    }
    
    private func setupTextView() {
        thirdTextView.contentInset = .zero
        thirdTextView.textContainerInset = .zero
        thirdTextView.textContainer.lineFragmentPadding = 0
        thirdTextView.isSelectable = false
    }
    
    private func setupData() {
        firstCheckboxView.on = firstCheckboxValue
        secondCheckboxView.on = secondCheckboxValue
        thirdCheckboxView.on = thirdCheckboxValue
        updateButton()
    }
    
    private func addGestureRecognizers() {
        let firstTap = UIGestureRecognizer(target: self, action: #selector(firstCheckboxTap(_:)))
        firstLabel.isUserInteractionEnabled = true
        firstLabel.addGestureRecognizer(firstTap)
        
        let secondTap = UIGestureRecognizer(target: self, action: #selector(secondCheckboxTap(_:)))
        secondLabel.addGestureRecognizer(secondTap)
        
        let thirdTap = UIGestureRecognizer(target: self, action: #selector(thirdCheckboxTap(_:)))
        thirdTextView.addGestureRecognizer(thirdTap)
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
        
        let termsString = Localizable.Checkbox.Box.termsOfUse
        let thirdString = Localizable.Checkbox.Box.third + " " + termsString
        let attributedString = NSMutableAttributedString(string: thirdString)
        
        let range = (thirdString as NSString).range(of: termsString)
        
        attributedString.addAttribute(NSAttributedStringKey.link, value: Localizable.Checkbox.Box.termsOfUse, range: range)
        
        // так, оставь пока)
//        thirdTextView.linkTextAttributes = [kCTUnderlineStyleAttributeName as String: NSUnderlineStyle.styleSingle]
        
        thirdTextView.attributedText = attributedString
  
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
    
}

extension CheckboxViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
    
}
