//
//  WavesReceiveViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WavesReceiveViewController: UIViewController, UIScrollViewDelegate {

    enum ReceiveState: Int {
        case cryptocurrency = 0
        case invoice
        case card
        case bank
    }
    var hideTabBarOnBack = false

    @IBOutlet weak var scrollViewContainer: UIScrollView!
    @IBOutlet weak var scrollViewSegment: UIScrollView!
    @IBOutlet weak var buttonСryptocurrency: UIButton!
    @IBOutlet weak var buttonInvoice: UIButton!
    @IBOutlet weak var buttonCard: UIButton!
    @IBOutlet weak var buttonBank: UIButton!
    
    var selectedSegmentIndex = ReceiveState.cryptocurrency
    @IBOutlet weak var leftViewOffset: NSLayoutConstraint!
    @IBOutlet weak var viewSegmentWidth: NSLayoutConstraint!

    var cryptocurrencyController: UIViewController?
    var invoiceController: UIViewController?
    var cardController: UIViewController?
    var bankController: UIViewController?

    @IBOutlet weak var scrollContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var labelTitleSmall: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var labelTitleBig: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Receive"
        setupBigNavigationBar()
        createBackButton()
        navigationController?.setNavigationBarHidden(true, animated: true)

        addController(&cryptocurrencyController, identifier: "WavesReceiveCryptocurrencyViewController", atPoisiton: 0)
        addController(&invoiceController, identifier: "WavesReceiveInvoiceViewController", atPoisiton: 1)
        addController(&cardController, identifier: "WavesReceiveCardViewController", atPoisiton: 2)
        addController(&bankController, identifier: "WavesReceiveBankViewController", atPoisiton: 3)
        
        scrollViewContainer.contentSize = CGSize(width: 4 * Platform.ScreenWidth, height: scrollViewContainer.contentSize.height)
        
        setupButtons(selectedButton: buttonСryptocurrency, animation: false)
    
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        scrollViewContainer.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeLeft.direction = .left
        scrollViewContainer.addGestureRecognizer(swipeLeft)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        if !hideTabBarOnBack {
            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
        navigationController?.popViewController(animated: true)
    }
    
    var activeButton: UIButton {
        if selectedSegmentIndex == .cryptocurrency {
            return buttonСryptocurrency
        }
        else if selectedSegmentIndex == .bank {
            return buttonBank
        }
        else if selectedSegmentIndex == .card {
            return buttonCard
        }
        else if selectedSegmentIndex == .invoice {
            return buttonInvoice
        }
        return UIButton()
    }
    
    func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .left {
            
            let index = selectedSegmentIndex.rawValue + 1
            if index <= ReceiveState.bank.rawValue {
                selectedSegmentIndex = ReceiveState(rawValue: index)!
                setupButtons(selectedButton: activeButton, animation: true)
            }
        }
        else if gesture.direction == .right {
            
            let index = selectedSegmentIndex.rawValue - 1
            if index >= 0 {
                selectedSegmentIndex = ReceiveState(rawValue: index)!
                setupButtons(selectedButton: activeButton, animation: true)
            }
        }
    }
    
    var defaultContentControllerHeight: CGFloat {
        return UIScreen.main.bounds.size.height - (Platform.isIphoneX ? 229 : 171)
    }
    
    func addController(_ controller: UnsafeMutablePointer<UIViewController?>, identifier: String, atPoisiton: Int) {
        
        controller.pointee = storyboard!.instantiateViewController(withIdentifier: identifier)
        addChildViewController(controller.pointee!)
        scrollViewContainer.addSubview(controller.pointee!.view)
        controller.pointee!.didMove(toParentViewController: self)
        controller.pointee!.view.frame.origin.x = CGFloat(atPoisiton) * Platform.ScreenWidth
        controller.pointee!.view.frame.size.height = defaultContentControllerHeight
        controller.pointee!.view.frame.size.width = Platform.ScreenWidth
    }
    
    var currentContentHeight: CGFloat {
        let view = scrollViewContainer.subviews[selectedSegmentIndex.rawValue]
        return view.frame.size.height
    }
    
    @IBAction func buttonSegmentTapped(_ sender: UIButton) {
    
        let index = sender.tag
        if selectedSegmentIndex.rawValue == index {
            return
        }
        
        selectedSegmentIndex = ReceiveState(rawValue: index)!
        setupButtons(selectedButton: sender, animation: true)
    }
    
    func setupScrollHeight() {
        scrollContainerHeight.constant = currentContentHeight
    }
    
    func setupButtons(selectedButton: UIButton, animation: Bool) {
        
        view.endEditing(true)
        
        buttonСryptocurrency.setTitleColor(UIColor.basic500, for: .normal)
        buttonInvoice.setTitleColor(UIColor.basic500, for: .normal)
        buttonCard.setTitleColor(UIColor.basic500, for: .normal)
        buttonBank.setTitleColor(UIColor.basic500, for: .normal)

        buttonСryptocurrency.setImage(UIImage(named: "rGateway14Basic500"), for: .normal)
        buttonInvoice.setImage(UIImage(named: "rInwaves14Basic500"), for: .normal)
        buttonCard.setImage(UIImage(named: "rCard14Basic500"), for: .normal)
        buttonBank.setImage(UIImage(named: "rBank14Basic500"), for: .normal)
        
        selectedButton.setTitleColor(.white, for: .normal)
        if selectedButton == buttonСryptocurrency {
            selectedButton.setImage(UIImage(named: "rGateway14White"), for: .normal)
        }
        else if selectedButton == buttonInvoice {
            selectedButton.setImage(UIImage(named: "rInwaves14White"), for: .normal)
        }
        else if selectedButton == buttonCard {
            selectedButton.setImage(UIImage(named: "rCard14White"), for: .normal)
        }
        else if selectedButton == buttonBank {
            selectedButton.setImage(UIImage(named: "rBank14White"), for: .normal)
        }
        
        leftViewOffset.constant = selectedButton.superview!.frame.origin.x
        viewSegmentWidth.constant = selectedButton.superview!.frame.size.width
                
        let offset = CGFloat(selectedSegmentIndex.rawValue) * Platform.ScreenWidth
        setupScrollHeight()
        scrollViewContainer.setContentOffset(CGPoint(x: offset , y: 0), animated: animation)

        if animation {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }

            var offset = selectedButton.superview!.frame.origin.x - selectedButton.superview!.frame.size.width - 16

            if offset < 0 {
                offset = 0
            }
            else if offset > scrollViewSegment.contentSize.width - scrollViewSegment.frame.size.width {
                offset = scrollViewSegment.contentSize.width - scrollViewSegment.frame.size.width
            }

            scrollViewSegment.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let showSmallTitle = scrollView.contentOffset.y >= 30
        
        if showSmallTitle {
            viewSeparator.isHidden = false
            labelTitleBig.isHidden = true
            labelTitleSmall.isHidden = false
        }
        else {
            viewSeparator.isHidden = true
            labelTitleBig.isHidden = false
            labelTitleSmall.isHidden = true
        }
    }
}
