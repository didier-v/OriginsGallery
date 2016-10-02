//
//  ProfileTableViewController.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 16/05/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class ProfileTableViewController: UITableViewController {
    enum CellIdentifier: String {
        case
        ConnectingCell,
        LoginCell,
        ProfileCell,
        ResetPasswordCell,
        SelectLoginTypeCell,
        TwitterCell,
        RedditCell,
        SteamCell,
        EmailCell,
        LoginOptionCell,
        LoginTwitterCell,
        LoginRedditCell,
        LoginSteamcell,
        ChangePasswordCell,
        NewPasswordCell,
        LogoutCell,
        CountsCell
    }
    enum Context:String {
        case
        isLogged,
        isLogging,
        isLogout,
        isInEmail,
        isInTwitter,
        isInReddit,
        isInSteam,
        ChangingPassword
    }
    
    var forgotPasswordAlertController: UIAlertController?
    var rows:[(CellIdentifier,JSON?)] = Array<(CellIdentifier,JSON?)>()
    var isEnteringEmail:Bool = false
    var currentAPI:SocialAPI?
    var userContext:Context?
    var counts: JSON?
    var score: Int = 0
    var context:Context {
        get {
            if Profile.user.isLogged {
                if userContext == .ChangingPassword {
                    return userContext!
                }
                return .isLogged
            }
            else if Profile.user.isLogging{
                return .isLogging
            }
            else {
                return userContext ?? .isLogout
            }
        }
    }
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 160.0;//(Maximum Height that should be assigned to your cell)

        
        //NOTIFICATIONS
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileTableViewController.tryLogin(_:)), name:"tryLogin", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileTableViewController.didLogin(_:)), name:"didLogin", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileTableViewController.didLogout(_:)), name:"didLogout", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileTableViewController.keyboardToggle(_:)), name:"KeyboardToggle", object: nil)
        
        #if DEBUG
        self.title = "(DEV) Profile"
        #endif
        
        
        
    }
    override func viewDidAppear(animated: Bool) {
        fetchCounts()
        fetchScore()
        updateRows(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateRows(reload:Bool) {
        let lastCount = rows.count
        var preferredAnimation:UITableViewRowAnimation = .None
        var minRow:Int = 0
        switch context {
        case .ChangingPassword:
            rows = [(.ProfileCell,nil), (.NewPasswordCell,nil)]
            minRow = 1
            preferredAnimation = .Fade
        case .isLogged:
            if Profile.user.oauth.isEmpty {
                rows = [(.ProfileCell,nil), (.ChangePasswordCell,nil), (.LogoutCell,nil)]
            }
            else {
                rows = [(.ProfileCell,nil), (.LogoutCell,nil)] // no password with social apis
            }
            //player score
            let params:Dictionary<String,AnyObject> = ["type":"TOTAL SCORE","number":score]
            rows.append((.CountsCell,JSON(params)))
            
            // player discoveries
            if counts != nil {
                if counts!["total"].intValue>0 {
                    let params:Dictionary<String,AnyObject> = ["type":"TOTAL DISCOVERIES","number":counts!["total"].intValue]
                    rows.append((.CountsCell,JSON(params)))
                    
                    for (key,value) in counts!.dictionaryValue {
                        if(value.intValue > 0) && (key != "total") {
                            let params:Dictionary<String,AnyObject> = ["type":key,"number":value.intValue]
                            rows.append((.CountsCell,JSON(params)))
                        }
                    }
                }
            }
        case .isLogging:
            rows = [(.ConnectingCell,nil)]
        case .isLogout:
            rows = [(.SelectLoginTypeCell,nil), (.LoginOptionCell,nil)] //[.SteamCell, .TwitterCell, .RedditCell, .EmailCell ]
        case .isInEmail:
            rows = [(.SelectLoginTypeCell,nil), (.LoginCell,nil)]
            minRow = 0
        case .isInTwitter:
            rows = [(.SelectLoginTypeCell,nil), (.LoginTwitterCell,nil)]
            minRow = 1
        case .isInReddit:
            rows = [(.SelectLoginTypeCell,nil), (.LoginRedditCell,nil)]
            minRow = 1
        case .isInSteam:
            rows = [(.SelectLoginTypeCell,nil), (.LoginSteamcell,nil)]
            minRow = 1
        }
        if(reload) {
            tableView.beginUpdates()
            var indexPaths:[NSIndexPath] = []
            let diff = rows.count - lastCount
            if diff>0 {
                for row in lastCount..<rows.count {
                    indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
                }
                tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
            else if diff<0 {
                for row in rows.count..<lastCount {
                    indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
                }
                tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
            tableView.endUpdates()
            
            indexPaths.removeAll()
            for row in minRow..<rows.count {
                indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
            }
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: preferredAnimation)
        }
    }
    
    // MARK: - DATASOURCE

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let (cellIdentifier,params) = rows[indexPath.row]
        switch cellIdentifier {
        case .ConnectingCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("ConnectingCell", forIndexPath: indexPath) as! ConnectingCell
            return cell
        case .LoginCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginCell", forIndexPath: indexPath) as! LoginCell
            cell.userNameField.text = "" //Profile.user.username
            cell.passwordField.text = ""
            return cell
        case .ProfileCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell
            return cell
        case .SelectLoginTypeCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("SelectLoginTypeCell", forIndexPath: indexPath) as! SelectLoginTypeCell
            cell.fill(self)
            return cell
        case .SteamCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("SteamCell", forIndexPath: indexPath)
            return cell
        case .RedditCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("RedditCell", forIndexPath: indexPath)
            return cell
        case .TwitterCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("TwitterCell", forIndexPath: indexPath)
            return cell
        case .EmailCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("EmailCell", forIndexPath: indexPath)
            return cell
        case .ResetPasswordCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("ResetPasswordCell", forIndexPath: indexPath)
            return cell
        case .LoginOptionCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginSocialAPICell", forIndexPath: indexPath) as! LoginSocialAPICell
            cell.fill(self, api:nil)
            return cell
        case .LoginTwitterCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginSocialAPICell", forIndexPath: indexPath) as! LoginSocialAPICell
            cell.fill(self, api:.Twitter)
            return cell
        case .LoginRedditCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginSocialAPICell", forIndexPath: indexPath) as! LoginSocialAPICell
            cell.fill(self, api:.Reddit)
            return cell
        case .LoginSteamcell:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginSocialAPICell", forIndexPath: indexPath) as! LoginSocialAPICell
            cell.fill(self, api:.Steam)
            return cell
        case .ChangePasswordCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("ChangePasswordCell", forIndexPath: indexPath)
            return cell
        case .NewPasswordCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("NewPasswordCell", forIndexPath: indexPath) as! NewPasswordCell
            cell.fill(self)
            return cell
        case .LogoutCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("LogoutCell", forIndexPath: indexPath)
            return cell
        case .CountsCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("CountsCell", forIndexPath: indexPath) as! CountsCell
            cell.fill(params)
            return cell;
        }
        
    }
    
    //MARK: - DELEGATE
    override func tableView(tableView: UITableView,
                            didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.reuseIdentifier == "EmailCell" {
                userContext = .isInEmail
            }
            
            updateRows(true)
            //cell.setSelected(false, animated: false)
        }
    }
    
    
    // MARK: - Actions

    
    @IBAction func forgotPassword(sender: AnyObject) {
        
        let ac = UIAlertController(title: "Forgot your password", message: "Enter your email to reset your password", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        let resetAction  = UIAlertAction(title: "Reset Password", style: .Destructive) {
            action in
            self.resetPassword(ac.textFields![0].text!)
        }
        resetAction.enabled = false
        ac.addAction(resetAction)
        ac.preferredAction = resetAction
        ac.addTextFieldWithConfigurationHandler() { textField in
            textField.keyboardType = .EmailAddress
            textField.text = ""
            textField.returnKeyType = .Send
            textField.enablesReturnKeyAutomatically = false
            textField.delegate = self
            textField.addTarget(self, action: #selector(ProfileTableViewController.emailDidChange(_:)), forControlEvents: .EditingChanged)
            
        }
        forgotPasswordAlertController = ac
        self.presentViewController(ac, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func changePassword() {
        userContext = .ChangingPassword
        updateRows(true)
    }
    
    
    @IBAction func logout(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        Profile.user.logout()
        userContext = .isLogout
        updateRows(true)
    }
    
    
    @IBAction func tapTableView(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func backToProfileTableViewController(segue:UIStoryboardSegue) {
    }
    
    func authWithAPI(api: SocialAPI) {
        currentAPI = api
        Profile.user.isLogging = true
        self.performSegueWithIdentifier("ProfileWebViewController", sender: self)
    }
    
    
    // MARK: - Notifications
    func keyboardToggle(notification:NSNotification) {
        if(notification.object as! Bool) {
            self.tableView.gestureRecognizers = [tapGestureRecognizer]
        }
        else {
            self.tableView.gestureRecognizers = nil
        }
    }
    
    func tryLogin(notification:NSNotification) {
        var message = ""
        if let parameters  = notification.object  {
            Profile.user.isLogging = true
            updateRows(true)
            self.tabBarController?.tabBar.hidden = true
            Alamofire.request(.POST, URL_LOGIN, parameters:parameters as? Dictionary,encoding: .JSON)
                .responseJSON { response  in
                    self.tabBarController?.tabBar.hidden = false
                    Profile.user.isLogging = false
                    switch (response.result) {
                    case .Success(let json):
                        let r = JSON(json)
                        if let _ = r["_id"].string {
                            Profile.user.id = r["id"].stringValue
                            Profile.user.email = r["email"].stringValue
                            Profile.user.username = r["username"].stringValue
                            Profile.user.admin = (r["admin"].intValue == 1)
                            Profile.user.mod = (r["mod"].intValue == 1)
                            Profile.user.votes = []
                            for (_,vote) in r["votes"] {
                                Profile.user.votes.append(vote.stringValue)
                            }
                            Profile.user.isLogged = true
                            let username = parameters["username"] as! String
                            let password = parameters["password"] as! String
                            Profile.user.storeCredentials(user: username, password: password)
                            NSUserDefaults.standardUserDefaults().setObject(Profile.user.username, forKey: "username")
                            CookiesManager.storeCookies()
                        }
                        else if r["message"] != nil {
                            message = r["message"].stringValue
                            self.alertLoginFailed(message)
                            Profile.user.isLogged = false
                        }

                    case .Failure(let error):
                        print("failed with error",error)
                        self.alertLoginFailed(error.localizedDescription)
                        Profile.user.isLogged = false
                    }
                    
                    self.updateRows(true)

            }
        }
    }
    
    func didLogin(notification:NSNotification) {
        fetchCounts()
        fetchScore()
        self.updateRows(true)
        
        if !Profile.user.termsAndConditionsAccepted {
            self.performSegueWithIdentifier("TermsViewController", sender: self)
        }
    }
    
    func didLogout(notification:NSNotification) {
        self.updateRows(true)
    }
    
    

    // MARK: - Private
    
    private func alertLoginFailed(error: String) {
        let ac = UIAlertController(title: "Login failed", message: error, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    @objc private func emailDidChange(textField:UITextField) {
        if let ac = self.forgotPasswordAlertController {
            if let t = textField.text {
                ac.preferredAction?.enabled = (t.isEmail)
            }
        }
    }
    
     func resetPassword(email:String) {
        let parameters:Dictionary = [
            "email": email
        ]
        
        Alamofire.request(.POST, URL_RESET_PASSWORD, parameters:parameters as Dictionary,encoding: .JSON)
            .responseJSON { response  in
                switch(response.result) {
                case .Success:
                    let ac = UIAlertController(title: "Request sent", message: "Your password has been reset. Please check your email", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)

                case .Failure(let error):
                    let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
        }
    }

    func fetchCounts() {
        //{"query":{"_discoveredBy":"5734a6a0cdd3a1f309baa3d5"}}
        let parameters:Dictionary = [
            "query": [
                "_discoveredBy":Profile.user.id
            ]
        ]
        Alamofire.request(.POST, URL_DISCOVERY_COUNTS, parameters:parameters as Dictionary,encoding: .JSON)
            .responseJSON() {
                response in
                switch(response.result) {
                case .Success(let json):
                    self.counts = JSON(json)
                    self.updateRows(true)
                case .Failure:
                    //TODO check error
                    break
                }
        }

    }
    
    func fetchScore() {
        let parameters:Dictionary = [
          "_id":Profile.user.id
        ]
        Alamofire.request(.POST, URL_USER_SCORE, parameters:parameters as Dictionary,encoding: .JSON)
            .responseJSON() {
                response in
                switch(response.result) {
                case .Success(let json):
                    self.score = JSON(json)["total"].intValue
                    self.updateRows(true)
                case .Failure:
                    //TODO check error
                    break
                }
        }
        
    }
    
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ProfileWebViewController" {
            if let destination = segue.destinationViewController as? ProfileWebViewController {
                destination.api = self.currentAPI!
                
            }
        }
    }


}


extension ProfileTableViewController:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let t = textField.text {
            return t.isEmail
        }
        return false
    }
}