//
//  Helper.swift
//  presence2
//
//  Created by Matt Li on 11/25/16.
//  Copyright © 2016 Matt Li. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn
import FirebaseDatabase

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        print("login anonymously did tapped")
        // anonymously log user in
        // Switch view by setting navigation controller as root view controller
        
        FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (anonymousUser: FIRUser?, error: NSError?) in
            if error == nil {
                print("UserID: \(anonymousUser!.uid)")

                let newUser = FIRDatabase.database().reference().child("users").child(anonymousUser!.uid)
                newUser.setValue(["displayname":"anonymous", "id":"\(anonymousUser!.uid)", "profileUrl":""])

                self.switchToNavigationViewController()
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    
    func loginWithGoogle(authentication: GIDAuthentication) {
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user: FIRUser?, error: NSError?) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                print(user?.email)
                print(user?.displayName)
                print(user?.photoURL)
                
                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
                newUser.setValue(["displayname":"\(user!.displayName!)", "id":"\(user!.uid)", "profileUrl":"\(user!.photoURL!)"])
                
                self.switchToNavigationViewController()
            }
        })
        
    }
    
    func switchToNavigationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
    }

}