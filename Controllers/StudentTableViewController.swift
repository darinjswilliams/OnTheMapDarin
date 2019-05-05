//
//  StudentTableViewController.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/28/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {

    
    var studentInformation: [StudentLocations] = [StudentLocations]()
    
    @IBOutlet var studentPinTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateTable()
      
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = studentInformation[indexPath.row].mediaURL
        if verifyUrl(urlString: url){
            let temp = URL(string: url!)
            UIApplication.shared.open(temp!, options: [:])
        }else {
            showFailure(message: "URL is not Valid")
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //MARK deque
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "studentsInformation", for: indexPath)
        
        tableCell.textLabel?.text =  self.studentInformation[indexPath.row].studentFullName
        tableCell.detailTextLabel?.text = self.studentInformation[indexPath.row].studentUrl
        tableCell.imageView?.image = UIImage(named: "icon_pin")
        
        return tableCell
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentInformation.count
    }

    @objc func populateTable(){
//        ParseClient.getSortedStudentList(completionHandler: handleStudentResponse(studentLocations:error:))
        
        ParseClient.processStudentRequest(url: EndPoints.getStudentLimit.url, completionHandler: handleStudentResponse(studentLocations:error:))
    }
    
    func handleStudentResponse(studentLocations:[StudentLocations]?, error:Error?) {
        
        //check pre condtions
        guard let studentLocations = studentLocations else {
            //MARK CALL ERROR FUNCTION
            return
        }
        studentInformation = studentLocations
        DispatchQueue.main.async {
            // reload table
            self.studentPinTableView.reloadData()
        }
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }

    @IBAction func logOut(_ sender: Any) {
        OnTheMapRestClient.taskForDelete {
        }
        DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func reFreshInformation(_ sender: Any) {
    self.populateTable()
    }
    
    @IBAction func addStudentLocation(_ sender: Any) {
        
        //MARK ADD SEQUE TO ADD STUDENT
        performSegue(withIdentifier: "findLocationfromListView", sender: nil)
    }
}
