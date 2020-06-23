import UIKit

final class SplashScreenVC: UIViewController {
    @IBOutlet private var gradientView: SplashScreenGradientView!

    var animatedCompleted: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.gradientView.runAnimations()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension SplashScreenVC: SplashScreenGradientViewDelegate {
    func splashScreenCompleted() {
        animatedCompleted?()
    }
}
