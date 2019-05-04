//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Darin Williams on 4/20/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

struct AllStudentsInformation: Codable {
    let results: [StudentLocations]
}

struct StudentLocations: Codable {
    let objectId:  String?
    let uniqueKey: String?
    let firstName: String?
    let lastName:  String?
    let mapString: String?
    let mediaURL:  String?
    let latitude:  Double?
    let longitude: Double?


    var studentFullName: String {

        var studentName = ""

        guard let fname = firstName, !fname.isEmpty,
            let  lname = lastName, !lname.isEmpty else {
                return  "No first name Or last Name"
        }

        studentName = fname + lname

        return studentName

    }



    var studentUrl: String {

        //Validate against nil and empty
        guard let  mUrl = mediaURL, !mUrl.isEmpty else {
            return ""
        }

        return mUrl
    }
}



struct SingleStudent: Codable {
    let result: StudentLocations
}


struct StudentInfo: Codable {
    let nickname: String
}


struct StudentNewLocation: Encodable {
    var uniqueKey:String
    var firstName:String?
    var lastName:String?
    var mapString:String
    var mediaURL:String
    var latitude:Double
    var longitude:Double
}

struct StudentPostLocationResponse: Codable {
    let createdAt: String
    let objectId: String
}
