//
//  TransactionReceiveViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import SwipeView


class TransactionHistoryViewController: UIViewController, SwipeViewDelegate, SwipeViewDataSource {

    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var arrowRight: UIButton!
    @IBOutlet weak var arrowLeft: UIButton!
    
    var hasComment = false
    var hadAddress = true
    
    var items : [NSDictionary] = []
    var currentPage = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        swipeView.delegate = self
        swipeView.dataSource = self
        
        arrowLeft.isHidden = true
        arrowRight.isHidden = true
        if items.count > 1 {
            arrowRight.isHidden = false
        }
        if currentPage > 0 {
            arrowLeft.isHidden = false
        }
        
        swipeView.currentPage = currentPage
    }

    @IBAction func leftTapped(_ sender: Any) {
        swipeView.scroll(toPage: swipeView.currentPage - 1, duration: 0.5)
    }
    
    @IBAction func rightTapped(_ sender: Any) {
        swipeView.scroll(toPage: swipeView.currentPage + 1, duration: 0.5)
    }
    
    //MARK: - SwipeViewDelegate
    
    
    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        
        if swipeView.currentPage == 0 {
            arrowLeft.isHidden = true
        }
        else if swipeView.currentPage == items.count - 1 {
            arrowRight.isHidden = true
        }
        else {
            if items.count > 1 {
                arrowRight.isHidden = false
                arrowLeft.isHidden = false
            }
        }
    }
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return items.count
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        
        var contentView : TransactionHistoryContentView! = view as? TransactionHistoryContentView
        
        if contentView == nil {
            contentView = TransactionHistoryContentView.loadView() as? TransactionHistoryContentView
            contentView.frame = swipeView.bounds
        }
        
        contentView.setup(items[index])
        
        return contentView
    }
    
    deinit {
        print(self.classForCoder, #function)
    }
}
