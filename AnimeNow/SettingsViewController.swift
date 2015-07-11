//
//  SettingsViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/28/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import iRate
import ANParseKit
import ANCommonKit
import FBSDKShareKit

class SettingsViewController: UITableViewController {
    
    let FacebookPageDeepLink = "fb://profile/713541968752502";
    let FacebookPageURL = "http://www.facebook.com/AozoraApp";
    let TwitterPageDeepLink = "twitter://user?id=3366576341";
    let TwitterPageURL = "http://www.twitter.com/AozoraApp";
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var facebookLikeButton: FBSDKLikeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLikeButton.objectID = "https://www.facebook.com/AozoraApp"
        
        updateLoginButton()
    }
    
    func updateLoginButton() {
        if PFUser.currentUserLoggedIn() {
            // Logged In both
            loginLabel.text = "Logout Aozora"
        } else if PFUser.currentUserIsGuest() {
            // User is guest
            loginLabel.text = "Login Aozora"
        }

    }
    
    // MARK: - IBActions
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - TableView functions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            // Login / Logout
            if PFUser.currentUserLoggedIn() {
                // Logged In both, logout
                WorkflowController.logoutUser().continueWithExecutor( BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
                    
                    if let error = task.error {
                        println("failed loggin out: \(error)")
                    } else {
                        println("logout succeeded")
                    }
                    WorkflowController.presentOnboardingController(true)
                    return nil
                })
                
                
            } else if PFUser.currentUserIsGuest() {
                // User is guest, login
                WorkflowController.presentOnboardingController(true)
            }

        case (1,0):
            // Unlock features
            let controller = UIStoryboard(name: "InApp", bundle: nil).instantiateViewControllerWithIdentifier("InApp") as! InAppPurchaseViewController
            navigationController?.pushViewController(controller, animated: true)
        case (1,1):
            // Restore purchases
            InAppTransactionController.restorePurchases().continueWithBlock({ (task: BFTask!) -> AnyObject! in
                
                if let _ = task.result {
                    var alert = UIAlertController(title: "Restored!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                return nil
            })
        case (2,0):
            // Rate app
            iRate.sharedInstance().openRatingsPageInAppStore()
        case (2,1):
            // Recommend to friends
            DialogController.sharedInstance.showFBAppInvite()
        case (3,0):
            // Open Facebook
            var url: NSURL?
            if let twitterScheme = NSURL(string: "fb://requests") where UIApplication.sharedApplication().canOpenURL(twitterScheme) {
                url = NSURL(string: FacebookPageDeepLink)
            } else {
                url = NSURL(string: FacebookPageURL)
            }
            UIApplication.sharedApplication().openURL(url!)
        case (3,1):
            // Open Twitter
            var url: NSURL?
            if let twitterScheme = NSURL(string: "twitter://") where UIApplication.sharedApplication().canOpenURL(twitterScheme) {
                url = NSURL(string: TwitterPageDeepLink)
            } else {
                url = NSURL(string: TwitterPageURL)
            }
            UIApplication.sharedApplication().openURL(url!)
        default:
            break
        }
        
        
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return nil
        case 1:
            return "Going pro unlocks lots of awesome features and help us keep improving the app"
        case 2:
            return "If you're looking for support drop us a message on Facebook or Twitter"
        case 3:
            return "Created from Anime fans for Anime fans, enjoy!\nAozora 1.0.0"
        default:
            return nil
        }
    }
}