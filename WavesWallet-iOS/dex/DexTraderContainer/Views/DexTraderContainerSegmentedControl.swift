//
//  DexTranderContainerSegmentedControl.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol DexTraderContainerSegmentedControlDelegate: AnyObject {
    
    func segmentedControlDidChangeState(_ state: DexTraderContainerSegmentedControl.SegmentedState)
}

final class DexTraderContainerSegmentedControl: UIView, NibOwnerLoadable {

    enum SegmentedState: Int {
        case orderBook = 0
        case chart
        case lastTraders
        case myOrders
    }
    
    weak var delegate: DexTraderContainerSegmentedControlDelegate?
    private(set) var selectedState: SegmentedState = SegmentedState.orderBook
    
    @IBOutlet private weak var buttonOrderBook: UIButton!
    @IBOutlet private weak var buttonChart: UIButton!
    @IBOutlet private weak var buttonLastTrades: UIButton!
    @IBOutlet private weak var buttonMyOrders: UIButton!
    @IBOutlet private weak var viewLine: UIView!
    @IBOutlet private weak var linePosition: NSLayoutConstraint!
    
    private var isNeedsUpdatesConstaints: Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupButtonsState()
        setupLocalization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    override func updateConstraints() {
     
        if isNeedsUpdatesConstaints {
            isNeedsUpdatesConstaints = false
            linePosition.constant = activeButtonPosition + buttonWidth / 2 - viewLine.frame.size.width / 2
        }
        super.updateConstraints()
    }
   
    func changeStateToScrollPage(_ page: Int) {
        
        if page == SegmentedState.orderBook.rawValue {
            setSelectedState(.orderBook, callDelegate: false)
        }
        else if page == SegmentedState.chart.rawValue {
            setSelectedState(.chart, callDelegate: false)
        }
        else if page == SegmentedState.lastTraders.rawValue {
            setSelectedState(.lastTraders, callDelegate: false)
        }
        else if page == SegmentedState.myOrders.rawValue {
            setSelectedState(.myOrders, callDelegate: false)
        }
    }
  
    private func setSelectedState(_ state: SegmentedState, callDelegate: Bool) {
        if selectedState != state {
            selectedState = state
            setupButtonsState()
            setupLinePosition(animation: true)
            
            if callDelegate {
                delegate?.segmentedControlDidChangeState(state)
            }
        }
    }
    
}

//MARK - Localization
private extension DexTraderContainerSegmentedControl {
    func setupLocalization() {
        buttonOrderBook.setTitle(Localizable.DexTraderContainer.Button.orderbook, for: .normal)
        buttonChart.setTitle(Localizable.DexTraderContainer.Button.chart, for: .normal)
        buttonMyOrders.setTitle(Localizable.DexTraderContainer.Button.myOrders, for: .normal)
        buttonLastTrades.setTitle(Localizable.DexTraderContainer.Button.lastTrades, for: .normal)
    }
}

//MARK - Setup UI
private extension DexTraderContainerSegmentedControl {
    
    func setupButtonsState() {
        setupInactiveState(buttonMyOrders)
        setupInactiveState(buttonLastTrades)
        setupInactiveState(buttonChart)
        setupInactiveState(buttonOrderBook)
        
        if selectedState == .orderBook {
            setupActiveState(buttonOrderBook)
        }
        else if selectedState == .myOrders {
            setupActiveState(buttonMyOrders)
        }
        else if selectedState == .chart {
            setupActiveState(buttonChart)
        }
        else if selectedState == .lastTraders {
            setupActiveState(buttonLastTrades)
        }
    }
    
    func setupInactiveState(_ button: UIButton) {
        button.setTitleColor(.submit200, for: .normal)
    }
    
    func setupActiveState(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
    }
    
    func setupLinePosition(animation: Bool) {
        
        isNeedsUpdatesConstaints = true
        setNeedsUpdateConstraints()
        if animation {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    var buttonWidth: CGFloat {
        switch selectedState {
        case .orderBook:
            return buttonOrderBook.frame.size.width
            
        case .chart:
            return buttonChart.frame.size.width
            
        case .lastTraders:
            return buttonLastTrades.frame.size.width
            
        case .myOrders:
            return buttonMyOrders.frame.size.width
        }
    }
    
    var activeButtonPosition: CGFloat {
        switch selectedState {
        case .orderBook:
            return buttonOrderBook.frame.origin.x
        case .chart:
            return buttonChart.frame.origin.x
        case .lastTraders:
            return buttonLastTrades.frame.origin.x
        case .myOrders:
            return buttonMyOrders.frame.origin.x
        }
    }
}

//MARK: - Actions
private extension DexTraderContainerSegmentedControl {
    
    @IBAction func actionTapped(_ sender: UIButton) {
        
        if sender == buttonMyOrders {
            setSelectedState(.myOrders, callDelegate: true)
        }
        else if sender == buttonLastTrades {
            setSelectedState(.lastTraders, callDelegate: true)
        }
        else if sender == buttonChart {
            setSelectedState(.chart, callDelegate: true)
        }
        else if sender == buttonOrderBook {
            setSelectedState(.orderBook, callDelegate: true)
        }
    }
    
   
}
