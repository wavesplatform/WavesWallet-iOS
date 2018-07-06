//
//  ConfirmBackupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ConfirmBackupViewController: UIViewController {

    @IBOutlet weak var viewTapButtons: UIView!
    @IBOutlet weak var viewInputButtons: BorderButtView!
    
    let words = ["nigga", "wanna", "too", "get", "tothe", "close", "utmost", "but", "igot", "stacks", "that'll", "attack", "any", "wack", "host"]
    
    var inputWords : [String] = []
    
    @IBOutlet weak var viewTapButtonsHeight: NSLayoutConstraint!
    @IBOutlet weak var viewInputButtonsHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        title = "Confirm backup"
        setupBigNavigationBar()
        hideTopBarLine()
        navigationController?.navigationBar.barTintColor = .white
    }
    
    func wordTapped(_ sender: UIButton) {
        
        let index = sender.tag
        inputWords.append(words[index])
        setupWords()
    }
    
    func removeWord(_ sender: UIButton) {
        
        let index = sender.tag
        inputWords.remove(at: index)
        setupWords()
    }
    
    func setupWords() {
        
        for view in viewTapButtons.subviews {
            view.removeFromSuperview()
        }
        
        for view in viewInputButtons.subviews {
            view.removeFromSuperview()
        }
        
        var offsetX : CGFloat = 0
        var offsetY : CGFloat = 0
        let deltaX  : CGFloat = 8

        let view = UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight))
        viewTapButtons.addSubview(view)

        for (index, word) in words.enumerated() {
            
            let button = createButton(word, isTapMode: false)
            button.frame.origin.x = offsetX
            button.addTarget(self, action: #selector(wordTapped(_:)), for: .touchUpInside)
            button.tag = index
            
            if button.frame.origin.x + button.frame.size.width + deltaX * 2 > viewTapButtons.frame.size.width {
                offsetY += button.frame.size.height + 14
                button.frame.origin.x = 0
                let view = UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight))
                viewTapButtons.addSubview(view)
            }

            offsetX = button.frame.origin.x + button.frame.size.width + deltaX
            lastButtonSuperView.addSubview(button)
            lastButtonSuperView.frame.size.width = button.frame.origin.x + button.frame.size.width
        }
        
        for view in viewTapButtons.subviews {
            view.frame.origin.x = (viewTapButtons.frame.size.width - view.frame.size.width) / 2
        }
        if words.count == inputWords.count {
            viewTapButtonsHeight.constant = 0
        }
        else {
            viewTapButtonsHeight.constant = lastButtonSuperView.frame.origin.y + lastButtonSuperView.frame.size.height
        }
        
        
        offsetY = 14
        offsetX = 0
        viewInputButtons.addSubview(UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight)))

        for (index, word) in inputWords.enumerated() {
            
            let button = createButton(word, isTapMode: true)
            button.frame.origin.x = offsetX
            button.addTarget(self, action: #selector(removeWord(_:)), for: .touchUpInside)
            button.tag = index
            
            if button.frame.origin.x + button.frame.size.width + deltaX * 2 > viewInputButtons.frame.size.width {
                offsetY += button.frame.size.height + 14
                button.frame.origin.x = 0
                let view = UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight))
                viewInputButtons.addSubview(view)
            }
            
            offsetX = button.frame.origin.x + button.frame.size.width + deltaX
            lastInputButtonSuperView.addSubview(button)
            lastInputButtonSuperView.frame.size.width = button.frame.origin.x + button.frame.size.width
        }
        
        for view in viewInputButtons.subviews {
            view.frame.origin.x = (viewInputButtons.frame.size.width - view.frame.size.width) / 2
        }
        
        viewInputButtonsHeight.constant = lastInputButtonSuperView.frame.origin.y + lastInputButtonSuperView.frame.size.height + 14
        viewInputButtons.setNeedsDisplay()
        
    }
    
    var lastInputButtonSuperView: UIView {
        return viewInputButtons.subviews.last!
    }
    
    var lastButtonSuperView: UIView {
        return viewTapButtons.subviews.last!
    }
    
    override func viewWillLayoutSubviews() {
        setupWords()
    }
    
    var buttonHeight: CGFloat {
        return 36
    }
    
    func createButton(_ title: String, isTapMode: Bool) -> UIButton {
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
      
        if isTapMode {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.addTableCellShadowStyle()
        }
        else {
            if inputWords.contains(title) {
                button.backgroundColor = .white
                button.setTitleColor(.white, for: .normal)
            }
            else {
                button.backgroundColor = .submit400
                button.setTitleColor(.white, for: .normal)
            }
        }
        
        button.layer.cornerRadius = 3
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        let width = title.maxWidth(font: button.titleLabel!.font)
        button.frame = CGRect(x: 0, y: 0, width: width + 28, height: buttonHeight)
        return button
    }
}
