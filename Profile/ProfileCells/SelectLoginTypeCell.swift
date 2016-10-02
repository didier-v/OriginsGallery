//
//  SelectLoginTypeCell.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 23/07/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit

class SelectLoginTypeCell: UITableViewCell {
    var tableViewController:ProfileTableViewController?

    @IBOutlet weak var toolbar: UIToolbar!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        for (_,button) in (toolbar.items?.enumerate())! {
            button.tintColor = MainTintColor
        }
    }
    
    func fill(tableViewController:ProfileTableViewController) {
        self.tableViewController = tableViewController
    }

    @IBAction func selectTypeTwitter(sender: UIBarButtonItem) {
        tableViewController!.userContext = .isInTwitter
        update(sender)
    }
    
    @IBAction func selectTypeReddit(sender: UIBarButtonItem) {
        tableViewController!.userContext = .isInReddit
        update(sender)
    }
    
    @IBAction func selectTypeSteam(sender: UIBarButtonItem) {
        tableViewController!.userContext = .isInSteam
        update(sender)
    }
    
    @IBAction func selectTypeEmail(sender: UIBarButtonItem) {
        tableViewController!.userContext = .isInEmail
        update(sender)
    }
    
    func update(sender: UIBarButtonItem) {
        for (_,button) in (toolbar.items?.enumerate())! {
            button.tintColor = MainTintColor
        }
        sender.tintColor = UIColor.whiteColor()
        tableViewController!.updateRows(true)
  
    }

}
