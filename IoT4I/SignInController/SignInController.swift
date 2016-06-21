//
//  SignInController.swift
//  IoT4I
//
//  Created by Amjad Nashashibi on 10/06/2016.
//
//  Copyright (c) IBM Corporation 2016. All rights reserved.
//
//  Material provided under the MIT license; intended solely for use with an
//  Apple iOS product and intended to be used in conjunction with officially
//  licensed Apple development tools and further customized and distributed
//  under the terms and conditions of your licensed Apple developer program.
//
//  The MIT License (MIT)
//
//  Copyright (c) IBM Corporation 2016. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit
import MBProgressHUD
import LocalAuthentication
import CocoaLumberjack
import UICKeyChainStore

class SignInController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginView:UIView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    internal var loginViewOriginY:CGFloat = 0
    internal var loginViewOriginX:CGFloat = 0
    private var isUserAlreadySignedIn:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let paddingUserView = UIView(frame:CGRectMake(0, 0, 7, 7))
        username.leftView=paddingUserView;
        username.leftViewMode = UITextFieldViewMode.Always
        let paddingPasswordView = UIView(frame:CGRectMake(0, 0, 7, 7))
        password.leftView=paddingPasswordView;
        password.leftViewMode = UITextFieldViewMode.Always
        
        loginViewOriginY = loginView.frame.origin.y
        loginViewOriginX = loginView.frame.origin.x
        
        self.username.delegate = self
        self.password.delegate = self
        
        self.username.minimumFontSize = self.username.font!.pointSize
        self.password.minimumFontSize = self.password.font!.pointSize
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        self.isUserAlreadySignedIn = Utils.isCredentialsPresent

        if (self.isUserAlreadySignedIn.boolValue)
        {
            do {
                (self.username.text, self.password.text) = try Utils.getCredintials()
            } catch {
                DDLogError("KeyChain Error \(error)")
                return
            }
        
            self.doSignIn()
        }
        
    }

    func keyboardWillShow(notification: NSNotification) {
        
        self.loginView.translatesAutoresizingMaskIntoConstraints = true;
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            let height = WINDOW_HEIGHT - keyboardSize.height - loginViewOriginY - loginView.frame.size.height
            
            if (height < 10)
            {
                self.loginView.frame.origin.y = loginViewOriginY - height - 10
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.loginView.frame.origin.y = loginViewOriginY
        self.loginView.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logIn()
    {
        self.doSignIn()
    }
    
    func doSignIn() {
        
        guard let user = self.username.text,password = self.password.text else {
            return
        }
        
        let window = self.view.window
        MBProgressHUD.showHUDAddedTo(window,animated:true)
        
        iService.signIn(self, username: user, password: password) { (code) -> Void in
            MBProgressHUD.hideHUDForView(window,animated:true)
            
            switch code {
            case let .OK(data):
                guard let json = data!.responseJson else {
                    let message = NSLocalizedString("SignIn.Alert.NoJSON", comment: "")
                    DDLogError(message)
                    self.showError(message)
                    break
                }
                do {
                    
                    let keychain = UICKeyChainStore(service:keyChainDomain)
                    do {
                        try keychain.setData(try! NSJSONSerialization.dataWithJSONObject(json, options: []), forKey: user,error:())
                    } catch {
                        DDLogError("KeyChain Error \(error)")
                    }

                    AppDelegate.gotoInitialController()

                }
                
            case let .Error(error):
                let message = error.localizedDescription
                DDLogError(message)
                self.showError(message)
            case .HTTPStatus(let status,_):
                let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                DDLogError(message)
                self.showError(message)
            case .Cancelled:
                DDLogInfo("SignIn Cancelled")
            }

            
        }
        
    }
    
    private func showError(message:String){
        
        let alert = UIAlertController(title: NSLocalizedString("SignIn.Alert.Title",comment:"Sign In Error"), message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button"), style: .Default, handler: { (alertAction) -> Void in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    // MARK: UITextFieldDelegate methods
    func textFieldDidBeginEditing(textField:UITextField) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInController.textFieldDidChange(_:)), name: UITextFieldTextDidChangeNotification, object: textField)
    }
    
    func textFieldDidEndEditing(textField:UITextField) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: textField)
    }
    
    func textFieldDidChange(notification:NSNotification) {
        if self.username.text?.isEmpty == true {
        } else if self.password.text?.isEmpty == true {
        } else {
        }
        
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool{
        
        if textField == self.username {
            self.password.becomeFirstResponder()
        } else if textField.text?.isEmpty == false {
            self.doSignIn()
        }
        
        return false
    }

}
