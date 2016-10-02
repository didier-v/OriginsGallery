//
//  RegisterTableViewController.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 28/05/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterTableViewController: UITableViewController {

    var registerInfo: [String:String] = [:]
    var hasAgreed:Bool = false
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerInfo = [:]
        
        self.tableView.tableFooterView = UIView()

        userNameField.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterTableViewController.registerWasSuccessful(_:)), name:"RegisterWasSuccessful", object: nil)
        
        
        //TERMS
        let font = UIFont(name: "Raleway-Regular", size: 18)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .Center
        let text = NSMutableAttributedString(string: "By registering, you agree with the ", attributes: [
            NSFontAttributeName:font!,
            NSForegroundColorAttributeName:MainTintColor,
            NSParagraphStyleAttributeName:titleParagraphStyle
            ])
        text.appendAttributedString(NSAttributedString(string: "Terms and Conditions", attributes: [
            NSFontAttributeName:font!,
            NSForegroundColorAttributeName: UIColor.redColor()
            ]))
        text.appendAttributedString(NSAttributedString(string: " of NMSOrigins.", attributes: [
            NSFontAttributeName:font!,
            NSForegroundColorAttributeName:MainTintColor
            ]))
        termsLabel.attributedText = text
        
        //Check
        let tapCheckGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckBox(_:)))
        checkBox.addGestureRecognizer(tapCheckGesture)
        
        let tapTermsGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTerms(_:)))
        termsLabel.addGestureRecognizer(tapTermsGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func didTapCheckBox(sender: AnyObject) {
        if !hasAgreed {
            checkBox.image = UIImage(named: "check")
        }
        else {
            checkBox.image = nil
        }
        hasAgreed = !hasAgreed
    }
    
    @IBAction func didTapTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:URL_TERMS)!)
    }

    
    @IBAction func registerAction() {
        sendRegister()
    }
    
    // MARK: - Private
    
    private func sendRegister() {
        var parameters:[String:AnyObject] = [:]
        
        if userNameField.text!.isEmpty {
            alertRegister("Required", message: "Please enter a user name.")
           return
        }
        if let count = (userNameField.text?.characters.count)! as Int? {
            switch count {
            case 0...2 :
                    alertRegister("Required", message: "The user name is too short (3 characters min).")
                    return
            case 3...30 :
                break
            default:
                alertRegister("Required", message: "The user name is too long (30 characters max).")
                return
            }
        }
        if emailField.text!.isEmpty {
            alertRegister("Required", message: "Please enter a valid email.")
            return
        }
        else {
            if !emailField.text!.isEmail {
                alertRegister("Required", message: "Please enter a valid email.")
                return
            }
        }
        
        if passwordField.text!.isEmpty {
            alertRegister("Required", message: "Please enter a password.")
            return
        }
        if passwordField.text != repeatPasswordField.text {
            alertRegister("Required", message: "Both passwords must match.")
            return
        }
        if !hasAgreed {
            alertRegister("Required", message: "You must agree with the Terms and Conditions by checking the white box.")
            return
        }
        
        parameters["username"]=userNameField.text
        parameters["email"]=emailField.text
        parameters["password"]=passwordField.text
        parameters["password2"]=repeatPasswordField.text
        parameters["termsAndConditions"]=["accepted":true]
        
        // send register
        Alamofire.request(.POST, URL_REGISTER, parameters:parameters,encoding: .JSON)
            .responseJSON { response  in
                switch (response.result) {
                case .Success(let json):
                    let r = JSON(json)
                    print (r)
                    if (r["email"].stringValue == "email duplicate") {
                        self.alertRegister("Register failed", message: "There is already an account with this email.")
                    }
                    else if(r["username"]=="username duplicated") {
                        self.alertRegister("Register failed", message: "There is already an account with this user name.")
                    }
                    else if !r["id"].stringValue.isEmpty {
                        // success
                        self.alertRegister("Success", message:"You will receive an E-Mail to activate your account, please check your junk folder in case you can't find it in your inbox.", leave:true)
                    }
                    
                case .Failure(let error):
                    print("failed with error",error)
                    self.alertRegister("Error", message: error.localizedDescription)
                    Profile.user.isLogged = false
                }
                self.tableView.reloadData()
        }
    }
    
    private func alertRegister(title: String, message: String, leave:Bool = false) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            action in
            if leave {
                NSNotificationCenter.defaultCenter().postNotificationName("RegisterWasSuccessful", object: nil)
            }
        }))
        self.presentViewController(ac, animated: true, completion: nil)
    }

    
    // MARK: - Notifications

    func registerWasSuccessful(notification:NSNotification) {
        self.performSegueWithIdentifier("backToProfileTableViewController", sender: self)
    }


}

// MARK: - TextView Delegate

extension RegisterTableViewController : UITextViewDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case userNameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            repeatPasswordField.becomeFirstResponder()
        case repeatPasswordField:
            self.registerAction()
        default:
            break
        }

        return true
    }
}

