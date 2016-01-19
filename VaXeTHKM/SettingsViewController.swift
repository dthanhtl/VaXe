//
//  SettingsViewController.swift
//  VaXeTHKM
//
//  Created by Thanh Tran on 11/18/15.
//  Copyright © 2015 vaxe. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Parse
import ParseFacebookUtilsV4
import Alamofire
import MessageUI

class SettingsViewController: UIViewController, UITextFieldDelegate,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var btnFacebook: UIButton!
    var isKBUp: Bool = false
    var tap = UITapGestureRecognizer()
    
    
    var loginStatus: Bool = false
    let facebookReadPermissions = ["public_profile", "email", "user_friends","user_location"]
    
    
    
    override func awakeFromNib() {
        self.view.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.view.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.view.layer.shadowOpacity = 0.5
        self.view.layer.shadowRadius = 1
        self.view.clipsToBounds = true
        self.view.layer.masksToBounds = true
        
        self.btnFacebook.layer.cornerRadius = 4.0
        self.btnFacebook.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.btnFacebook.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.btnFacebook.layer.shadowOpacity = 0.5
        self.btnFacebook.layer.shadowRadius = 1
        self.btnFacebook.clipsToBounds = true
        self.btnFacebook.layer.masksToBounds = true

    }
    override func viewDidLoad() {

        self.containerView.layer.cornerRadius = 4.0
        self.containerView.clipsToBounds = true
        self.containerView.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        

        
        if((PFUser.currentUser()  != nil)){
            self.loginStatus = true
        }else{
            self.loginStatus = false
        }
        
        self.resetUI()
    }

    func resetUI(){
    
        if(self.loginStatus){
            self.btnFacebook.setTitle("Đăng xuất khỏi Facebook", forState: .Normal)
        
        }else{
            self.btnFacebook.setTitle("Đăng nhập với Facebook", forState: .Normal)
        }
    }

    @IBAction func dismissTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(false) { () -> Void in
            
        }
    }
    
    @IBAction func facebookLoginTapped(sender: AnyObject) {
        
        if(!self.loginStatus){
            PFFacebookUtils.logInInBackgroundWithReadPermissions(self.facebookReadPermissions) {
                (user: PFUser?, error: NSError?) -> Void in
                if let user = user {
                    if user.isNew {
                        
                    } else {
                    
                    }
                    
                    self.loginStatus = true
                } else {
                    self.loginStatus = false
                }
                
                self.resetUI()
            }
        }else{
            PFUser.logOutInBackgroundWithBlock({ (er: NSError?) -> Void in
                self.loginStatus = false
                
                self.resetUI()
                
            })
            
        }
    
        
    }
    
    @IBAction func gopYTapped(sender: AnyObject) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["hi@pizzathieves.com"])
        mailComposerVC.setSubject("VaXe App Feedback")
        mailComposerVC.setMessageBody("Ý Kiến:", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func gioiThieuTapped(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://pizzathieves.com/vaxe")!)
    }
}
