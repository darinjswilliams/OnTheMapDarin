//
//  UdacityClient.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/27/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

class OnTheMapRestClient  {
    
class func login(username: String, password: String, completionHandler: @escaping (Bool, Error?) -> Void) {
    let body = LoginRequest(udacity: UserCredentials(username: username, password: password))
    
    
    //Get the login base with session parameter attached
    taskForPOSTDecodeRequest(url: EndPoints.getAuthenticateUser.url, responseType: LoginResponse.self, body: body) { response, error in
        if let response = response {
            //Add session
            print("login func: \(response)")
            AuthenticationStore.userKey = (response.account?.key)!
            AuthenticationStore.sessionId = (response.session?.id)!
            completionHandler(true, error)
        } else {
            completionHandler(false, error)
        }
    }
}
    
 class func getSingleStudentInformation(completionHandler: @escaping (Bool, Error?) -> Void){
    taskForGETRequest(url: EndPoints.getUserSession(AuthenticationStore.userKey).url, responseType: StudentInfo.self) { response, error in
        if let response = response {
            print("getSingleStudentInformation: success \(response.nickname)")
            DispatchQueue.main.async {
                completionHandler(true, error)
            }
        } else {
             DispatchQueue.main.async {
                 completionHandler(false, error)
            }
        }

      }
    }

class func taskForPOSTDecodeRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
    
    var request = URLRequest(url: url)
    
    request.httpMethod = AuthenticationStore.headerPost
 
    
    request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField:        AuthenticationStore.headerAccept)
    request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerContentType)
    request.httpBody = try! JSONEncoder().encode(body)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            DispatchQueue.main.async {
                completionHandler(nil, error)
            }
            return
        }
        print("taskForPOSTRequest... \(data)")
        print(data.count)
        
        let range = Range(5..<data.count)
        let loginResponseData = data.subdata(in: range) /*subset response data! */
        print(String(data: loginResponseData, encoding: .utf8)!)
        
    
        let decoder = JSONDecoder()
        do {
            let responseObject = try decoder.decode(ResponseType.self, from: loginResponseData)
            DispatchQueue.main.async {
                completionHandler(responseObject, nil)
            }
        } catch {
            do {
                let errorResponse = try decoder.decode(OnTheMapErrorResponse.self, from: loginResponseData) as Error
                DispatchQueue.main.async {
                    completionHandler(nil, errorResponse)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
    }
    task.resume()
  }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type,  completionHandler: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
         var request = URLRequest(url: url)
        
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerAccept)
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerContentType)
        
        
        let assumeDownLoadTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            // guard there is data
            guard let data = data else {
                // TODO: CompleteHandler can return error
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let jsonDecoder = JSONDecoder()
            do {
                let result = try jsonDecoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completionHandler(result, error)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        assumeDownLoadTask.resume()
        
        return assumeDownLoadTask
    }
    
    
    
    
    class func taskForPOSTRequest(url: URL, body: String, completion: @escaping (
        Data?, Error?) -> Void)-> URLSessionDataTask{
        
        var request = URLRequest(url: url)
        request.httpMethod = AuthenticationStore.headerPost
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerAccept)
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerContentType)
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("Request did not return a valid response.")
                return
            }
            
            switch (statusCode) {
            case 403:
                sendError("Please check your credentials and try again.")
            case 200 ..< 299:
                break
            default:
                sendError("Your request returned a status code other than 2xx!")
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var newData = data
            let range = Range(5..<data.count)
            newData = data.subdata(in: range)
            
            completion(newData, nil)
        }
        task.resume()
        return task
    }
    
//    class func requestSignedInUserInfo(completionHandler: @escaping (StudentInfo?,Error?)->Void) {
//        let url = EndPoints.getUserSession(AuthenticationStore.userKey).url
//        print("requestSignedInUserInro \(url)")
//        var request = URLRequest(url: url)
//  
//        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerAccept)
//        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerContentType)
//       request.addValue(AuthenticationStore.headerParseAppId, forHTTPHeaderField: AuthenticationStore.parseAppId)
//        
//        request.addValue(AuthenticationStore.headerUserKey, forHTTPHeaderField: AuthenticationStore.headerParseAppKey)
//        
//         request.addValue(AuthenticationStore.userKey, forHTTPHeaderField: AuthenticationStore.headerUserKey)
//        
//        let assumeDownLoadTask = URLSession.shared.dataTask(with: request) {
//            (data, response, error) in
//            // guard there is data
//            guard let data = data else {
//                // TODO: CompleteHandler can return error
//                DispatchQueue.main.async {
//                    completionHandler(nil, error)
//                }
//                return
//            }
//            let range = Range(5..<data.count)
//            let newData = data.subdata(in: range)
//            let jsonDecoder = JSONDecoder()
//            do {
//                let result = try jsonDecoder.decode(StudentInfo.self, from: newData)
//                DispatchQueue.main.async {
//                    completionHandler(result, nil)
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    completionHandler(nil,error)
//                }
//            }
//        }
//        
//        assumeDownLoadTask.resume()
//    }
    
//    class func logInUdacity(username: String, password: String, completion: @escaping (Bool, Error?)->Void){
//        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
//        _ = taskForPOSTRequest(url: EndPoints.getAuthenticateUser.url, body: body, completion: { (data, error) in
//            if let error = error {
//                print(error)
//                completion(false, error)
//            } else {
//                let userSessionData = self.parseUserSession(data: data)
//                if let sessionData = userSessionData.0 {
//                    guard let account = sessionData.account, account.registered == true else {
//                        completion(false, error)
//                        return
//                    }
//                    guard let userSession = sessionData.session else {
//                        completion(false, error)
//                        return
//                    }
//                    AuthenticationStore.userKey = account.key
//                    print("Authetication Key = \(AuthenticationStore.userKey)")
//                    UserDefaults.standard.set(account.key, forKey: "accountKey")
//                    UserDefaults.standard.set(userSession.id, forKey: "UserSession")
//                    AuthenticationStore.sessionId = userSession.id
//
//                     completion(true, nil)
//
//                } else {
//
//                    completion(false, error)
//
//                }
//            }
//        })
//    }
    
    
    class func parseUserSession(data: Data?) -> (LoginResponse?, Error?) {
        var studentsLocation: (userSession: LoginResponse?, error: Error?) = (nil, nil)
        do {
            if let data = data {
                let jsonDecoder = JSONDecoder()
                studentsLocation.userSession = try jsonDecoder.decode(LoginResponse.self, from: data)
            }
        } catch {
            print("Could not parse the data as JSON: \(error.localizedDescription)")
            let userInfo = [NSLocalizedDescriptionKey : error]
            studentsLocation.error = NSError(domain: "parseUserSession", code: 1, userInfo: userInfo)
        }
        return studentsLocation
    }
    
    
    class func taskForDelete(completionHandler: @escaping () -> Void){
        var request = URLRequest(url: EndPoints.logout.url)
        request.httpMethod = AuthenticationStore.headerDelete
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerAccept)
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerContentType)
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("enter task for delete")
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            AuthenticationStore.sessionId = ""
            AuthenticationStore.userKey = ""
        }
        task.resume()
    }
}
