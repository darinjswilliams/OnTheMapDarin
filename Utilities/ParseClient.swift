//
//  ParseClient.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/28/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

class ParseClient {
    
    
    class func requestLimitedStudents(completion: @escaping ([StudentLocations]?, Error?)-> Void){
        requestGetStudents(url: EndPoints.getStudentLimit.url) { (response, error) in
            guard let response = response else {
                print("requestLimitedStudents: Failed")
                completion(nil, error)
                return
            }
            completion(response,nil)
        }
    }
    
    class func requestGetStudents(url: URL, completionHandler: @escaping ([StudentLocations]?,Error?)->Void) {
        var request = URLRequest(url: url)
   
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
                let result = try jsonDecoder.decode(AllStudentsInformation.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(result.results, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
    }
    
    class func getSortedStudentList(completion: @escaping ([StudentLocations]?, Error?)-> Void){
        
        NSLog("Entering GetSortedStudentList:")
        
        requestGetStudents(url: EndPoints.getStudentOrder.url) { (response, error) in
            
            guard let response = response else {
                print("requestSortedStudentLists: Failed")
                completion(nil, error)
                return
            }
            print("getStudentList..\(response)")
            completion(response,error)
        }
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
