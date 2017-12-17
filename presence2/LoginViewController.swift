//
//  LoginViewController.swift
//  presence2
//
//  Created by Matt Li on 11/25/16.
//  Copyright © 2016 Matt Li. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {


    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.blackColor().CGColor
        GIDSignIn.sharedInstance().clientID = "810981757625-rfdntbjih4ivf1l8ltird49b3kdblvv9.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(FIRAuth.auth()?.currentUser)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) -> Void in
            if user != nil {
                print(user)
                Helper.helper.switchToNavigationViewController()
            } else {
                print("Unauthorized")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginAnonymouslyDidTapped(sender: AnyObject) {
        print("login anonymously did tapped")
        Helper.helper.loginAnonymously()

    }

    @IBAction func googleLoginDidTapped(sender: AnyObject) {
        print("google login did tapped")
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        print(user.authentication)
        Helper.helper.loginWithGoogle(user.authentication)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
