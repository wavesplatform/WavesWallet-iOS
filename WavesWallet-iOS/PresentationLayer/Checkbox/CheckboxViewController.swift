//
//  CheckboxViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 10/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class CheckboxViewController: UIViewController {
    
    @IBOutlet weak var grayView: UIView!
    
    @IBOutlet weak var okButton: UIButton!
    var input: CheckboxModuleInput?
    
    var firstCheckboxValue: Bool = false
    var secondCheckboxValue: Bool = false
    var thirdCheckboxValue: Bool = false
    
    @IBOutlet weak var firstCheckboxView: CheckboxControl!
    
    @IBOutlet weak var thirdCheckboxView: CheckboxControl!
    @IBOutlet weak var secondCheckboxView: CheckboxControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstCheckboxView.on = firstCheckboxValue
        secondCheckboxView.on = secondCheckboxValue
        thirdCheckboxView.on = thirdCheckboxValue
        updateButton()
    }
    
    @IBAction func firstCheckboxTap(_ sender: Any) {
        firstCheckboxView.on = !firstCheckboxView.on
        firstCheckboxValue = firstCheckboxView.on
        
        updateButton()
    }
    
    @IBAction func secondCheckboxTap(_ sender: Any) {
        secondCheckboxView.on = !secondCheckboxView.on
        secondCheckboxValue = secondCheckboxView.on
        
        updateButton()
    }
    
    @IBAction func thirdCheckboxTap(_ sender: Any) {
        thirdCheckboxView.on = !thirdCheckboxView.on
        thirdCheckboxValue = thirdCheckboxView.on
        
        updateButton()
    }
    
    @IBAction func buttonTap(_ sender: Any) {
        
    }
    
    private func updateButton() {
        if firstCheckboxValue && secondCheckboxValue && thirdCheckboxValue {
            okButton.isSelected = true
            okButton.backgroundColor = UIColor(31, 90, 246)
        } else {
            okButton.isSelected = false
            okButton.backgroundColor = UIColor(186, 202, 244)
        }
    }
    
}
