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
    
    
    private static func extractedFunc(_ request: inout URLRequest) {
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerAccept)
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerContentType)
    }
    
    

class func taskForPOSTDecodeRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
    
    var request = URLRequest(url: url)
    
    request.httpMethod = AuthenticationStore.headerPost
 
    extractedFunc(&request)
    

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
        
        extractedFunc(&request)
        
        
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
    
    
    class func taskForDelete(completionHandler: @escaping () -> Void){
        var request = URLRequest(url: EndPoints.logout.url)
        request.httpMethod = AuthenticationStore.headerDelete
        
        extractedFunc(&request)

        
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
