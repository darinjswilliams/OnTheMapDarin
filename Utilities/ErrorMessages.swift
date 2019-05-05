//
//  ErrorMessages.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 5/5/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

enum ErrorMessages: Error {
    
    case invalidCredentials(String)
    case failureToConnect(String)
    case otherError(String)
    
    
    
    func credentialsValidation(withErrorStatusCode errorStatusCode: Int) throws {
        switch errorStatusCode {
        case 400:
            throw ErrorMessages.invalidCredentials("Bad Request")
        case 401:
            throw ErrorMessages.invalidCredentials("UnAuthorize")
        case 403:
            throw ErrorMessages.invalidCredentials("Account not found or invalid credentials.")
        case 404:
            throw ErrorMessages.invalidCredentials("Not Found")
        case 408:
            throw ErrorMessages.invalidCredentials("Request Timeout")
        case 500:
            throw ErrorMessages.failureToConnect("Internal Server")
        case 503:
            throw ErrorMessages.failureToConnect("Service Unavailable")
        case 505:
            throw ErrorMessages.failureToConnect("HTTP Version Not Supported")
        case 511:
            throw ErrorMessages.failureToConnect("Network Authentication Required")
            
        default:
            throw ErrorMessages.otherError("Network Error")
        }
    }
}
