// ___FILEHEADER___

import AppTools
import RxSwift

final class ___VARIABLE_productName___Interactor: ___VARIABLE_productName___Interactable {
    private let presenter: ___VARIABLE_productName___Presentable
    init(presenter: ___VARIABLE_productName___Presentable) {
        self.presenter = presenter
    }
}

// MARK: - IOTransformer

extension ___VARIABLE_productName___Interactor: IOTransformer {
    func transform(_ input: ___VARIABLE_productName___ViewOutput) -> ___VARIABLE_productName___InteractorOutput {
        return ___VARIABLE_productName___InteractorOutput()
    }
}
