//
//  VIPBinder.swift
//  AppTools
//
//  Created by vvisotskiy on 07.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import Foundation

public enum VIPBinder {
    public static func bind<I: IOTransformer, P: IOTransformer, V: BindableView>(interactor: I, presenter: P, view: V)
        where I.Output == P.Input, P.Output == V.ViewInput, V.ViewOutput == I.Input {
            let viewOutput = view.getOutput()
            let interactorOutput = interactor.transform(viewOutput)
            let presenterOutput = presenter.transform(interactorOutput)
            view.bindView(input: presenterOutput)
    }
    
    public static func bind<I: IOTransformer, P: IOTransformer, V: BindableView>(interactor: I, presenter: P, view: V)
        -> (interactorOutput: I.Output, presenterOutput: P.Output, viewOutput: V.ViewOutput)
        where I.Output == P.Input, P.Output == V.ViewInput, V.ViewOutput == I.Input {
            let viewOutput = view.getOutput()
            let interactorOutput = interactor.transform(viewOutput)
            let presenterOutput = presenter.transform(interactorOutput)
            view.bindView(input: presenterOutput)
            
            return (interactorOutput, presenterOutput, viewOutput)
    }
}
