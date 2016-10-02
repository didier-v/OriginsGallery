//
//  NewPasswordCell.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 23/07/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewPasswordCell: UITableViewCell {
    var tableViewController:ProfileTableViewController?

    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(tableViewController:ProfileTableViewController) {
        self.tableViewController = tableViewController
        sendButton.enabled = false
    }


    @IBAction func passwordEditingChanged(sender: UITextField) {
        if newPasswordField.text == repeatPasswordField.text! && !newPasswordField.text!.isEmpty {
            sendButton.enabled = true
        }
        else {
            sendButton.enabled = false
        }
    }
    
    @IBAction func sendNewPassword() {
        Profile.user.password = newPasswordField.text
        newPasswordField.enabled = false
        repeatPasswordField.enabled = false
        sendButton.enabled = false
        cancelButton.enabled = false
        tableViewController!.tabBarController?.tabBar.hidden = true
        Profile.user.save(tableViewController!) {
            response, statusCode in
            
            self.newPasswordField.enabled = true
            self.repeatPasswordField.enabled = true
            self.sendButton.enabled = true
            self.cancelButton.enabled = true
            self.tableViewController!.tabBarController?.tabBar.hidden = false
            
            if statusCode == 200 {
            switch (response.result) {
            case .Success(let json):
                let data = JSON(json)
                Profile.user.update(data)
                Profile.user.storeCredentials(user: Profile.user.username, password: self.newPasswordField.text!)
                Profile.user.password = nil
                
                let alert:UIAlertController = UIAlertController(title: "Change Password" , message: "Your password has been changed.", preferredStyle:.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                }))
                self.tableViewController!.presentViewController(alert, animated:true, completion:nil);

            case .Failure:
                break
            }
            }
        }
    }
    
    @IBAction func cancelChangePassword() {
        tableViewController!.userContext = .isLogged
        tableViewController!.updateRows(true)
    }
}
