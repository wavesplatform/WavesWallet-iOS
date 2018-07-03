//
//  HistoryLeasedTopHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class HistoryLeasedTopHeaderCell: UITableViewCell {

    var delegate: HistoryTopHeaderCellDelegate?

    @IBOutlet weak var buttonActiveNow: UIButton!
    @IBOutlet weak var buttonCanceled: UIButton!
    @IBOutlet weak var buttonAll: UIButton!
    
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var leftViewOffset: NSLayoutConstraint!
    @IBOutlet weak var viewContainer: UIView!
    
    var selectedState = HistoryViewController.HistoryState.all

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        if Platform.isIphone5 {
            buttonWidth.constant = 90
        }
        
        setupButtons(selectedButton: buttonAll, animation: false)
    }

    func setupState(_ state: HistoryViewController.HistoryState, animation: Bool) {
        
        if selectedState == state {
            return
        }
        
        selectedState = state
        
        if state == .all {
            setupButtons(selectedButton: buttonAll, animation: animation)
        }
        else if state == .activeNow {
            setupButtons(selectedButton: buttonActiveNow, animation: animation)
        }
        else if state == .canceled {
            setupButtons(selectedButton: buttonCanceled, animation: animation)
        }
    }
    
    
    @IBAction func actionTapped(_ sender: Any) {
        
        let button = sender as! UIButton
        var newState : HistoryViewController.HistoryState!
        
        if button == buttonAll {
            newState = .all
        }
        else if button == buttonActiveNow {
            newState = .activeNow
        }
        else if button == buttonCanceled {
            newState = .canceled
        }
        
        if newState == selectedState {
            return
        }

        var leftDirection = true
        
        if newState.rawValue > selectedState.rawValue {
            leftDirection = false
        }
        
        selectedState = newState

        setupButtons(selectedButton: sender as! UIButton, animation: true)
        delegate?.historyTopHeaderCellDidSelectState(selectedState, leftDirection: leftDirection)
    }
    
    func setupButtons(selectedButton: UIButton, animation: Bool) {
        buttonAll.setTitleColor(UIColor.basic500, for: .normal)
        buttonActiveNow.setTitleColor(UIColor.basic500, for: .normal)
        buttonCanceled.setTitleColor(UIColor.basic500, for: .normal)
        
        selectedButton.setTitleColor(.white, for: .normal)
        leftViewOffset.constant = selectedButton.frame.origin.x
        
        if animation {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    
}
