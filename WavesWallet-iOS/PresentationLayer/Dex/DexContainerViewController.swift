//
//  DexContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

let kNotifDidChangeDexItems = "kNotifDidChangeDexItems"

class DexContainerViewController: UIViewController, UIScrollViewDelegate, ChartViewControllerDelegate, CreateOrderViewControllerDelegate {

    var priceAsset : String!
    var amountAsset : String!
    var priceAssetDecimal: Int!
    var amountAssetDecimal: Int!
    
    var priceAssetName : String!
    var amountAssetName : String!

    var orderBookController : OrderBookViewController!
    var chartController : ChartViewController!
    var lastTraderController : LastTradersViewController!
    var myOrdersController: MyOrdersViewController!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewLeadingOffset: NSLayoutConstraint!
    
    @IBOutlet weak var buttonOrderBook: UIButton!
    @IBOutlet weak var buttonChart: UIButton!
    @IBOutlet weak var buttonLastTraders: UIButton!
    @IBOutlet weak var buttonMyOrders: UIButton!
    
    @IBOutlet weak var viewShadow: UIView!
    
    var selectedPage = 0
    var previousTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previousTitle = title
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        view.backgroundColor = AppColors.wavesColor
        orderBookTapped(buttonOrderBook)
        navigationItem.rightBarButtonItems = [UIBarButtonItem.init(title: "Order", style: .plain, target: self, action: #selector(orderTapped))]

        viewShadow.backgroundColor = AppColors.wavesColor
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowRadius = 7
        viewShadow.layer.shadowOpacity = 0.7
        viewShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        orderBookController = storyboard?.instantiateViewController(withIdentifier: "OrderBookViewController") as! OrderBookViewController
        orderBookController.amountAsset = amountAsset
        orderBookController.priceAsset = priceAsset
        orderBookController.amountAssetDecimal = amountAssetDecimal
        orderBookController.priceAssetDecimal = priceAssetDecimal
        orderBookController.priceAssetName = priceAssetName
        orderBookController.amountAssetName = amountAssetName
        addChildViewController(orderBookController)
        scrollView.addSubview(orderBookController.view)
        orderBookController.didMove(toParentViewController: self)

        chartController = storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        chartController.delegate = self
        chartController.valueTitle = title
        chartController.amountAsset = amountAsset
        chartController.priceAsset = priceAsset
        addChildViewController(chartController)
        scrollView.addSubview(chartController.view)
        chartController.didMove(toParentViewController: self)

        lastTraderController = storyboard?.instantiateViewController(withIdentifier: "LastTradersViewController") as! LastTradersViewController
        lastTraderController.amountAsset = amountAsset
        lastTraderController.priceAsset = priceAsset
        lastTraderController.amountAssetDecimal = amountAssetDecimal
        lastTraderController.priceAssetDecimal = priceAssetDecimal
        addChildViewController(lastTraderController)
        scrollView.addSubview(lastTraderController.view)
        lastTraderController.didMove(toParentViewController: self)
    
        myOrdersController = storyboard?.instantiateViewController(withIdentifier: "MyOrdersViewController") as! MyOrdersViewController
        myOrdersController.amountAsset = amountAsset
        myOrdersController.priceAsset = priceAsset
        myOrdersController.amountAssetDecimal = amountAssetDecimal
        myOrdersController.priceAssetDecimal = priceAssetDecimal
        addChildViewController(myOrdersController)
        scrollView.addSubview(myOrdersController.view)
        myOrdersController.didMove(toParentViewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previousTitle = title
        title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = previousTitle
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
        
        frame = myOrdersController.view.frame
        frame.origin.x = scrollView.frame.size.width * 3
        frame.size.width = scrollView.frame.size.width
        frame.size.height = scrollView.frame.size.height
        myOrdersController.view.frame = frame
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 4, height: scrollView.contentSize.height)
    }
    
    func createOrderViewControllerDidCreateOrder() {
        myOrdersTapped(buttonMyOrders)
    }
    
    @objc func orderTapped() {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "CreateOrderViewController") as! CreateOrderViewController
        controller.delegate = self
        controller.priceAsset = priceAsset
        controller.amountAsset = amountAsset
        controller.priceAssetName = priceAssetName
        controller.amountAssetName = amountAssetName
        controller.priceAssetDecimal = priceAssetDecimal
        controller.amountAssetDecimal = amountAssetDecimal
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func changeChartTimeFrame() {
        chartController.timeFrameTapped()
    }
    
    @objc func bottomChartTapped() {
        chartController.showHideBarChart()
    }
    
    //MARK: ChartViewControllerDelegate
    
    func chartViewControllerDidChangeTimeFrame() {
     
        let btnTimeFrame = UIBarButtonItem.init(title: chartController.nameFromTimeFrame(DataManager.getCandleTimeFrame()), style: .done, target: self, action: #selector(changeChartTimeFrame))
        let btnOrder = UIBarButtonItem.init(title: "Order", style: .plain, target: self, action: #selector(orderTapped))
        let btnBottomChart = UIBarButtonItem.init(image: UIImage(named: "btn_bars"), style: .plain, target: self, action: #selector(bottomChartTapped))
        
        navigationItem.rightBarButtonItems = [btnOrder, btnTimeFrame, btnBottomChart]
    }
    
    
    //MARK: ButtonCalls
    
    @IBAction func orderBookTapped(_ sender: Any) {
        
        if selectedPage == 0 {
            return
        }
        
        selectedPage = 0
        setupViewLinePosition(sender: sender as! UIButton)
    
        buttonOrderBook.setTitleColor(UIColor.white, for: .normal)
        buttonChart.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonLastTraders.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonMyOrders.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)

        navigationItem.rightBarButtonItems = [UIBarButtonItem.init(title: "Order", style: .plain, target: self, action: #selector(orderTapped))]
        
        orderBookController.controllerWillAppear()
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
        buttonMyOrders.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        
        chartViewControllerDidChangeTimeFrame()
        
        orderBookController.controllerWillDissapear()
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
        buttonMyOrders.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem.init(title: "Order", style: .plain, target: self, action: #selector(orderTapped))]
        
        lastTraderController.controllerWillAppear()
        orderBookController.controllerWillDissapear()
    }
    
    @IBAction func myOrdersTapped(_ sender: Any) {
        if selectedPage == 3 {
            return
        }
        
        selectedPage = 3
        setupViewLinePosition(sender: sender as! UIButton)
        
        buttonOrderBook.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonChart.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonLastTraders.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        buttonMyOrders.setTitleColor(UIColor.white, for: .normal)

        navigationItem.rightBarButtonItems = [UIBarButtonItem.init(title: "Order", style: .plain, target: self, action: #selector(orderTapped))]
        
        myOrdersController.controllerWillAppear()
        orderBookController.controllerWillDissapear()
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
        else if page == 3 {
            myOrdersTapped(buttonMyOrders)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
