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
}

enum DisplayErrorState {
    case waiting
    case error(DisplayError)
    case none
}

extension DisplayErrorState {

    static func displayErrorState(hasData: Bool, error: Error) -> DisplayErrorState {

        var displayError: DisplayError!

        if hasData == false {
            let isInternetNotWorking = (error as? NetworkError)?.isInternetNotWorking ?? false
            displayError = .globalError(isInternetNotWorking: isInternetNotWorking)
        } else {

            switch error {
            case let appError as NetworkError:
                switch appError {
                case .internetNotWorking:
                    displayError = .internetNotWorking

                case .notFound:
                    displayError = .notFound

                case .serverError:
                    displayError = .notFound

                case .message(let message):
                    displayError = .message(message)
                }

            default:
                displayError = .notFound
            }
        }

        return .error(displayError)
    }
}
