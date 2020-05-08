//
//  BindableView.swift
//  AppTools
//
//  Created by vvisotskiy on 07.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

public protocol BindableView: AnyObject {
    associatedtype ViewOutput
    associatedtype ViewInput
    
    func getOutput() -> ViewOutput
    func bindView(input: ViewInput)
}
