//
//  SaveBackupPhraseViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol SaveBackupPhraseOutput: AnyObject {
    func userSavedBackupPhrase()
}

struct SaveBackupPhraseInput {
    let seed: [String]
    let isReadOnly: Bool
}

private enum Constants {
    static let copyDelay: TimeInterval = 2
    static let lineSpacingForWords: CGFloat = 10
}

final class SaveBackupPhraseViewController: UIViewController {

    @IBOutlet private weak var labelWords: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var titleForCopyLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var buttonCopy: UIButton!

    var input: SaveBackupPhraseInput?
    weak var output: SaveBackupPhraseOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        if input?.isReadOnly ?? false {
            nextButton.isHidden = true
            infoLabel.isHidden = true
        }

        title =  Localizable.Waves.Backup.Backup.Navigation.title
        titleLabel.text = Localizable.Waves.Backup.Savebackup.Label.title
        titleForCopyLabel.text = Localizable.Waves.Backup.Savebackup.Copy.Label.title
        infoLabel.text = Localizable.Waves.Backup.Savebackup.Next.Label.title
        nextButton.setTitle(Localizable.Waves.Backup.Savebackup.Next.Button.title, for: .normal)

        createBackButton()
        setupBigNavigationBar()
        navigationItem.shadowImage = UIImage()
        navigationItem.backgroundImage = UIImage()        
        nextButton.setBackgroundImage(UIColor.submit300.image, for: .highlighted)
        nextButton.setBackgroundImage(UIColor.submit400.image, for: .normal)
        setupWords()
    }

    @IBAction func copyTapped(_ sender: Any) {
        buttonCopy.isUserInteractionEnabled = false
        buttonCopy.setImage(Images.checkSuccess.image, for: .normal)
        UIPasteboard.general.string = (input?.seed ?? []).joined(separator: " ")
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.copyDelay) {
            self.buttonCopy.isUserInteractionEnabled = true
            self.buttonCopy.setImage(Images.copyAddress.image, for: .normal)
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        output?.userSavedBackupPhrase()
    }
    
    private func setupWords() {

        let words = input?.seed ?? []

        var text = ""
        
        for (index, word) in words.enumerated() {
            text.append(word)
            
            if index < words.count - 1 {
                text.append("   ")
            }
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Constants.lineSpacingForWords
        paragraph.alignment = .center
        let params = [NSAttributedString.Key.paragraphStyle : paragraph]
        let attributed = NSMutableAttributedString(string: text, attributes: params)
        
        labelWords.attributedText = attributed
    }
}
