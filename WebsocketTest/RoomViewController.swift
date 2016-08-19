//
//  ViewController.swift
//  WebsocketTest
//
//  Created by Jonathan McAllister on 05/08/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import UIKit
import Starscream
import AVFoundation

class RoomViewController: UIViewController {

    let socket = SocketAdapter()
    @IBOutlet var textInput: UITextField!
    @IBOutlet var inputContainer: UIView!
    @IBOutlet var inputContainerBottomConstraint: NSLayoutConstraint!
    let synthesizer = AVSpeechSynthesizer()
    
    @IBOutlet var collectionView: UICollectionView!
    
    var user: User!
    var messages = [Message_]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        (self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = CGSize(width: self.collectionView.bounds.width, height: 1)
        
        self.synthesizer.pauseSpeakingAtBoundary(.Word)
        
        self.textInput.becomeFirstResponder()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.socket.messages.subscribe { result in
            let messages = result.successValue!
            self.messages += messages
            self.update()
        }
        
        self.socket.message.subscribe { result in
            let message = result.successValue!
            self.messages.append(message)
            self.update()
        }
        
        self.socket.connect()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        super.viewDidDisappear(animated)
    }
    
    func update() {
        self.collectionView.reloadData()
        self.view.layoutIfNeeded()
        let y = max(0, self.collectionView.contentSize.height - self.collectionView.bounds.height)
        self.collectionView.contentOffset = CGPoint(x: 0, y: y)
    }
    
    @IBAction func sendMessage() {
        let text = self.textInput.text!
        let emojified = text.emojified()
        self.socket.send(message: emojified, userId: self.user!.userid)
        self.textInput.text = nil
        self.textInput.becomeFirstResponder()
    }
    
    @IBAction func leave() {
        self.socket.disconnect()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension RoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.isEmpty == false {
            self.sendMessage()
        }
        return true
    }
    
}

// MARK: - Keyboard
extension RoomViewController {
    
    func keyboardWasShown(notification: NSNotification) {
        let info: Dictionary = notification.userInfo!
        let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        self.inputContainerBottomConstraint.constant = keyboardFrame.height
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animateWithDuration(duration, delay: 0.0, options: [.CurveEaseOut] , animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.inputContainerBottomConstraint.constant = 0
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animateWithDuration(duration, delay: 0.0, options: [.CurveEaseOut] , animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension RoomViewController {
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.pitchMultiplier = 2.0
        self.synthesizer.speakUtterance(utterance)
    }
    
}

extension RoomViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let message = self.messages[indexPath.row]
        let identifier = self.cellIdentifierForMessage(message)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! SpeechCell
//        cell.usernameLabel.text = message.user.username
        cell.messageLabel.text = message.message_
        cell.widthConstraint.constant = collectionView.bounds.width
        return cell
    }
    
    func cellIdentifierForMessage(message: Message_) -> String {
//        if message.user == self.user {
//            return "self"
//        } else if message.user.username == "📎" {
//            return "server"
//        } else {
//            return "other"
//        }
        return "server"
    }
    
}
