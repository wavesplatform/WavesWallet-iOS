//
//  DexContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class DexContainerViewController: UIViewController, UIScrollViewDelegate {

    var orderBookController : OrderBookViewController!
    var chartController : ChartViewController!
    var lastTraderController : LastTradersViewController!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewLeadingOffset: NSLayoutConstraint!
    
    @IBOutlet weak var buttonOrderBook: UIButton!
    @IBOutlet weak var buttonChart: UIButton!
    @IBOutlet weak var buttonLastTraders: UIButton!
    
    var selectedPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Test"
        view.backgroundColor = AppColors.dexNavBarColor
        orderBookTapped(buttonOrderBook)
    
        scrollView.isScrollEnabled = false
        
        orderBookController = storyboard?.instantiateViewController(withIdentifier: "OrderBookViewController") as! OrderBookViewController
        addChildViewController(orderBookController)
        scrollView.addSubview(orderBookController.view)
        orderBookController.didMove(toParentViewController: self)
        
        chartController = storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        addChildViewController(chartController)
        scrollView.addSubview(chartController.view)
        chartController.didMove(toParentViewController: self)

        lastTraderController = storyboard?.instantiateViewController(withIdentifier: "LastTradersViewController") as! LastTradersViewController
        addChildViewController(lastTraderController)
        scrollView.addSubview(lastTraderController.view)
        lastTraderController.didMove(toParentViewController: self)
        
        
        
        
//        orderBookTapped(buttonChart)

    }
    
    override func viewDidLayoutSubviews() {
        
        var frame = orderBookController.view.frame
        frame.size.width = scrollView.frame.size.width
        frame.size.height = scrollView.frame.size.height
        orderBookController.view.frame = frame

        frame = chartController.view.frame
        frame.origin.x = scrollView.frame.size.width
        frame.size.width = scrollView.frame.size.width
        frame.size.height = scrollView.frame.size.height
        chartController.view.frame = frame

        frame = lastTraderController.view.frame
        frame.origin.x = scrollView.frame.size.width * 2
        frame.size.width = scrollView.frame.size.width
        frame.size.height = scrollView.frame.size.height
        lastTraderController.view.frame = frame
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.contentSize.height)
    }
    
    @IBAction func orderBookTapped(_ sender: Any) {
        
        if selectedPage == 0 {
            return
        }
        
        selectedPage = 0
        setupViewLinePosition(sender: sender as! UIButton)
    
        buttonOrderBook.setTitleColor(UIColor.white, for: .normal)
        buttonChart.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonLastTraders.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
    }

    @IBAction func chartTapped(_ sender: Any) {
        
        if selectedPage == 1 {
            return
        }
        
        selectedPage = 1
        setupViewLinePosition(sender: sender as! UIButton)
    
        buttonOrderBook.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonChart.setTitleColor(UIColor.white, for: .normal)
        buttonLastTraders.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
    }
    
    @IBAction func lastTradersTapped(_ sender: Any) {
    
        if selectedPage == 2 {
            return
        }
        
        selectedPage = 2
        setupViewLinePosition(sender: sender as! UIButton)
        
        buttonOrderBook.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonChart.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonLastTraders.setTitleColor(UIColor.white, for: .normal)
    }
    
    func setupViewLinePosition(sender: UIButton) {
        
        viewLeadingOffset.constant = sender.frame.origin.x
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(selectedPage) * scrollView.frame.size.width, y: 0), animated: true)
    }
    
    //MARK: UIScrollViewDelegate 
   
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.size.width);
        
        if page == 0 {
            orderBookTapped(buttonOrderBook)
        }
        else if page == 1 {
            chartTapped(buttonChart)
        }
        else if page == 2 {
            lastTradersTapped(buttonLastTraders)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
