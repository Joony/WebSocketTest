//
//  RoomViewController.swift
//  WebsocketTest
//
//  Created by Jonathan McAllister on 05/08/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    
    @IBOutlet var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.usernameField.becomeFirstResponder()
    }
    
    @IBAction func join() {
        guard usernameField.text != nil && usernameField.text!.isEmpty == false else {
            return
        }
        self.performSegueWithIdentifier("join", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController {
            if let roomViewController = navigationController.topViewController as? RoomViewController {
                
                let userBuilder = User.Builder()
                userBuilder.username = self.usernameField.text!
                userBuilder.userid = self.randomNumber()
                let user = try! userBuilder.build()
                
                roomViewController.user = user
            }
        }
    }

}

extension UserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.join()
        return true
    }
    
}

// MARK: - Random
extension UserViewController {
    
    func randomNumber(range: Range<Int> = 0..<100) -> Int32 {
        let min = range.startIndex
        let max = range.endIndex
        return Int32(arc4random_uniform(UInt32(max - min))) + min
    }
    
}
