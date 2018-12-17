//
//  WindowCoordinator.swift
//  CoordinatorKit
//
//  Created by Ian MacCallum on 10/11/17.
//

public protocol WindowCoordinatorType: BaseCoordinatorType {
	var router: WindowRouterType { get }
}

open class WindowCoordinator<DeepLinkType>: NSObject, WindowCoordinatorType {
	
	public var childCoordinators: [PresentableCoordinator<DeepLinkType>] = []
	
	open var router: WindowRouterType
	
	public init(router: WindowRouterType) {
		self.router = router
		super.init()
	}
	
	open func start() { start(with: nil) }
	open func start(with link: DeepLinkType?) {}
	
	public func addChild(_ coordinator: Coordinator<DeepLinkType>) {
		childCoordinators.append(coordinator)
	}
	
	public func removeChild(_ coordinator: Coordinator<DeepLinkType>?) {
		
		if let coordinator = coordinator, let index = childCoordinators.index(of: coordinator) {
			childCoordinators.remove(at: index)
		}
	}
}

final public class NavigationRouter: NSObject, UINavigationControllerDelegate {

    private var completions: [UIViewController : () -> Void]

    public var rootViewController: UIViewController? {
        return navigationController.viewControllers.first
    }

    public var hasRootController: Bool {
        return rootViewController != nil
    }

    public let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.completions = [:]
        super.init()
        self.navigationController.delegate = self
    }

    public func present(_ module: Presentable, animated: Bool = true) {
        navigationController.present(module.toPresentable(), animated: animated, completion: nil)
    }

    public func dismissModule(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }

    public func push(_ module: Presentable, animated: Bool = true, completion: (() -> Void)? = nil) {

        let controller = module.toPresentable()

        // Avoid pushing UINavigationController onto stack
        guard controller is UINavigationController == false else {
            return
        }

        if let completion = completion {
            completions[controller] = completion
        }

        navigationController.pushViewController(controller, animated: animated)
    }

    public func popModule(animated: Bool = true)  {
        if let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }

    public func setRootModule(_ module: Presentable, hideBar: Bool = false) {
        // Call all completions so all coordinators can be deallocated
        completions.forEach { $0.value() }
        navigationController.setViewControllers([module.toPresentable()], animated: false)
        navigationController.isNavigationBarHidden = hideBar
    }

    public func popToRootModule(animated: Bool) {
        if let controllers = navigationController.popToRootViewController(animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }

    fileprivate func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }


    // MARK: Presentable

    public func toPresentable() -> UIViewController {
        return navigationController
    }


    // MARK: UINavigationControllerDelegate

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {

        // Ensure the view controller is popping
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(poppedViewController) else {
                return
        }

        runCompletion(for: poppedViewController)
    }
}

