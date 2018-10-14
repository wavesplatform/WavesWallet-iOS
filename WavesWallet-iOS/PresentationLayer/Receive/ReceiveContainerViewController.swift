//
//  ReceiveContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


private enum Constants {
    static let minScrollOffsetOnKeyboardDismiss: CGFloat = -0.5
}

final class ReceiveContainerViewController: UIViewController {

    private var viewControllers: [UIViewController] = []
    private var states: [Receive.ViewModel.State] = []
    private var selectedState: Receive.ViewModel.State!

    @IBOutlet private weak var segmentedControl: SegmentedControl!
    @IBOutlet private weak var scrollViewContainer: UIScrollView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    var asset: DomainLayer.DTO.AssetBalance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Localizable.Receive.Label.receive
        createBackButton()
        setupControllers()
        setupSegmentedControl()
        setupSwipeGestures()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        scrollView.delegate = self
    }
  
    @objc private func keyboardWillHide() {
        //TODO: - Need to find good solution to show big nav bar when it small on dismissKeyboard
        scrollView.setContentOffset(CGPoint(x: 0, y: Constants.minScrollOffsetOnKeyboardDismiss), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for view in scrollViewContainer.subviews {
            view.frame.size.width = scrollViewContainer.frame.size.width
            view.frame.size.height = scrollViewContainer.frame.size.height
        }
    }
    
}

//MARK: - Actions
private extension ReceiveContainerViewController {
    
    func scrollToPage(_ page: Int) {
        view.endEditing(true)
        let offset = CGPoint(x: CGFloat(page) * scrollViewContainer.frame.size.width, y: 0)
        scrollViewContainer.setContentOffset(offset, animated: true)
    }
    
    @IBAction func segmentedDidChange(_ sender: Any) {
        guard let state = Receive.ViewModel.State(rawValue: segmentedControl.selectedIndex) else { return }
        selectedState = state
        scrollToPage(selectedState.rawValue)
    }
    
    @objc func handleGesture(_ gesture: UISwipeGestureRecognizer) {
                
        if gesture.direction == .left {

            let index = segmentedControl.selectedIndex + 1
            if index <= Receive.ViewModel.State.card.rawValue {
                guard let state = Receive.ViewModel.State(rawValue: index) else { return }
                selectedState = state
                segmentedControl.setSelectedIndex(state.rawValue, animation: true)
                scrollToPage(state.rawValue)
            }
        }
        else if gesture.direction == .right {

            let index = selectedState.rawValue - 1
            if index >= 0 {
                guard let state = Receive.ViewModel.State(rawValue: index) else { return }
                selectedState = state
                segmentedControl.setSelectedIndex(state.rawValue, animation: true)
                scrollToPage(state.rawValue)
            }
        }
    }
}

//MARK: - SetupUI
private extension ReceiveContainerViewController {

    func setupControllers() {
        
        let scrollWidth = UIScreen.main.bounds.size.width
        
        for (index, viewController) in viewControllers.enumerated() {
            scrollViewContainer.addSubview(viewController.view)
            viewController.view.frame.origin.x = CGFloat(index) * scrollWidth
            addChildViewController(viewController)
            viewController.didMove(toParentViewController: self)
        }
        
        scrollViewContainer.contentSize = CGSize(width: CGFloat(viewControllers.count) * scrollWidth,
                                                 height: scrollViewContainer.contentSize.height)

    }
    
    func setupSwipeGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        scrollViewContainer.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeLeft.direction = .left
        scrollViewContainer.addGestureRecognizer(swipeLeft)
    }

    
    func setupSegmentedControl() {
        
        var buttons: [SegmentedControl.Button] = []
        
        for state in states {
            if state == .cryptoCurrency {
                buttons.append(.init(name: Localizable.Receive.Button.cryptocurrency,
                                     icon: .init(normal: Images.rGateway14Basic500.image,
                                                 selected: Images.rGateway14White.image)))
            }
            else if state == .invoice {
                buttons.append(.init(name: Localizable.Receive.Button.invoice,
                                     icon: .init(normal: Images.rInwaves14Basic500.image,
                                                 selected: Images.rInwaves14White.image)))
            }
            else if state == .card {
                buttons.append(.init(name: Localizable.Receive.Button.card,
                                     icon: .init(normal: Images.rCard14Basic500.image,
                                                 selected: Images.rCard14White.image)))
            }
        }
        
        segmentedControl.update(with: buttons)
    }
}

//MARK: UIScrollViewDelegate
extension ReceiveContainerViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

//MARK: - Methods
extension ReceiveContainerViewController {
    
    func add(_ viewController: UIViewController, state: Receive.ViewModel.State) {
        viewControllers.append(viewController)
        states.append(state)
        
        selectedState = states[0]
    }
}
