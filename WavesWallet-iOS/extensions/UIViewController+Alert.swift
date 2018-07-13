import Foundation
import UIKit

extension UIViewController {
    public func presentBasicAlertWithTitle(title: String, message: String? = nil,
                                           completion: (() -> Void)? = nil) {
        if presentedViewController == nil {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
                    if let completion = completion {
                        completion()
                    }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func presentAskAlert(title: String, message: String? = nil, yesCompletion: (() -> Void)? = nil, noCompletion: (() -> Void)? = nil) {
        if presentedViewController == nil {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
                if let completion = yesCompletion {
                    completion()
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                
                if let completion = noCompletion {
                    completion()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
