//
//  HistoryTopHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/10/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol HistoryTopHeaderCellDelegate: class {
    func historyTopHeaderCellDidSelectState(_ state: HistoryViewController.HistoryState, leftDirection: Bool)
}

class HistoryTopHeaderCell: UITableViewCell {
    
    var delegate: HistoryTopHeaderCellDelegate?    
    
    @IBOutlet weak var buttonAll: UIButton!
    @IBOutlet weak var buttonSent: UIButton!
    @IBOutlet weak var buttonReceived: UIButton!
    @IBOutlet weak var buttonExchanged: UIButton!
    @IBOutlet weak var buttonLeased: UIButton!
    @IBOutlet weak var buttonIssued: UIButton!
    @IBOutlet weak var leftViewOffset: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var selectedState = HistoryViewController.HistoryState.all
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        setupButtons(selectedButton: buttonAll, animation: false)
    }

    
    func setupState(_ state: HistoryViewController.HistoryState, animation: Bool) {
        
        if selectedState == state {
            return
        }
        
        selectedState = state
       
        let containerView = scrollView.subviews.first!
        let button = containerView.subviews.first(where: {$0 is UIButton && $0.tag == state.rawValue}) as! UIButton
        setupButtons(selectedButton: button, animation: animation)
    }
    
    @IBAction func setupButtonState(_ sender: Any) {
    
        let index = (sender as! UIButton).tag
        if index == selectedState.rawValue {
            return
        }

        var leftDirection = true
        
        if index > selectedState.rawValue {
            leftDirection = false
        }

        selectedState = HistoryViewController.HistoryState(rawValue: index)!
        setupButtons(selectedButton: sender as! UIButton, animation: true)
        
        delegate?.historyTopHeaderCellDidSelectState(selectedState, leftDirection: leftDirection)
    }
    
    func setupButtons(selectedButton: UIButton, animation: Bool) {
        buttonAll.setTitleColor(UIColor.basic500, for: .normal)
        buttonSent.setTitleColor(UIColor.basic500, for: .normal)
        buttonReceived.setTitleColor(UIColor.basic500, for: .normal)
        buttonExchanged.setTitleColor(UIColor.basic500, for: .normal)
        buttonLeased.setTitleColor(UIColor.basic500, for: .normal)
        buttonIssued.setTitleColor(UIColor.basic500, for: .normal)
        
        selectedButton.setTitleColor(.white, for: .normal)
        leftViewOffset.constant = selectedButton.frame.origin.x
        
        if animation {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
            
            var offset = selectedButton.frame.origin.x - selectedButton.frame.size.width - 16
            
            if offset < 0 {
                offset = 0
            }
            else if offset > scrollView.contentSize.width - scrollView.frame.size.width {
                offset = scrollView.contentSize.width - scrollView.frame.size.width
            }
            
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    class func cellHeight() -> CGFloat {
        return 50
    }
}
