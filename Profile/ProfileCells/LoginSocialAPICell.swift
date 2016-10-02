//
//  LoginSocialAPICell.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 21/07/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit
import Alamofire

class LoginSocialAPICell: UITableViewCell {
    var tableViewController:ProfileTableViewController?
    var api:SocialAPI?
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fill(tableViewController:ProfileTableViewController, api:SocialAPI?) {
        self.tableViewController = tableViewController
        self.api = api
        if api != nil {
            self.loginButton.setTitle("LOG IN USING "+api!.rawValue.uppercaseString, forState: .Normal)
        }
        else {
            self.loginButton.setTitle("LOGIN OPTIONS", forState: .Normal)
        }
    }

    
    @IBAction func loginTwitter(sender: AnyObject) {
        if api !=  nil {
            tableViewController!.authWithAPI(api!)
        }
    }

}
