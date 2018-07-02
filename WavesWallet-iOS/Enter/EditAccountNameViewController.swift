//
//  EditAccountNameViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class EditAccountNameViewController: UIViewController {

    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var labelAccountName: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBgBlueImage()
        labelAccountName.alpha = 0
        textField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        buttonSave.setupButtonDeactivateState()
    }
   
    func nameDidChange() {
        
        DataManager.setupTextFieldLabel(textField: textField, placeHolderLabel: labelAccountName)
        
        if textField.text!.count > 0 {
            buttonSave.setupButtonActiveState()
        }
        else {
            buttonSave.setupButtonDeactivateState()
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
