//
//  ConfirmBackupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ConfirmBackupViewController: UIViewController, ConfirmBackupStackListViewDelegate, ConfirmBackupStackInputViewDelegate {

    @IBOutlet weak var stackListView: ConfirmBackupStackListView!
    @IBOutlet weak var stackTopView: ConfirmBackupStackInputView!
    
    @IBOutlet weak var labelTapWord: UILabel!
    
    let words = ["nigga", "wanna", "too", "get", "tothe", "close", "utmost", "but", "igot", "stacks", "that'll", "attack", "any", "wack", "host"]
    
    var inputWords : [String] = []
    
    @IBOutlet weak var stackListViewHeight: NSLayoutConstraint!
    
    
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
        
        stackListView.setupWords(words)
        stackListView.delegate = self
        stackTopView.delegate = self
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        
    }
    
    //MARK: - ConfirmBackupStackListViewDelegate
    
    func confirmBackupStackListViewDidTapWord(_ word: String) {
        stackTopView.addWord(word)
        
        if labelTapWord.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.labelTapWord.alpha = 0
            }
        }
        
        let isFullyFilled = stackTopView.words.count == stackListView.words.count
        let isCorrectFilled = stackTopView.words == stackListView.words
        
        if isFullyFilled {
            if isCorrectFilled {
                stackTopView.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.3) {
                    self.stackListView.alpha = 0
                    self.buttonConfirm.alpha = 1
                }
            }
            else {
                UIView.animate(withDuration: 0.3) {
                    self.labelError.alpha = 1
                    self.stackListView.alpha = 0
                }
            }
        }
    }
    
    
    //MARK: - ConfirmBackupStackInputViewDelegate
    
    func confirmBackupStackInputViewDidRemoveWord(_ word: String) {
        stackListView.showWord(word)
        
        if labelError.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.labelError.alpha = 0
                self.stackListView.alpha = 1
            }
        }
    }

    
}
