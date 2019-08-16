//
//  DebugRootView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import DomainLayer

private struct Constants {
    
    static let firstPosition: CGPoint = CGPoint(x: 44, y: 44)
    
    static let size: CGFloat = 35
}

protocol DebugWindowRouterDelegate: AnyObject {
    func relaunchApplication()
}

final class DebugRootView: UIView  {
    
    private lazy var debugView: DebugView = DebugView(frame: .zero)
    
    private lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlerPanGesture(_:)))
    
    var debugPosition: CGPoint = CGPoint.zero
    
    var didTapOnButton: (() -> Void)?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        
        debugPosition = ApplicationDebugSettings.debugButtonPosition ?? CGPoint(x: 44, y: 44)
        
        addSubview(debugView)
        
        debugView.layer.zPosition = 666
        debugView.didTapOnView = { [weak self] in
            self?.didTapOnButton?()
        }
        
        updateContent()
        
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        debugView.frame = CGRect(x: debugPosition.x, y: debugPosition.y, width: Constants.size, height: Constants.size)
    }
    
    @objc private func handlerPanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let location = recognizer.location(in: self)
        
        switch recognizer.state {
        case .began:
            break
            
        case .changed:
            
            var newFrame = debugView.frame
            newFrame.origin = CGPoint(x: location.x - newFrame.width * 0.5, y: location.y - newFrame.height * 0.5)
            
            if self.frame.contains(newFrame) == false {
                return
            }
            
            debugView.center = location
            
        default:
            ApplicationDebugSettings.debugButtonPosition = location
            
        }
    }
    
    func updateContent() {
        debugView.chainIdLabel.text = WalletEnvironment.current.scheme
    }
}

// MARK: UIGestureRecognizerDelegate

extension DebugRootView: UIGestureRecognizerDelegate {}


final class DebugWindow: UIWindow {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let hitView = super.hitTest(point, with: event)
        
        if (hitView?.isKind(of: DebugView.self) ?? false) == true  {
            return nil
        }
        
        if (hitView is DebugRootView)  {
            return nil
        }
        
        return hitView
    }
}

final class DebugWindowRouter: WindowRouter {
    
    private let contentView: UIView = UIView()
    
    private lazy var debugRootView = DebugRootView()
    
    private lazy var debugWindow: DebugWindow = {
        
        let window = DebugWindow()
        let vc = UIViewController()
        vc.view = debugRootView
        vc.view.frame = UIScreen.main.bounds
        vc.view.backgroundColor = .clear
        window.backgroundColor = .clear
        window.rootViewController = vc
        window.windowLevel = .alert
        return window
    }()
    
    weak var delegate: DebugWindowRouterDelegate?
    
    override init(window: UIWindow) {
        super.init(window: window)
    }
    
    override func windowDidAppear() {
        super.windowDidAppear()
        
        debugRootView.didTapOnButton = { [weak self] in
            self?.showSupport()
        }
        
        debugWindow.makeKeyAndVisible()
    }
    
    private func showSupport() {
        let vc = StoryboardScene.Support.debugViewController.instantiate()
        vc.delegate = self
        let nv = CustomNavigationController()
        nv.viewControllers = [vc]
        debugWindow.rootViewController?.present(nv, animated: true, completion: nil)
    }
}

// MARK: DebugViewControllerDelegate

extension DebugWindowRouter: DebugViewControllerDelegate {
    
    func dissmissDebugVC(isNeedRelaunchApp: Bool) {
        
        debugRootView.updateContent()
        
        debugWindow.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        
        if isNeedRelaunchApp {
            self.delegate?.relaunchApplication()
        }
    }
    
    func relaunchApplication() {
        self.delegate?.relaunchApplication()
    }
}

extension WindowRouter {
    
    #if DEBUG || TEST
    
    static func windowFactory(window: UIWindow) -> DebugWindowRouter {
        return DebugWindowRouter(window: window)
    }
    
    #else
    
    static func windowFactory(window: UIWindow) -> WindowRouter {
        return WindowRouter(window: window)
    }
    
    #endif
}
