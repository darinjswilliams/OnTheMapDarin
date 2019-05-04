//
//  AuthenticationStore.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/27/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

struct AuthenticationStore {
    static let loginUrl = "https://onthemap-api.udacity.com/v1/session"
    static let signUpUrl = "https://auth.udacity.com/sign-up"
    static let notValid = "Credentials not Valid"
    static let userName = "username"
    static let passWord = "password"
    
    static var sessionId = ""
    static let headerJsonFormat = "application/json"
    static let headerContentType = "Content-Type"
    static let headerAccept = "Accept"
    static let headerPost = "POST"
    static let headerGet = "GET"
    static let headerDelete = "DELETE"
    static let limit = "100"
    static var userKey = ""
    static var headerUserKey = "User-Key"
    static var parseAppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static var parseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static var headerParseAppId = "X-Parse-Application-Id"
    static var headerParseAppKey = "X-Parse-REST-API-Key"
    
}

struct LoginRequest: Codable {
    let udacity: UserCredentials
}

struct UserCredentials: Codable {
    let username: String
    let password: String
}


struct LoginResponse: Codable {
    let account: Account?
    let session: Session?
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}


struct UserProfile {
    var last_name: String
    var first_name: String
    var nickname: String
    
}

extension UserProfile: Codable {
    enum CodingKeys: String, CodingKey {
        case last_name = "last_name"
        case first_name = "first_name"
        case nickname = "nickname"
    }
}



