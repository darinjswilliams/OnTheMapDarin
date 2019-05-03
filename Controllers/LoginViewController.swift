//
//  LoginViewController.swift
//  OnTheMapDarin
//
//  Created by Darin Williams on 4/27/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginUser(_ sender: Any) {
        
        guard let userEmailAddr = self.emailAddress.text, !userEmailAddr.isEmpty else {
            showFailure(message: "Email Required")
            return
        }
        
        guard let userPassWord = self.passWord.text, !userPassWord.isEmpty else {
            showFailure(message: "Password Required")
            return
        }
        
        authenticationLoginSession(username: userEmailAddr, password: userPassWord)
       
    }
    
    
    
    @IBAction func signUpUser(_ sender: Any) {
    }
    
    
    private func  authenticationLoginSession(username: String, password: String){
        
//        OnTheMapRestClient.logInUdacity(username: username, password: password  )
        OnTheMapRestClient.login(username: username, password: password, completionHandler: handleLoginResponse(success:error:))
        
    }
    
    func handleLoginResponse(success: Bool, error: Error?){
   
        if success {
            
            self.performUIUpdatesOnMain {
                self.emailAddress.text = ""
                self.passWord.text = ""
                
                let mainController =  self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarController") as! UITabBarController
                self.present(mainController, animated: true, completion: nil)
                
            }
        } else {
            self.performUIUpdatesOnMain {
                self.showFailure(message: "Login falied")
            }
        }
        

    }


}
