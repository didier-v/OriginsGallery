//
//  ProfileCell.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 16/05/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var apiButton: UIBarButtonItem!
    @IBOutlet weak var userNameButton: UIBarButtonItem!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        userNameButton.title = Profile.user.username
        if let oauth = SocialAPI(rawValue:Profile.user.oauth.lowercaseString) {
            switch oauth {
            case .Twitter:
                apiButton.image = UIImage(named: "Twitter")
            case .Reddit:
                apiButton.image = UIImage(named: "Reddit")
            case .Steam:
                apiButton.image = UIImage(named: "Steam")
            default:
                apiButton.image = UIImage(named: "email")
            }
        }
        
    }

}
