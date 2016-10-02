//
//  TermsViewController.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 24/07/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var termsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let text = NSMutableAttributedString(string: "By clicking “I agree”, you agree with the ")
            text.appendAttributedString(NSAttributedString(string: "Terms and Conditions", attributes: [NSLinkAttributeName: NSURL(string: URL_TERMS)!]))
                text.appendAttributedString(NSAttributedString(string: " of NMSOrigins."))
        self.termsLabel.attributedText = text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:URL_TERMS)!)

    }
    @IBAction func agree(sender: UIButton) {
        Profile.user.acceptTerms(self) {
            response, statusCode  in
            if(statusCode == 200) {
                self.performSegueWithIdentifier("agree", sender: self)
            }
        }
    }
    
    
    @IBAction func disagree(sender: AnyObject) {
        Profile.user.logout()
        self.performSegueWithIdentifier("disagree", sender: self)
    }
}