//
//  SuccessSystemMessageView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.35
    static let showTime: Double = 1
    
    static let height: CGFloat = 46
    static let textLeftOffset: CGFloat = 16
    static let textRightOffset: CGFloat = 5
    static let textTopOffset: CGFloat = 16
    static let textBottomOffset: CGFloat = 16
    static let fontSize: CGFloat = 13
    static let backgroundColor: UIColor = .success400
}

final class SuccessSystemMessageView: UIView {

    private var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Constants.height))
        initialize()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.center.y = frame.size.height / 2
    }
}


extension SuccessSystemMessageView {
    class func showWithMessage(_ message: String) {
        let view = SuccessSystemMessageView()
        view.setupMessage(message)
        view.animate()
        view.addToSupperView()
    }
}

private extension SuccessSystemMessageView {
    
    func initialize() {
        backgroundColor = Constants.backgroundColor
        label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: Constants.fontSize)
        label.numberOfLines = 0
        addSubview(label)
    }
    
    func setupMessage(_ message: String) {
        label.text = message
        
        let width = frame.size.width - Constants.textLeftOffset - Constants.textRightOffset
        let height = message.maxHeight(font: label.font, forWidth: width)
        label.frame = CGRect(x: Constants.textLeftOffset , y: 0, width: width, height: height)
        frame.size.height = max(height + Constants.textTopOffset + Constants.textBottomOffset, Constants.height)
        frame.origin.y = UIScreen.main.bounds.size.height - frame.size.height
    }
}

private extension SuccessSystemMessageView {
    
    func addToSupperView() {
        
        AppDelegate.shared().window?.subviews.forEach({
            if $0.isKind(of: classForCoder) {
                $0.removeFromSuperview()
            }
        })
        
        AppDelegate.shared().window?.addSubview(self)
    }
    
    func animate() {
        alpha = 0
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.alpha = 1
            
        }) { (complete) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(Int(Constants.showTime * 1000)) , execute: {
                
                UIView.animate(withDuration: Constants.animationDuration, animations: {
                    self.alpha = 0
                }, completion: { (complete) in
                    self.removeFromSuperview()
                })
            })
        }
    }
    
}
