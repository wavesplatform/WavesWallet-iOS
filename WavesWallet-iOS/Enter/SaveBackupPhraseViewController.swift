//
//  SaveBackupPhraseViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class SaveBackupPhraseViewController: UIViewController {

    @IBOutlet weak var labelWords: UILabel!
    @IBOutlet weak var buttonCopy: UIButton!
    
    let words = ["nigga", "wanna", "too", "get", "tothe", "close", "utmost", "but", "igot", "stacks", "that'll", "attack", "any", "wack", "host"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Save backup phrase"
        createBackButton()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupWords()
    }

    @IBAction func copyTapped(_ sender: Any) {
        buttonCopy.isUserInteractionEnabled = false
        buttonCopy.setImage(UIImage(named: "check_success"), for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.buttonCopy.isUserInteractionEnabled = true
            self.buttonCopy.setImage(UIImage(named: "copy_address"), for: .normal)
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {

        let controller = storyboard?.instantiateViewController(withIdentifier: "ConfirmBackupViewController") as! ConfirmBackupViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func setupWords() {
        
        var text = ""
        
        for (index, word) in words.enumerated() {
            text.append(word)
            
            if index < words.count - 1 {
                text.append("   ")
            }
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 10
        paragraph.alignment = .center
        let params = [NSAttributedStringKey.paragraphStyle : paragraph]
        let attributed = NSMutableAttributedString(string: text, attributes: params)
        
        labelWords.attributedText = attributed
    }
}
