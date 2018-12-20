//
//  PopupViewController.swift
//  TestPopup
//
//  Created by Pavel Gubin on 5/22/18.
//  Copyright © 2018 Pavel Gubin. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    
    //MARK: - UI Settings
    static let BgAlpha: CGFloat = 0.4
    static let DragImageFrame = CGRect(x: (UIScreen.main.bounds.size.width - 36) / 2.0, y: 6, width: 36, height: 4)
    static let CornerRadius: CGFloat = 12
    static let AnimationDuration: TimeInterval = 0.3

    //MARK: Container Settings
    static let DefaultTopContainerTopOffset: CGFloat = BiometricManager.type == BiometricType.faceID ? 150 : 64
    static let BottomContainerOffset: CGFloat = BiometricManager.type == BiometricType.faceID ? 30 : 0
    static let ContainerOffsetOfDragPoint: CGFloat = 20
    
    //MARK: - Gesture Settings
    static let MinumOffsetToScrollTop: CGFloat = 150
}

final class PopupViewController: UIViewController {

    private var bgView = UIView(frame: UIScreen.main.bounds)
    private var contentView : UIView!
    private var topContainerOffset : CGFloat = Constants.DefaultTopContainerTopOffset
    private let dragImage = UIImageView(frame: Constants.DragImageFrame)
    private var isDragMode = false
    
    private var gestureTap: UITapGestureRecognizer!
    
    // Use if screen is not have full size
    var contentHeight: CGFloat = 0 {
        didSet {
            contentHeight += Constants.BottomContainerOffset
            topContainerOffset = UIScreen.main.bounds.size.height - contentHeight - Constants.ContainerOffsetOfDragPoint
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        bgView.backgroundColor = .black
        bgView.alpha = 0

        setupMainContentView()
        setupGestures()
    }
    
    func present(contentViewController: UIViewController, animated: Bool = true) {
        
        let topController = getTopController()
        topController.view.addSubview(bgView)
        
        topController.addChild(self)
        didMove(toParent: topController)
        topController.view.addSubview(view)
        
        addChild(contentViewController)
        contentViewController.didMove(toParent: self)
        contentViewController.view.frame = CGRect(x: 0, y: Constants.ContainerOffsetOfDragPoint,
                                                  width: contentView.frame.size.width,
                                                  height: contentView.frame.size.height - Constants.ContainerOffsetOfDragPoint)
        contentView.addSubview(contentViewController.view)
        
        view.frame.origin.y = view.frame.size.height
        
        showView(animated: animated)
    }
 
    func present(contentView: UIView, animated: Bool) {
                
        contentView.frame = CGRect(x: 0, y: Constants.ContainerOffsetOfDragPoint,
                                                  width: contentView.frame.size.width,
                                                  height: contentView.frame.size.height - Constants.ContainerOffsetOfDragPoint)
        self.contentView.addSubview(contentView)
        
        view.frame.origin.y = view.frame.size.height
        
        showView(animated: animated)
    }
    
    func dismissPopup(completed: (() -> Void)? = nil) {
        UIView.animate(withDuration: Constants.AnimationDuration, animations: {
            self.view.frame.origin.y = self.view.frame.size.height
            self.bgView.alpha = 0
        }) { (compeleted) in
            completed?()
            self.bgView.removeFromSuperview()
            self.view.removeFromSuperview()
            self.willMove(toParent: nil)
            self.removeFromParent()
        }
    }
    
    func showView(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: Constants.AnimationDuration) {
                self.view.frame.origin.y = 0
                self.bgView.alpha = Constants.BgAlpha
            }
        } else {
            self.view.frame.origin.y = 0
            self.bgView.alpha = Constants.BgAlpha
        }
    }
    
    func hideView(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: Constants.AnimationDuration) {
                self.view.frame.origin.y = self.view.frame.height
                self.bgView.alpha = 0
            }
        } else {
            self.view.frame.origin.y = self.view.frame.height
            self.bgView.alpha = 0
        }
    }
  
}


//MARK: - Gesture Actions

private extension PopupViewController {
    
    
    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let location = gesture.location(in: view)
            
            if location.y <= topContainerOffset || isDragPoint(location: location){
                dismissPopup()
            }
        }
    }
 
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .began {
            let location = CGPoint(x: gesture.location(in: view).x, y: gesture.location(in: view).y - 10)
            
            isDragMode = isDragPoint(location: location)
        }
        else if gesture.state == .ended {
            isDragMode = false
            
            if view.frame.origin.y < Constants.MinumOffsetToScrollTop {
                animateToTop()
            }
            else {
                dismissPopup()
            }
        }
        else if gesture.state == .changed {
            
            if isDragMode {
                let translation = gesture.translation(in: self.view)
                self.view.frame.origin.y += translation.y
                
                if self.view.frame.origin.y <= 0 {
                    self.view.frame.origin.y = 0
                }
                
                let alpha = 1.0 - self.view.frame.origin.y / contentView.frame.size.height
                let newAlpha = alpha * Constants.BgAlpha
                bgView.alpha = newAlpha
                
                gesture.setTranslation(.zero, in: self.view)
            }
        }
        else if gesture.state == .failed {
            isDragMode = false
        }
    }
    
    
    func isDragPoint(location: CGPoint) -> Bool {
        return location.y <= topContainerOffset + 20 && location.y >= topContainerOffset - 20
    }
    
}


//MARK: - SetupUI

private extension PopupViewController {
    
    func setupMainContentView() {
        
        contentView = UIView(frame: CGRect(x: 0, y: topContainerOffset, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - topContainerOffset))
        contentView.backgroundColor = UIColor.white
        
        dragImage.image = Images.dragElem.image
        contentView.addSubview(dragImage)
        
        let shadowView = UIView(frame: contentView.frame)
        shadowView.backgroundColor = .white
        shadowView.layer.cornerRadius = Constants.CornerRadius
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 4
        view.addSubview(shadowView)
        
        let maskPath = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: Constants.CornerRadius, height: Constants.CornerRadius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        contentView.layer.mask = shape
        view.addSubview(contentView)
    }
    
    func setupGestures() {
        gestureTap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        gestureTap.delegate = self
        view.addGestureRecognizer(gestureTap)
        
        let gesturePan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        gesturePan.delegate = self
        view.addGestureRecognizer(gesturePan)
    }
}

extension PopupViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == gestureTap {
            
            let location = gestureTap.location(in: view)
            
            if location.y <= topContainerOffset || isDragPoint(location: location) {
                return true
            }
            
            return false
            
        }
        
        return true
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == gestureTap {
            return true
        }
        
        return true
    }
    
}

//MARK: - Additional Methods
private extension PopupViewController {
    
    func animateToTop() {
        UIView.animate(withDuration: Constants.AnimationDuration) {
            self.view.frame.origin.y = 0
            self.bgView.alpha = Constants.BgAlpha
        }
    }
    
    func getTopController() -> UIViewController {
        return AppDelegate.shared().window!.rootViewController!
    }
}
