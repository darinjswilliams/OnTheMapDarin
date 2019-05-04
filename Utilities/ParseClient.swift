//
//  ParseClient.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/28/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

class ParseClient {
    
    
    class func requestLimitedStudents(completionHandler: @escaping ([StudentLocations]?, Error?)-> Void){
        taskForGETRequest(url: EndPoints.getStudentLimit.url, response: AllStudentsInformation.self) { (response, error) in
            guard let response = response else {
                print("requestLimitedStudents: Failed")
             DispatchQueue.main.async {
                completionHandler(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(response.results, error)
            }
        }
    }
    
    
    //This is Called by Studnet List Controller
    class func getSortedStudentList(completionHandler: @escaping ([StudentLocations]?, Error?)-> Void){
        
        
        taskForGETRequest(url: EndPoints.getStudentOrder.url, response: AllStudentsInformation.self) { (response, error) in
            
            guard let response = response else {
                print("requestSortedStudentLists: Failed")
                completionHandler(nil, error)
                return
            }
            print("getStudentList..\(response)")
            completionHandler(response.results,error)
        }
    }
    

    class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type,  completionHandler: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        print("here is the url \(url)")
        
        request.addValue(AuthenticationStore.parseAppId, forHTTPHeaderField: AuthenticationStore.headerParseAppId)
        
        request.addValue(AuthenticationStore.parseApiKey, forHTTPHeaderField: AuthenticationStore.headerParseAppKey)
        
        
        let downloadTask = URLSession.shared.dataTask(with: request) {
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
                let result = try jsonDecoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(result, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
        
        return downloadTask
    }
    
    
    class func postStudentNewLocation(postInformation:StudentNewLocation, completionHandler: @escaping (StudentPostLocationResponse?, Error?)-> Void) {
        
    
        taskForPostNewLocations(url: EndPoints.getStudentLimit.url, responseType: StudentPostLocationResponse.self,  body: postInformation )
        { (response, error) in
            guard let response = response else {
                print("requestLimitedStudents: Failed")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(response, error)
            }
        }
    }
    

class func taskForPostNewLocations<RequestType: Encodable, ResponseType: Decodable>(url: URL,  responseType: ResponseType.Type, body: RequestType, completionHandler: @escaping (ResponseType?, Error?)->Void) -> URLSessionDataTask {
        
    var request = URLRequest(url: url)
    request.httpMethod = AuthenticationStore.headerPost
    request.addValue(AuthenticationStore.parseAppId, forHTTPHeaderField: AuthenticationStore.headerParseAppId)
    
    request.addValue(AuthenticationStore.parseApiKey, forHTTPHeaderField: AuthenticationStore.headerParseAppKey)
    request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerContentType)
    
     request.httpBody = try! JSONEncoder().encode(body)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            DispatchQueue.main.async {
                completionHandler(nil, error)
            }
            return
        }
        
        let jsonDecoder = JSONDecoder()
        do {
            
            let responseData = try! jsonDecoder.decode(
               ResponseType.self, from: data)
              print(String(data: data, encoding: .utf8)!)
            
                DispatchQueue.main.async {
                    completionHandler(responseData,error)
                }
            
        } catch {
            DispatchQueue.main.async {
                completionHandler(nil,error)
            }
        }
    }
    task.resume()
    
    return task
 }

    
    class func requestPostLocations(postInformation:StudentNewLocation, completionHandler: @escaping (StudentPostLocationResponse?,Error?)->Void) {
        let endpoint:URL = EndPoints.getStudentBase.url
        var request = URLRequest(url: endpoint)
        request.httpMethod = AuthenticationStore.headerPost
        request.addValue(AuthenticationStore.parseAppId, forHTTPHeaderField: AuthenticationStore.headerParseAppId)
        
        request.addValue(AuthenticationStore.parseApiKey, forHTTPHeaderField: AuthenticationStore.headerParseAppKey)
        request.addValue(AuthenticationStore.headerJsonFormat, forHTTPHeaderField: AuthenticationStore.headerContentType)
        
        let jsonEncoder = JSONEncoder()
        let encodedPostData = try! jsonEncoder.encode(postInformation)
        request.httpBody = encodedPostData
        print(encodedPostData)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                print(error!)
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                print(data.base64EncodedString())
                let decodedData = try jsonDecoder.decode(
                    StudentPostLocationResponse.self, from: data)
                print(decodedData)
                DispatchQueue.main.async {
                    completionHandler(decodedData,nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        task.resume()
    }
    
}
