//
//  PopupViewController.swift
//  TestPopup
//
//  Created by Pavel Gubin on 5/22/18.
//  Copyright © 2018 Pavel Gubin. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    var bgView : UIView?
    var contentView : UIView!
    var topContainerOffset : CGFloat = Platform.isIphoneX ? 150 : 64
    let bgAlpha : CGFloat = 0.4
    var dragImage : UIImageView!
    var isDragMode = false
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        contentView = UIView(frame: CGRect(x: 0, y: topContainerOffset, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - topContainerOffset))
        contentView.backgroundColor = UIColor.white
        
        dragImage = UIImageView(frame: CGRect(x: (contentView.frame.size.width - 36) / 2.0, y: 6, width: 36, height: 4))
        dragImage.image = UIImage(named: "dragElem")
        contentView.addSubview(dragImage)
        
        let corner: CGFloat = 12
        
        let shadowView = UIView(frame: contentView.frame)
        shadowView.backgroundColor = .white
        shadowView.layer.cornerRadius = corner
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 4
        view.addSubview(shadowView)
        
        let maskPath = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: corner, height: corner))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        contentView.layer.mask = shape
        view.addSubview(contentView)
        
        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        view.addGestureRecognizer(gestureTap)
        
        let gesturePan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        view.addGestureRecognizer(gesturePan)
    }

    
    func dismissPopup() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.origin.y = self.view.frame.size.height
            self.bgView?.alpha = 0
        }) { (compelte) in
            
            self.bgView?.removeFromSuperview()
            self.view.removeFromSuperview()
            self.willMove(toParentViewController: nil)
            self.removeFromParentViewController()
        }
    }

    
    func getTopController() -> UIViewController {
        return AppDelegate.shared().window!.rootViewController!
    }
    
    func present(contentViewController: UIViewController) {
        
        let topController = getTopController()
        bgView = UIView(frame: UIScreen.main.bounds)
        bgView!.backgroundColor = .black
        bgView!.alpha = 0
        topController.view.addSubview(bgView!)
        
        topController.addChildViewController(self)
        didMove(toParentViewController: topController)
        topController.view.addSubview(view)

        let contentOffset: CGFloat = 20
        
        addChildViewController(contentViewController)
        contentViewController.didMove(toParentViewController: self)
        contentViewController.view.frame = CGRect(x: 0, y: contentOffset,
                                                  width: contentView.frame.size.width,
                                                  height: contentView.frame.size.height - contentOffset)
        contentView.addSubview(contentViewController.view)
        
        view.frame.origin.y = view.frame.size.height
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
            self.bgView?.alpha = self.bgAlpha
        }
    }
    
    func animateToTop() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
            self.bgView?.alpha = self.bgAlpha
        }
    }
    //MARK: - Gesture
    
    func isDragPoint(location: CGPoint) -> Bool {
        return  location.x >= dragImage.frame.origin.x - 15 &&
                location.x <= dragImage.frame.origin.x + dragImage.frame.size.width + 15 &&
                location.y <= topContainerOffset + 30 && location.y >= topContainerOffset - 20
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .began {
            let location = CGPoint(x: gesture.location(in: view).x, y: gesture.location(in: view).y - 10)

            if isDragPoint(location: location) {
                isDragMode = true
            }
            else {
                isDragMode = false
            }
        }
        else if gesture.state == .ended {
            isDragMode = false
            
            if view.frame.origin.y < 150 {
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
                let newAlpha = alpha * bgAlpha
                bgView?.alpha = newAlpha
                
                gesture.setTranslation(.zero, in: self.view)
            }
        }
        else if gesture.state == .failed {
            isDragMode = false
        }
    }
    
    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let location = gesture.location(in: view)

            if location.y <= topContainerOffset || isDragPoint(location: location){
                dismissPopup()
            }
        }
    }
  
    deinit {
        print(self.classForCoder,#function)
    }
}
