//
//  ConfirmBackupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


class ConfirmBackupViewController: UIViewController {

    @IBOutlet weak var viewBottomButtons: UIView!
    @IBOutlet weak var viewTopButtons: BorderButtView!
    
    @IBOutlet weak var labelTapWord: UILabel!
    
    let words = ["nigga", "wanna", "too", "get", "tothe", "close", "utmost", "but", "igot", "stacks", "that'll", "attack", "any", "wack", "host"]
    
    var inputWords : [String] = []
    
    @IBOutlet weak var viewBottomButtonsHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTopButtonsHeight: NSLayoutConstraint!
    
    var hasInit = false
    
    var bottomButtons : [UIButton] = []
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var labelError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        title = "Confirm backup"
        setupBigNavigationBar()
        hideTopBarLine()
        navigationController?.navigationBar.barTintColor = .white
        buttonConfirm.alpha = 0
        labelError.alpha = 0
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
    
    }
    
    override func viewWillLayoutSubviews() {
        initBottomWords()
    }
    
    
    func wordTapped(_ sender: UIButton) {
        
        let index = sender.tag
        
        inputWords.append(words[index])

        if labelTapWord.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.labelTapWord.alpha = 0
            }
        }
        
        zoomOut(view: sender, completion: nil)
        setupTopWords(zoomLastButton: true)
        
        if words.count == inputWords.count {
            if words == inputWords {
                viewTopButtons.isUserInteractionEnabled = false
                
                UIView.animate(withDuration: 0.3) {
                    self.viewBottomButtons.alpha = 0
                    self.buttonConfirm.alpha = 1
                }
            }
            else {
                UIView.animate(withDuration: 0.3) {
                    self.labelError.alpha = 1
                    self.viewBottomButtons.alpha = 0
                }
            }
        }
    }
    
    func removeWord(_ sender: UIButton) {
        
        let index = sender.tag
        let word = inputWords[index]
        inputWords.remove(at: index)
        
        let buttonIndex = words.index(of: word)!
        self.zoomOut(view: sender) {
            self.setupTopWords(zoomLastButton: false)
        }

        if let button = bottomButtons.first(where: {$0.tag == buttonIndex}) {
            self.zoomIn(view: button)
        }
        
        if labelError.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.labelError.alpha = 0
                self.viewBottomButtons.alpha = 1
            }
        }
    }
    
    func zoomIn(view: UIView) {
        
        UIView.animate(withDuration: 0.2) {
            view.transform = .identity
        }
    }
    
    func zoomOut(view: UIView, completion: (() -> Swift.Void)? = nil) {

        UIView.animate(withDuration: 0.2, animations: {
//            view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        }) { (complete) in
            if let completion = completion {
                completion()
            }
        }
    }

 
    func initBottomWords() {
        
        if hasInit {
            return
        }
        else if viewBottomButtons.frame.size.width == Platform.ScreenWidth - 32 {
            hasInit = true
        }
        
        var offsetX : CGFloat = 0
        var offsetY : CGFloat = 0
        let deltaX  : CGFloat = 8

        
        for view in viewBottomButtons.subviews {
            view.removeFromSuperview()
        }
        
        let view = UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight))
        viewBottomButtons.addSubview(view)
        
        for (index, word) in words.enumerated() {
            
            let button = createButton(word, isTopWords: false)
            button.frame.origin.x = offsetX
            button.addTarget(self, action: #selector(wordTapped(_:)), for: .touchUpInside)
            button.tag = index
            bottomButtons.append(button)
            
            let viewBg = BorderButtView(frame: button.frame)
            viewBg.backgroundColor = .white
            
            if button.frame.origin.x + button.frame.size.width > viewBottomButtons.frame.size.width {
                offsetY += button.frame.size.height + 14
                button.frame.origin.x = 0
                viewBg.frame.origin.x = 0
                let view = UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight))
                viewBottomButtons.addSubview(view)
            }
            
            offsetX = button.frame.origin.x + button.frame.size.width + deltaX
            lastBottomButtonSuperView.addSubview(viewBg)
            
            lastBottomButtonSuperView.addSubview(button)
            lastBottomButtonSuperView.frame.size.width = button.frame.origin.x + button.frame.size.width
        }
        
        for view in viewBottomButtons.subviews {
            view.frame.origin.x = (viewBottomButtons.frame.size.width - view.frame.size.width) / 2
        }
        if words.count == inputWords.count {
            viewBottomButtonsHeight.constant = 0
        }
        else {
            viewBottomButtonsHeight.constant = lastBottomButtonSuperView.frame.origin.y + lastBottomButtonSuperView.frame.size.height
        }
    }
    
    func setupTopWords(zoomLastButton: Bool) {
        
        for view in viewTopButtons.subviews {
            view.removeFromSuperview()
        }
        
        var offsetX : CGFloat = 0
        var offsetY : CGFloat = 14
        let deltaX  : CGFloat = 8
        
        viewTopButtons.addSubview(UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight)))

        for (index, word) in inputWords.enumerated() {
            
            let button = createButton(word, isTopWords: true)
            button.frame.origin.x = offsetX
            button.addTarget(self, action: #selector(removeWord(_:)), for: .touchUpInside)
            button.tag = index
            
            if index == inputWords.count - 1 && zoomLastButton {
                button.transform = CGAffineTransform(scaleX: 0, y: 0)
                zoomIn(view: button)
            }
            
            if button.frame.origin.x + button.frame.size.width + deltaX * 2 > viewTopButtons.frame.size.width {
                offsetY += button.frame.size.height + 14
                button.frame.origin.x = 0
                let view = UIView(frame: CGRect(x: 0, y: offsetY, width: 0, height: buttonHeight))
                viewTopButtons.addSubview(view)
            }
            
            offsetX = button.frame.origin.x + button.frame.size.width + deltaX
            lastTopButtonSuperView.addSubview(button)
            lastTopButtonSuperView.frame.size.width = button.frame.origin.x + button.frame.size.width
        }
        
        for view in viewTopButtons.subviews {
            view.frame.origin.x = (viewTopButtons.frame.size.width - view.frame.size.width) / 2
        }
        
        viewTopButtonsHeight.constant = lastTopButtonSuperView.frame.origin.y + lastTopButtonSuperView.frame.size.height + 14
        viewTopButtons.setNeedsDisplay()
    }
    
    var lastTopButtonSuperView: UIView {
        return viewTopButtons.subviews.last!
    }
    
    var lastBottomButtonSuperView: UIView {
        return viewBottomButtons.subviews.last!
    }
    
   
    var buttonHeight: CGFloat {
        return 36
    }
    
    func createButton(_ title: String, isTopWords: Bool) -> UIButton {
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
      
        if isTopWords {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.addTableCellShadowStyle()
        }
        else {
            button.backgroundColor = .submit400
            button.setTitleColor(.white, for: .normal)
        }
        
        button.layer.cornerRadius = 3
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        let width = title.maxWidth(font: button.titleLabel!.font)
        button.frame = CGRect(x: 0, y: 0, width: width + 28, height: buttonHeight)
        return button
    }
}
