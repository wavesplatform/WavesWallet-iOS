//
//  DexSegmentedControl.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 18.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions


private enum Constants {
    static let deltaButtonWidth: CGFloat = 24
    
    static let lineWidth: CGFloat = 14
    static let lineHeight: CGFloat = 2
    static let lineRadius: Float = 2
    static let lineOffsetBottomScale: CGFloat = 0.75
    
    static let buttonTitleInsets = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: 0)
    static let animationDuration: TimeInterval = 0.3
}

protocol DexSegmentedControlDelegate: AnyObject {
    func dexSegmentedControlDidChangeIndex(_ index: Int)
}

final class DexSegmentedControl: UIView {

    private(set) var selectedIndex: Int = 0
    private let scrollView = UIScrollView()
    private let selectedLine = UIView(frame: .init(x: 0, y: 0, width: Constants.lineWidth, height: Constants.lineHeight))
    private let bottomLine = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.5))
    
    weak var delegate: DexSegmentedControlDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bottomLine.backgroundColor = .accent100
        
        selectedLine.frame.origin.y = frame.size.height * Constants.lineOffsetBottomScale
        selectedLine.cornerRadius = Constants.lineRadius
        selectedLine.backgroundColor = .submit400
        
        scrollView.showsHorizontalScrollIndicator = false
        
        addSubview(scrollView)
        addSubview(selectedLine)
        addSubview(bottomLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        bottomLine.frame.size.width = frame.size.width
        bottomLine.frame.origin.y = frame.size.height - bottomLine.frame.size.height
        updateLinePosition(animation: false)
    }
    
    var items: [String] = [] {
        didSet {
            createButtons()
            setupActiveStates()
        }
    }
}


private extension DexSegmentedControl {
    
    func createButtons() {
        scrollView.subviews.forEach{ $0.removeFromSuperview() }
        
        let font = UIFont.systemFont(ofSize: 13)
        
        for (index, title) in items.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = font
            button.tag = index
            button.titleEdgeInsets = Constants.buttonTitleInsets
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.frame = .init(x: lastButtonOffset, y: 0, width: title.maxWidth(font: font) + Constants.deltaButtonWidth, height: frame.size.height)
            scrollView.addSubview(button)
        }
        
        scrollView.contentSize.width = lastButtonOffset
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index != selectedIndex else { return }
        selectedIndex = index
        updateLinePosition(animation: true)
        setupActiveStates()
        
        delegate?.dexSegmentedControlDidChangeIndex(selectedIndex)
    }

    func updateLinePosition(animation: Bool) {
        let button = currentActiveButton
        let position = button.frame.origin.x + (button.frame.size.width - self.selectedLine.frame.size.width) / 2
        UIView.animate(withDuration: animation ? Constants.animationDuration : 0) {
            self.selectedLine.frame.origin.x = position
        }
    }
    
    var lastButtonOffset: CGFloat {
        return (scrollView.subviews.last?.frame.origin.x ?? 0) + (scrollView.subviews.last?.frame.size.width ?? 0)
    }
    
    var currentActiveButton: UIButton {
        let buttons = scrollView.subviews.filter{ $0 is UIButton } as? [UIButton] ?? []
        return buttons[selectedIndex]
    }
    
    func setupActiveStates() {
        let buttons = scrollView.subviews.filter{ $0 is UIButton } as? [UIButton] ?? []
        
        for (index, button) in buttons.enumerated() {
            let color: UIColor = index == selectedIndex ? .black : .basic500
            button.setTitleColor(color, for: .normal)
        }
    }
}
