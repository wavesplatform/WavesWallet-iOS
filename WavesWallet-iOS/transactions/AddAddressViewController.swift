//
//  HistoryEditAddressViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/31/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol AddAddressViewControllerDelegate: class {
    
    func addAddressViewControllerDidBack()
}

class AddAddressViewController: UIViewController, UITextFieldDelegate {

    var delegate: AddAddressViewControllerDelegate?
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTextFieldName: UILabel!
    
    @IBOutlet weak var buttonSaveBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    
    var isAddMode = false
    
    
    // UI cases
    var showTabBarOnBack = false
    var showNavBarOnBack = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        labelTitle.text = isAddMode ? "Add" : "Edit"
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        textFieldName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        if isAddMode {
            buttonDelete.isHidden = true
            labelTextFieldName.alpha = 0
        }
        else {
            buttonSaveBottomOffset.constant = 96
            textFieldName.text = "Mr. Big Mike"
        }
        setupButtonSave()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
    
        let controller = UIAlertController(title: "Do you really want to delete the address?", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
        }
        controller.addAction(cancel)
        controller.addAction(delete)
        present(controller, animated: true, completion: nil)
    }
    
    func setupButtonSave () {
        if textFieldName.text!.count > 0 {
            buttonSave.isUserInteractionEnabled = true
            buttonSave.backgroundColor = .submit400
        }
        else {
            buttonSave.isUserInteractionEnabled = false
            buttonSave.backgroundColor = .submit200
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange() {
        
        let isShowName = textFieldName.text!.count > 0
        
        if isShowName {
            if labelTextFieldName.alpha == 0 {
                UIView.animate(withDuration: 0.3) {
                    self.labelTextFieldName.alpha = 1
                }
            }
        }
        else {
            if labelTextFieldName.alpha > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.labelTextFieldName.alpha = 0
                }
            }
        }
        
        setupButtonSave()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        delegate?.addAddressViewControllerDidBack()
        
        if showTabBarOnBack {
            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
        navigationController?.popViewController(animated: true)
        
        if showNavBarOnBack {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

}
