//
//  LoginCell.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 16/05/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Actions
    
    @IBAction func logIn(sender: AnyObject) {
        var userName:String
        var password:String
      
        if let t = userNameField.text {
            userName = t
        }
        else {
            userName=""
        }
        if let t = passwordField.text {
            password = t
        }
        else {
            password = ""
        }
        
        let parameters = [
            "username":userName,
            "password":password,
            "remember":true
        ]

        NSNotificationCenter.defaultCenter().postNotificationName("tryLogin", object: parameters)
    }
    
   
    
    @IBAction func register(sender: AnyObject) {
    }
    
    @IBAction func passwordEditingChanged(sender: AnyObject) {
        if let password = passwordField.text {
            loginButton.enabled = !password.isEmpty
        }
        else {
            loginButton.enabled = false
        }
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

 
    }
    
    // MARK: delegate
    func textFieldDidEndEditing(textField: UITextField) {
        NSNotificationCenter.defaultCenter().postNotificationName("KeyboardToggle", object: false)
            
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        NSNotificationCenter.defaultCenter().postNotificationName("KeyboardToggle", object: true)

    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(textField == userNameField) {
            passwordField.becomeFirstResponder()
        }
        else { // in password
            if let password = textField.text  {
                if !password.isEmpty {
                    logIn(self)
                }
                else {
                    return false
                }
            }
            
        }
        return true
    }

}
