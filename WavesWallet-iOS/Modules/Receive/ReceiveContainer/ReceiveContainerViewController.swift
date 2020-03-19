//
//  ReceiveContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import DomainLayer

private enum Constants {
    static let minScrollOffsetOnKeyboardDismiss: CGFloat = -0.3
}

final class ReceiveContainerViewController: UIViewController {

    private var viewControllers: [UIViewController] = []
    private var states: [Receive.ViewModel.State] = []
    private var selectedState: Receive.ViewModel.State!

    @IBOutlet private weak var segmentedControl: SegmentedControl!
    @IBOutlet private weak var scrollViewContainer: UIScrollView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning { [weak self] in
        guard let self = self else { return }
    }
    
    var asset: DomainLayer.DTO.SmartAssetBalance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Localizable.Waves.Receive.Label.receive
        createBackButton()
        setupControllers()
        setupSegmentedControl()
        setupSwipeGestures()
        createInfoButton()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
  
    @objc private func keyboardWillHide() {
        //TODO: - Need to find good solution to show big nav bar when it small on dismissKeyboard
        
        if isShowNotFullBigNavigationBar {
            scrollView.setContentOffset(CGPoint(x: 0, y: Constants.minScrollOffsetOnKeyboardDismiss), animated: true)
        }
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
    
    private func createInfoButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarInfowhite.image.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(receiveAddressDidShowInfo))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
    }
    
    
    @objc func receiveAddressDidShowInfo() {
          
        var elements: [TooltipTypes.DTO.Element] = .init()
        
        let titleGeneralTooltip = Localizable.Waves.Receive.Tootltip.Addressoptions.Externalsource.title
        let descriptionGeneralTooltip = Localizable.Waves.Receive.Tootltip.Addressoptions.Externalsource.subtitle
        
        
        let titleSecondTooltip = Localizable.Waves.Receive.Tootltip.Addressoptions.Wavesaccount.title
        let descriptionSecondTooltip = Localizable.Waves.Receive.Tootltip.Addressoptions.Wavesaccount.subtitle
        
        elements.append(.init(title: titleGeneralTooltip,
                              description: descriptionGeneralTooltip))
        
        elements.append(.init(title: titleSecondTooltip,
                              description: descriptionSecondTooltip))
        
        let title = Localizable.Waves.Receive.Tootltip.Addressoptions.title
        let data = TooltipTypes.DTO.Data.init(title: title,
                                              elements: elements)
        
        let vc = TooltipModuleBuilder(output: self)
            .build(input: .init(data: data))
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = popoverViewControllerTransitioning
        
        self.present(vc, animated: true, completion: nil)
      }
    
}


// MARK: TooltipViewControllerModulOutput
extension ReceiveContainerViewController: TooltipViewControllerModulOutput {
    
    func tooltipDidTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Actions
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
            if index < viewControllers.count {
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

// MARK: - SetupUI
private extension ReceiveContainerViewController {

    func setupControllers() {
        
        let scrollWidth = UIScreen.main.bounds.size.width
        
        for (index, viewController) in viewControllers.enumerated() {
            scrollViewContainer.addSubview(viewController.view)
            viewController.view.frame.origin.x = CGFloat(index) * scrollWidth
            addChild(viewController)
            viewController.didMove(toParent: self)
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
                buttons.append(.init(name: Localizable.Waves.Receive.Button.cryptocurrency,
                                     icon: .init(normal: Images.rGateway14Basic500.image,
                                                 selected: Images.rGateway14White.image)))
            }
            else if state == .invoice {
                buttons.append(.init(name: Localizable.Waves.Receive.Button.invoice,
                                     icon: .init(normal: Images.rInwaves14Basic500.image,
                                                 selected: Images.rInwaves14White.image)))
            }
            else if state == .card {
                buttons.append(.init(name: Localizable.Waves.Receive.Button.card,
                                     icon: .init(normal: Images.rCard14Basic500.image,
                                                 selected: Images.rCard14White.image)))
            }
        }
        
        segmentedControl.update(with: buttons)
    }
}

// MARK: UIScrollViewDelegate
extension ReceiveContainerViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

// MARK: - Methods
extension ReceiveContainerViewController {
    
    func add(_ viewController: UIViewController, state: Receive.ViewModel.State) {
        viewControllers.append(viewController)
        states.append(state)
        
        selectedState = states[0]
    }
}
