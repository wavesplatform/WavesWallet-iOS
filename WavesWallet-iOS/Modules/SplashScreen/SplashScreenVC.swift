import UIKit
import UITools

final class SplashScreenVC: UIViewController {
    @IBOutlet private var gradientView: SplashScreenGradientView!

    var animatedCompleted: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.gradientView.runAnimations()
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

}

extension SplashScreenVC: SplashScreenGradientViewDelegate {
    func splashScreenCompleted() {
        animatedCompleted?()
    }
}

extension SplashScreenVC: StoryboardInstantiatable {}
