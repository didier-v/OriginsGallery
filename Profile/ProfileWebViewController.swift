//
//  ProfileWebViewController.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 23/07/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit

class ProfileWebViewController: UIViewController, UIWebViewDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var api: SocialAPI!
    var isDismissed:Bool = false
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        webView.delegate = self
        titleButton.title = "Login with "+api.rawValue.capitalizedString
    }

    override func viewWillAppear(animated: Bool) {
        guard let URL = NSURL(string: URL_AUTH_BASE+api.rawValue) else {
            fatalError("missing social api")
        }
        webView.loadRequest(NSURLRequest(URL: URL))
    }
    @IBAction func cancel(sender: UIBarButtonItem) {
        isDismissed = true
        Profile.user.isLogging = false
        self.dismissViewControllerAnimated(true,completion: nil)
    }
    
    //MARK: DELEGATE
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        /*
        "good" links
         https://dev.nmsorigins.com/auth/twitter
         https://api.twitter.com/oauth/authenticate?oauth_token=bxTlhwAAAAAAu6r4AAABVh2J_aY
         https://api.twitter.com/oauth/authenticate
         https://dev.nmsorigins.com/auth/twitter/return?denied=bxTlhwAAAAAAu6r4AAABVh2J_aY : intercept and go back to login page
         https://dev.nmsorigins.com/auth/twitter/return?oauth_token OK

         https://dev.nmsorigins.com/auth/reddit
         https://ssl.reddit.com/api/v1/authorize?duration=permanent&response_type=code&redirect_uri=https%3A%2F%2Fdev.nmsorigins.com%2Fauth%2Freddit%2Freturn&scope=identity&state=5fc838232d7812673c7e5ac14ac2e1f8863f15c403ae1fc855d88163fde38315&client_id=tqqxk8FL7fBtYQ
         https://www.reddit.com/login?dest=https%3A%2F%2Fssl.reddit.com%2Fapi%2Fv1%2Fauthorize%3Fduration%3Dpermanent%26response_type%3Dcode%26redirect_uri%3Dhttps%253A%252F%252Fdev.nmsorigins.com%252Fauth%252Freddit%252Freturn%26scope%3Didentity%26state%3D5fc838232d7812673c7e5ac14ac2e1f8863f15c403ae1fc855d88163fde38315%26client_id%3Dtqqxk8FL7fBtYQ
         https://www.redditmedia.com/gtm/jail?cb=8CqR7FcToPI
         https://www.redditmedia.com/gtm?id=GTM-NDJTNB&cb=8CqR7FcToPI
         https://ssl.reddit.com/api/v1/authorize?duration=permanent&response_type=code&redirect_uri=https%3A%2F%2Fdev.nmsorigins.com%2Fauth%2Freddit%2Freturn&scope=identity&state=5fc838232d7812673c7e5ac14ac2e1f8863f15c403ae1fc855d88163fde38315&client_id=tqqxk8FL7fBtYQ
         https://www.redditmedia.com/gtm/jail?cb=8CqR7FcToPI
         https://www.redditmedia.com/gtm?id=GTM-NDJTNB&cb=8CqR7FcToPI
         https://ssl.reddit.com/api/v1/authorize
         https://dev.nmsorigins.com/auth/reddit/return?state=5fc838232d7812673c7e5ac14ac2e1f8863f15c403ae1fc855d88163fde38315&code=aGu1jqPQ9swzk8Pkryh7Jjnd7TE
         https://dev.nmsorigins.com/auth/reddit/return?state=8f245938ea05f06efb864892219ca54612c12784a2cc9b6726c3482fc375982a&error=access_denied

         
         https://steamcommunity.com/openid/login?openid.mode=checkid_setup
         https://store.steampowered.com/login/transfer
         https://help.steampowered.com/login/transfer
         https://steamcommunity.com/openid/login
         */
        // TWITTER
        if request.URLString == URL_AUTH_BASE+"twitter" {
            return true
        }
        if request.URLString.hasPrefix("https://api.twitter.com/oauth/authenticate") {
            return true
        }
        if request.URLString.containsString("nmsorigins.com/auth/twitter/return?oauth_token") {
            return true
        }
        if request.URLString.containsString("auth/twitter/return?denied") {
            isDismissed  = true
            self.dismissViewControllerAnimated(true,completion: nil)
            return false
        }
        // REDDIT
        if request.URLString == URL_AUTH_BASE+"reddit" {
            return true
        }
        if request.URLString.hasPrefix("https://ssl.reddit.com/api/v1/authorize") {
            return true
        }
        if request.URLString.hasPrefix("https://www.reddit.com/login") {
            return true
        }
        if request.URLString.hasPrefix("https://www.redditmedia.com/gtm") {
            return true
        }
        if request.URLString.containsString("auth/reddit/return?") {
            if  request.URLString.containsString("access_denied") {
                isDismissed = true
                self.dismissViewControllerAnimated(true,completion: nil)
                return false
            }
            else {
                return true
            }
        }
        
        //STEAM
        if request.URLString == URL_AUTH_BASE+"steam" {
            return true
        }
        if request.URLString.hasPrefix("https://steamcommunity.com/openid") {
            return true
        }
        if request.URLString.hasPrefix("https://store.steampowered.com/login/transfer") {
            return true
        }
        if request.URLString.hasPrefix("https://steamcommunity.com/openid/login") {
            return true
        }
        if request.URLString.containsString("auth/steam/return?") {
       //     self.dismissViewControllerAnimated(true,completion: nil)
            return true
        }

        if request.URLString == URL_BASE {
            CookiesManager.storeCookies()
            isDismissed = true
            self.dismissViewControllerAnimated(true) {
                Profile.user.getCurrent()
            }
            return false
        }
        
        if request.URLString == URL_DISCOVERY_FIND {
            return false
        }
        
        return false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
        let js:String =
            "var meta = document.createElement('meta'); " +
        "meta.setAttribute( 'name', 'viewport' ); " +
        "meta.setAttribute( 'content', 'width = device-width, initial-scale=1.0, minimum-scale=0.2, maximum-scale=5.0; user-scalable=1;' ); " +
        "document.getElementsByTagName('head')[0].appendChild(meta)";
        
        webView.stringByEvaluatingJavaScriptFromString(js)

    }
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if !isDismissed {
            activityIndicator.stopAnimating()
            let alert:UIAlertController = UIAlertController(title: "Network error", message: error?.localizedDescription, preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            }))
            self.presentViewController(alert, animated:true) {
                self.dismissViewControllerAnimated(true,completion: nil)
            }
        }
    }
}
