//
//  TitledModel.swift
//  AppTools
//
//  Created by vvisotskiy on 22.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import Foundation

public struct TitledModel<Model: Hashable>: Hashable {
    public let title: String
    public let model: Model

    public init(title: String, model: Model) {
        self.title = title
        self.model = model
    }
}

extension TitledModel {
    public func copy(newTitle: String, newModel: Model) -> TitledModel {
        TitledModel(title: newTitle, model: newModel)
    }
    
    public func copy(newModel: Model) -> TitledModel {
        TitledModel(title: title, model: newModel)
    }
}

public struct TitledOptionalModel<Model: Hashable>: Hashable {
    public let title: String
    public let model: Model?

    public init(title: String, model: Model?) {
        self.title = title
        self.model = model
    }
}

extension TitledOptionalModel {
    public func copy(newTitle: String, newModel: Model?) -> TitledOptionalModel {
        TitledOptionalModel(title: newTitle, model: newModel)
    }
    
    public func copy(newModel: Model?) -> TitledOptionalModel {
        TitledOptionalModel(title: title, model: newModel)
    }
}
