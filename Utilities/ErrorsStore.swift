//
//  ErrorsStore.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/27/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import UIKit

struct OnTheMapErrorResponse: Codable {
    let status: Int
    let error: String
}

extension OnTheMapErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}


struct ErrorCode {
    
    static let inValidErrorCode = 400
    
}
