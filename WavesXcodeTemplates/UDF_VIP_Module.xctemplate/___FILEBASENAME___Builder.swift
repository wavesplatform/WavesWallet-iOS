// ___FILEHEADER___

import AppTools
import UITools

final class ___VARIABLE_productName___Builder: ___VARIABLE_productName___Buildable {
    func build() -> ___VARIABLE_productName___ViewController {
        // MARK: - Dependency

        // let dependency = ...

        // MARK: - Instantiating

        let presenter = ___VARIABLE_productName___Presenter()
        let interactor = ___VARIABLE_productName___Interactor(presenter: presenter)
        let viewController = ___VARIABLE_productName___ViewController.instantiateFromStoryboard()
        viewController.interactor = interactor

        // MARK: - Binding

        VIPBinder.bind(interactor: interactor, presenter: presenter, view: viewController)

        return viewController
    }
}
