//
//  DisplayError.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DisplayError: Equatable {
    case globalError(isInternetNotWorking: Bool)
    case internetNotWorking
    case notFound
    case message(String)
    case scriptError
}

enum DisplayErrorState {
    case waiting
    case error(DisplayError)
    case none
}

extension DisplayError {

    init(error: Error) {

        switch error {
        case let appError as NetworkError:
            switch appError {
            case .internetNotWorking:
                self = .internetNotWorking

            case .notFound:
                self = .notFound

            case .serverError:
                self = .notFound

            case .message(let message):
                self = .message(message)

            case .scriptError:
                self = .scriptError
            
            case .authWallet:
                self = .notFound
            }

        default:
            self = .notFound
        }
    }
}

extension DisplayErrorState {

    static func displayErrorState(hasData: Bool, error: Error) -> DisplayErrorState {

        var displayError: DisplayError!

        if hasData == false {
            let isInternetNotWorking = (error as? NetworkError)?.isInternetNotWorking ?? false
            displayError = .globalError(isInternetNotWorking: isInternetNotWorking)
        } else {

            displayError = DisplayError(error: error)
        }

        return .error(displayError)
    }
}
