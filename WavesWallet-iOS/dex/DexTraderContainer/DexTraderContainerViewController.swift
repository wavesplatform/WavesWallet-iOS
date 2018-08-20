//
//  DexTraderContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexTraderContainerViewController: UIViewController {

    @IBOutlet weak var segmentedControl: DexTranderContainerSegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pair: DexTraderContainer.DTO.Pair!
    weak var moduleOutput: DexTraderContainerModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.delegate = self
        title = pair.amountAsset.name + " / " + pair.priceAsset.name
        createBackWhiteButton()
        addBgBlueImage()
        addInfoButton()
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSmallNavigationBar()
        hideTopBarLine()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = nil
    }
}

//MARK: - Actions
private extension DexTraderContainerViewController {
    
    @objc func infoTapped() {
        let infoPair = DexInfoPair.DTO.Pair(amountAsset: pair.amountAsset.id, amountAssetName: pair.amountAsset.name, priceAsset: pair.priceAsset.id, priceAssetName: pair.priceAsset.name, isHidden: pair.isHidden)
        moduleOutput?.showInfo(pair: infoPair)
    }
    
}

//MARK: - DexTranderContainerSegmentedControlDelegate
extension DexTraderContainerViewController: DexTranderContainerSegmentedControlDelegate {
    
    func segmentedControlDidChangeState(_ state: DexTranderContainerSegmentedControl.SegmentedState) {
        scrollToPageIndex(state.rawValue)
    }
}

//MARK: - UIScrollViewDelegate
extension DexTraderContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        segmentedControl.changeStateToScrollPage(page)
    }
}


//MARK: - Setup UI
private extension DexTraderContainerViewController {
    
    func scrollToPageIndex(_ pageIndex: Int) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(pageIndex) * scrollView.frame.size.width, y: scrollView.contentOffset.y), animated: true)
    }
    
    func addInfoButton() {
        let btn = UIBarButtonItem(image: Images.topbarInfowhite.image, style: .plain, target: self, action: #selector(infoTapped))
        btn.tintColor = .white
        navigationItem.rightBarButtonItem = btn
    }
    
    func build() {
        let numberOrScreens = 4
        
        let orderIndex = DexTranderContainerSegmentedControl.SegmentedState.orderBook.rawValue
        addController(DexOrderBookModuleBuilder().build(input: pair), atIndex: orderIndex)
        
        let chartIndex = DexTranderContainerSegmentedControl.SegmentedState.chart.rawValue
        addController(DexChartModuleBuilder().build(), atIndex: chartIndex)
        
        let lastTradesIndex = DexTranderContainerSegmentedControl.SegmentedState.lastTraders.rawValue
        addController(DexLastTradesModuleBuilder().build(), atIndex: lastTradesIndex)
        
        let myOrdersIndex = DexTranderContainerSegmentedControl.SegmentedState.myOrders.rawValue
        addController(DexMyOrdersModuleMuilder().build(), atIndex: myOrdersIndex)
        
        scrollView.contentSize = CGSize(width: CGFloat(numberOrScreens) * Platform.ScreenWidth, height: scrollView.contentSize.height)
    }
    
    func addController(_ viewController: UIViewController, atIndex: Int) {
        scrollView.addSubview(viewController.view)
        viewController.view.frame = scrollView.bounds
        viewController.view.frame.origin.x = CGFloat(atIndex) * Platform.ScreenWidth
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
    }
}
