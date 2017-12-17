//
//  ChatViewController.swift
//  presence2
//
//  Created by Matt Li on 11/25/16.
//  Copyright © 2016 Matt Li. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    var messageRef = FIRDatabase.database().reference().child("messages")

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            self.senderId = currentUser.uid
            if currentUser.anonymous == true {
                self.senderDisplayName = "anonymous"
            }
            else {
                self.senderDisplayName = "\(currentUser.displayName!)"
            }
        }
//        messageRef.childByAutoId().setValue("first message")
//        messageRef.childByAutoId().setValue("second message")
//        messageRef.observeEventType(FIRDataEventType.Value) { (snapshot: FIRDataSnapshot) in
//            print(snapshot.value)
//            if let dict = snapshot.value as? NSDictionary {
//                print(dict)
//            }
//        }
        observeMessages()
    }

    func observeUsers(id: String) {
        FIRDatabase.database().reference().child("users").child(id).observeEventType(.Value, withBlock: {
            snapshot in
            if let dict = snapshot.value as? [String:AnyObject] {
                let avatarUrl = dict["profileUrl"] as! String
                self.setupAvatar(avatarUrl, messageId: id)
            }
        })
    }
    
    func setupAvatar(url: String, messageId: String) {
        if url != ""
        {
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOfURL: fileUrl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
            avatarDict[messageId] = userImg
            
        } else {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage"), diameter: 30)
        }
        collectionView?.reloadData()
    }
    
    
    func observeMessages() {
        messageRef.observeEventType(.ChildAdded, withBlock: { snapshot in
//            print(snapshot.value)
            if let dict = snapshot.value as? [String: AnyObject] {
//              let MediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                self.observeUsers(senderId)
                
                let startTime = CFAbsoluteTimeGetCurrent()
                
                let text = dict["text"] as! String
                self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                
                print("TEXT: \(CFAbsoluteTimeGetCurrent() - startTime)")
                
                self.collectionView?.reloadData()
            }

        })
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//      messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//      collectionView?.reloadData()
//      print(messages)
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT" ]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("did press accessory button")
        let imagePicker = UIImagePickerController()
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        if message.senderId == self.senderId {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(.blackColor())
        } else {
            return bubbleFactory.incomingMessagesBubbleImageWithColor(.lightGrayColor())
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        return avatarDict[message.senderId]
//      return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage"), diameter: 30)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of items is: \(messages.count)")
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutDidTapped(sender: AnyObject) {
        
        do {
            try FIRAuth.auth()?.signOut()
            
        } catch let error {
            print(error)
        }
        
        print(FIRAuth.auth()?.currentUser)
        
        // Create main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // From main storyboard instantiate the login view controller
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        
        // Get the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Set the login view controller as root view controller
        appDelegate.window?.rootViewController = loginVC
        
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


extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("did finish picking")
        //get the image
        //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        //collectionView?.reloadData()
    }
}
