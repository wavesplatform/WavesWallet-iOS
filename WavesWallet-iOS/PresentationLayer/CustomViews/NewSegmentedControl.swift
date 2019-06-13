//
//  SegmentedControl.swift
//  testApp
//
//  Created by Pavel Gubin on 5/16/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

private enum Constants {
    static let font = UIFont.systemFont(ofSize: 13)
    static let startOffset: CGFloat = 5
    static let deltaTitleWidth: CGFloat = 22
    static let unselectedColor = UIColor.basic500
    static let titleEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    
    static let lineWidth: CGFloat = 14
    static let lineHeight: CGFloat = 2
    static let lineCorner: CGFloat = 1.25
    static let lineTitleOffset: CGFloat = 6
    static let lineColor = UIColor.submit400
    
    static let animationDuration: TimeInterval = 0.3
    
    enum Shadow {
        static let height: CGFloat = 4
        static let opacity: Float = 0.1
        static let shadowRadius: Float = 3
    }
}

protocol NewSegmentedControlDelegate: AnyObject {
    func segmentedControlDidChangeIndex(_ index: Int)
}

final class NewSegmentedControl: UIScrollView {
    
    private let lineView = UIView()
    
    private(set) var selectedIndex: Int = 0
    weak var segmentedDelegate: NewSegmentedControlDelegate?
    
    var items: [String] = [] {
        didSet {
            selectedIndex = 0
            setup()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var offset: CGFloat = Constants.startOffset
        for button in titleButtons {
            guard let title = button.title(for: .normal) else { return }
            let width = title.maxWidth(font: Constants.font) + Constants.deltaTitleWidth
            button.frame = .init(x: offset, y: 0, width: width, height: frame.size.height)
            offset = button.frame.origin.x + button.frame.size.width
        }
        
        if let subView = titleButtons.last {
            contentSize.width = subView.frame.origin.x + subView.frame.size.width
        }
    }
    
    @objc private func buttonDidTapped(_ sender: UIButton) {
        if sender.tag == selectedIndex {
            return
        }
        
        setSelectedIndex(sender.tag, animation: true)
        segmentedDelegate?.segmentedControlDidChangeIndex(selectedIndex)
    }
}

//MARK: - Methods
extension NewSegmentedControl {
    
    func setSelectedIndex(_ index: Int, animation: Bool) {
        if selectedIndex == index {
            return
        }
        
        selectedIndex = index
        setupLinePosition(animation: true)
        setupTitleColors()
        setupVisibleActiveButtonState()
    }
    
    func addShadow() {
        if layer.shadowColor == nil {
            layer.setupShadow(options: .init(offset: CGSize(width: 0, height: Constants.Shadow.height),
                                             color: .black,
                                             opacity: Constants.Shadow.opacity,
                                             shadowRadius: Constants.Shadow.shadowRadius,
                                             shouldRasterize: true))
        }
    }
}

//MARK: - UI Settings
private extension NewSegmentedControl {
    
    var titleButtons: [UIButton] {
        return subviews.filter {$0 is UIButton} as? [UIButton] ?? []
    }
    
    var activeButtonPosition: CGFloat {
        return titleButtons.first(where: {$0.tag == selectedIndex})?.frame.origin.x ?? 0
    }
    
    func setup() {
        showsHorizontalScrollIndicator = false
        clipsToBounds = false
        lineView.frame = CGRect(x: 0, y: 0, width: Constants.lineWidth, height: Constants.lineHeight)
        lineView.layer.cornerRadius = Constants.lineCorner
        lineView.backgroundColor = Constants.lineColor
        
        for view in subviews {
            view.removeFromSuperview()
        }

        var offset: CGFloat = Constants.startOffset
        for (index, item) in items.enumerated() {
            let button = UIButton(type: .system)
            let width = item.maxWidth(font: Constants.font) + Constants.deltaTitleWidth
            button.frame = .init(x: offset, y: 0, width: width, height: frame.size.height)
            button.titleLabel?.font = Constants.font
            button.contentVerticalAlignment = .top
            button.titleEdgeInsets = Constants.titleEdgeInsets
            button.addTarget(self, action: #selector(buttonDidTapped(_:)), for: .touchUpInside)
            button.tag = index
            button.setTitle(item, for: .normal)
            addSubview(button)
            offset = button.frame.origin.x + button.frame.size.width
        }

        setupTitleColors()

        if let subView = subviews.last {
            contentSize.width = subView.frame.origin.x + subView.frame.size.width
        }
        addSubview(lineView)
        setupLinePosition(animation: false)
    }
    
    func setupLinePosition(animation: Bool) {
        
        let x = activeButtonPosition + Constants.deltaTitleWidth / 2
        let y = frame.size.height / 2 + Constants.lineTitleOffset
        
        if animation {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.lineView.frame.origin.x = x
                self.lineView.frame.origin.y = y
            }
        }
        else {
            lineView.frame.origin.x = x
            lineView.frame.origin.y = y
        }
    }
    
    func setupTitleColors() {
        
        for (index, button) in titleButtons.enumerated() {
            if index == selectedIndex {
                button.setTitleColor(.black, for: .normal)
            }
            else {
                button.setTitleColor(Constants.unselectedColor, for: .normal)
            }
        }
    }
    
    func setupVisibleActiveButtonState() {
        
        let nearLeftButtonPosition = titleButtons.first(where: {$0.tag == selectedIndex - 1})?.frame.origin.x ?? 0
        let nearRightButtonPosition = titleButtons.first(where: {$0.tag == selectedIndex + 1})?.frame.origin.x ?? 0
        let nearRightButtonWidth = titleButtons.first(where: {$0.tag == selectedIndex + 1})?.frame.size.width ?? 0
        let activeButtonWidth = titleButtons.first(where: {$0.tag == selectedIndex})?.frame.size.width ?? 0
        
        if nearLeftButtonPosition < contentOffset.x {
            setContentOffset(.init(x: nearLeftButtonPosition - Constants.startOffset, y: 0), animated: true)
        }
        else if contentOffset.x < nearRightButtonPosition + nearRightButtonWidth - frame.size.width {
            setContentOffset(.init(x: nearRightButtonPosition + nearRightButtonWidth - frame.size.width, y: 0), animated: true)
        }
        else if contentOffset.x < activeButtonPosition + activeButtonWidth - frame.size.width {
            setContentOffset(.init(x: activeButtonPosition + activeButtonWidth - frame.size.width, y: 0), animated: true)
        }
    }

}
