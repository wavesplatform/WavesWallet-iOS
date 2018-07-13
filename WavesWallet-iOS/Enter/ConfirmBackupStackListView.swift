//
//  ConfirmBackupStackListView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol ConfirmBackupStackListViewDelegate: class {
    
    func confirmBackupStackListViewDidTapWord(_ word: String)
}

class ConfirmBackupStackListView: ConfirmBackupStackBaseView {

    var delegate: ConfirmBackupStackListViewDelegate?
    
    var words: [String] = []
    
    var buttons: [UIButton] = []
    
    var leftStackListOffset : CGFloat = 16
   
    
    func updateContainerFrame() {

        var height: CGFloat = 0
        for (index, container) in self.subviews.enumerated() {
            let isNotEmptyContainer = container.subviews.filter({$0.frame.size.height == self.buttonHeight && $0.isKind(of: UIButton.classForCoder())}).count > 0
            
            if isNotEmptyContainer {
                height += self.buttonHeight
                
                if index + 1 < self.subviews.count {
                    
                    var isNotEmptyNextContainer = false
                    for i in index + 1..<self.subviews.count {
                        let nextContainer = self.subviews[i]
                        isNotEmptyNextContainer = nextContainer.subviews.filter({$0.frame.size.height == self.buttonHeight && $0.isKind(of: UIButton.classForCoder())}).count > 0
                        if isNotEmptyNextContainer {
                            height += self.buttonContainerOffset
                            break
                        }
                    }
                }
            }
        }
        
        self.heightConstraint.constant = height

        UIView.animate(withDuration: 0.2, animations: {
            var offsetY : CGFloat = 0
            for container in self.subviews {

                let count = container.subviews.filter({$0.frame.size.height == self.buttonHeight && $0.isKind(of: UIButton.classForCoder())}).count
                container.frame.size.height = count > 0 ? self.buttonHeight : 0
                container.frame.origin.y = offsetY

                if count > 0 {
                    offsetY = container.frame.origin.y + container.frame.size.height + self.buttonContainerOffset
                }
            }
            self.superview?.layoutIfNeeded()
        })
    }
    
    @objc func wordTapped(_ sender: UIButton) {
        
        let word = words[sender.tag]
       
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { (complete) in
            self.updateContainerFrame()
        }

        delegate?.confirmBackupStackListViewDidTapWord(word)
    }
    
    
    func showWord(_ word: String) {
        let index = words.index(of: word)!
        let button = buttons[index]
        
        UIView.animate(withDuration: 0.2, animations: {
            button.transform = .identity

        }) { (complete) in
            self.updateContainerFrame()
        }
    }
    
    func setupWords(_ words: [String]) {
        self.words = words
        
        var offsetX : CGFloat = 0
        var offsetY : CGFloat = 0
        let deltaX  : CGFloat = 8
        
        for view in subviews {
            view.removeFromSuperview()
        }
        buttons.removeAll()
        
        addEmptyListContainerView(offsetY: offsetY)
        
        for (index, word) in words.enumerated() {
            
            let button = createButton(word, isBlueWord: true)
            button.frame.origin.x = offsetX
            button.addTarget(self, action: #selector(wordTapped(_:)), for: .touchUpInside)
            button.tag = index
            buttons.append(button)
            
            let viewBg = BorderButtView(frame: button.frame)
            viewBg.backgroundColor = .white
            
            if button.frame.origin.x + button.frame.size.width > mainViewWidth {
                offsetY += button.frame.size.height + 14
                button.frame.origin.x = 0
                viewBg.frame.origin.x = 0
                addEmptyListContainerView(offsetY: offsetY)
            }
            
            offsetX = button.frame.origin.x + button.frame.size.width + deltaX
            lastButtonContainer.addSubview(viewBg)

            lastButtonContainer.addSubview(button)
            lastButtonContainer.frame.size.width = button.frame.origin.x + button.frame.size.width
        }
        
        for view in subviews {
            view.frame.origin.x = (mainViewWidth - view.frame.size.width) / 2
        }
        
        heightConstraint.constant = lastButtonContainer.frame.origin.y + lastButtonContainer.frame.size.height
    }
  
    var mainViewWidth : CGFloat {
        return  Platform.ScreenWidth - (leftStackListOffset * 2)
    }
}
