//
//  ConfirmBackupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol ConfirmBackupOutput: AnyObject {
    func userConfirmBackup()
}

struct ConfirmBackupInput {
    let seed: [String]
}

final class ConfirmBackupViewController: UIViewController, ConfirmBackupStackListViewDelegate, ConfirmBackupStackInputViewDelegate {

    @IBOutlet private weak var stackListView: ConfirmBackupStackListView!
    @IBOutlet private weak var stackTopView: ConfirmBackupStackInputView!
    @IBOutlet private weak var labelTapWord: UILabel!
    @IBOutlet private weak var stackListViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var buttonConfirm: UIButton!
    @IBOutlet private weak var labelError: UILabel!

    private var inputWords : [String] = []
    private var words: [String] {
         return input?.seed ?? []
    }
    var input: ConfirmBackupInput?
    weak var output: ConfirmBackupOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Backup.Confirmbackup.Navigation.title
        labelTapWord.text = Localizable.Backup.Confirmbackup.Info.label
        labelError.text = Localizable.Backup.Confirmbackup.Error.label
        buttonConfirm.setTitle(Localizable.Backup.Confirmbackup.Button.confirm, for: .normal)

        buttonConfirm.setBackgroundImage(UIColor.submit300.image, for: .highlighted)
        buttonConfirm.setBackgroundImage(UIColor.submit400.image, for: .normal)

        createBackButton()
        setupBigNavigationBar()
        hideTopBarLine()
        navigationController?.navigationBar.barTintColor = .white
        buttonConfirm.alpha = 1
        labelError.alpha = 1
        
        var sortedSortds = words
        sortedSortds.shuffle()
        
        stackListView.setupWords(sortedSortds)
        stackListView.delegate = self
        stackTopView.delegate = self
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        output?.userConfirmBackup()
    }
    
    //MARK: - ConfirmBackupStackListViewDelegate
    
    func confirmBackupStackListViewDidTapWord(_ word: String) {
        stackTopView.addWord(word)
        
        if labelTapWord.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.labelTapWord.alpha = 0
            }
        }
        
        let isFullyFilled = stackTopView.words.count == words.count
        let isCorrectFilled = stackTopView.words == words
        
        if isFullyFilled {
            if isCorrectFilled {
                stackTopView.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.3) {
                    self.stackListView.alpha = 0
                    self.buttonConfirm.alpha = 1
                }
            } else {
                stackTopView.errorMode = true
                stackTopView.setNeedsDisplay()
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
        
        if stackTopView.errorMode {
            stackTopView.errorMode = false
            stackTopView.setNeedsDisplay()
        }

        if stackTopView.words.count == 0 {
            UIView.animate(withDuration: 0.3) {
                self.labelTapWord.alpha = 1
            }
        }
        
        if labelError.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.labelError.alpha = 0
                self.stackListView.alpha = 1
            }
        }
    }
}
