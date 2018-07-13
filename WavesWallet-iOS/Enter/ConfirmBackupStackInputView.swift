//
//  ConfirmBackupStackTopView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol ConfirmBackupStackInputViewDelegate: class {
    
    func confirmBackupStackInputViewDidRemoveWord(_ word: String)
}

class ConfirmBackupStackInputView : ConfirmBackupStackBaseView {
 
    var delegate: ConfirmBackupStackInputViewDelegate?
    
    var errorMode = false
    
    var words: [String] = []

    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0.5, y: 0.5, width: frame.size.width - 1, height: frame.size.height - 1), cornerRadius: 3)
        path.lineWidth = 0.5
        let dashes: [CGFloat] = [6, 4]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = CGLineCap.butt
        
        if errorMode {
            UIColor.error500.setStroke()
        }
        else {
            UIColor.basic300.setStroke()
        }
        path.stroke()
    }
    
    
    func addWord(_ word: String) {
        words.append(word)
        setupWords(zoomLastButton: true)
    }

    func removeWord(_ sender: UIButton) {
        
        let word = words[sender.tag]
        self.words.remove(at: sender.tag)
        self.delegate?.confirmBackupStackInputViewDidRemoveWord(word)

        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { (complete) in
            self.isUserInteractionEnabled = true
            DispatchQueue.main.async {
                self.setupWords(zoomLastButton: false)
            }
        }
        
    }
    
    func setupWords(zoomLastButton: Bool) {
        
        for view in subviews {
            view.removeFromSuperview()
        }
        
        var offsetX : CGFloat = 0
        var offsetY : CGFloat = 14
        let deltaX  : CGFloat = 8
        
        addEmptyInputContainerView(offsetY: offsetY)

        for (index, word) in words.enumerated() {
            
            let button = createButton(word, isBlueWord: false)
            button.frame.origin.x = offsetX
            button.addTarget(self, action: #selector(removeWord(_:)), for: .touchUpInside)
            button.tag = index
            
            if index == words.count - 1 && zoomLastButton {
                button.transform = CGAffineTransform(scaleX: 0, y: 0)
                UIView.animate(withDuration: 0.2) {
                    button.transform = .identity
                }
            }
            
            if button.frame.origin.x + button.frame.size.width + deltaX * 2 > frame.size.width {
                offsetY += button.frame.size.height + self.buttonContainerOffset
                button.frame.origin.x = 0
                addEmptyInputContainerView(offsetY: offsetY)
            }
            
            offsetX = button.frame.origin.x + button.frame.size.width + deltaX
            lastButtonContainer.addSubview(button)
            lastButtonContainer.frame.size.width = button.frame.origin.x + button.frame.size.width
        }
        
        for view in subviews {
            view.frame.origin.x = (frame.size.width - view.frame.size.width) / 2
        }
        
        self.heightConstraint.constant = lastButtonContainer.frame.origin.y + lastButtonContainer.frame.size.height + 14
        setNeedsDisplay()
    }

}
