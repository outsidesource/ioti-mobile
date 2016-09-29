//
//  SignInController.swift
//  IoT4I
//
//  Created by Amjad Nashashibi on 10/06/2016.
//
//  Data Privacy Disclaimer
//
//  This Program has been developed for demonstration purposes only to illustrate the technical capabilities and potential business uses of the IBM IoT for Insurance
//  The components included in this Program may involve the processing of personal information (for example location tracking and behavior analytics). When implemented in practice such processing may be subject to specific legal and regulatory requirements imposed by country specific data protection and privacy laws.  Any such requirements are not addressed in this Program.
//  Licensee is responsible for the ensuring Licenseeís use of this Program and any deployed solution meets applicable legal and regulatory requirements.  This may require the implementation of additional features and functions not included in the Program.
//
//  Apple License issue
//
//  This Program is intended solely for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools and further customized and distributed under the terms and conditions of Licenseeís licensed Apple iOS Developer Program or Licenseeís licensed Apple iOS Enterprise Program.
//  Licensee agrees to use the Program to customize and build the application for Licenseeís own purpose and distribute in accordance with the terms of Licenseeís Apple developer program
//  Risk Mitigation / Product Liability Issues
//  The Program and any resulting application is not intended for design, construction, control, or maintenance of automotive control systems where failure of such sample code or resulting application could give rise to a material threat of death or serious personal injury.  The Program is not intended for use where bodily injury, tangible property damage, or environmental contamination might occur as a result of a failure of or problem with such Program.
//  IBM shall have no responsibility regarding the Program's or resulting application's compliance with laws and regulations applicable to Licenseeís business and content. Licensee is responsible for use of the Program and any resulting application.
//  As with any development process, Licensee is responsible for developing, sufficiently testing and remediating Licenseeís products and applications and Licensee is solely responsible for any foreseen or unforeseen consequences or failures of Licenseeís products or applications.
//
//  REDISTRIBUTABLES
//
//  If the Program includes components that are Redistributable, they will be identified in the REDIST file that accompanies the Program. In addition to the license rights granted in the Agreement, Licensee may distribute the Redistributables subject to the following terms:
//  1) Redistribution must be in source code form only and must conform to all directions, instruction and specifications in the Program's accompanying REDIST or documentation;
//  2) If the Program's accompanying documentation expressly allows Licensee to modify the Redistributables, such modification must conform to all directions, instruction and specifications in that documentation and these modifications, if any, must be treated as Redistributables;
//  3) Redistributables may be distributed only as part of Licensee's application that was developed using the Program ("Licensee's Application") and only to support Licensee's customers in connection with their use of Licensee's Application. Licensee's application must constitute significant value add such that the Redistributables are not a substantial motivation for the acquisition by end users of Licensee's software product;
//  4) If the Redistributables include a Java Runtime Environment, Licensee must also include other non-Java Redistributables with Licensee's Application, unless the Application is designed to run only on general computer devices (e.g., laptops, desktops and servers) and not on handheld or other pervasive devices (i.e., devices that contain a microprocessor but do not have computing as their primary purpose);
//  5) Licensee may not remove any copyright or notice files contained in the Redistributables;
//  6) Licensee must hold IBM, its suppliers or distributors harmless from and against any claim arising out of the use or distribution of Licensee's Application;
//  7) Licensee may not use the same path name as the original Redistributable files/modules;
//  8) Licensee may not use IBM's, its suppliers or distributors names or trademarks in connection with the marketing of Licensee's Application without IBM's or that supplier's or distributor's prior written consent;
//  9) IBM, its suppliers and distributors provide the Redistributables and related documentation without obligation of support and "AS IS", WITH NO WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING THE WARRANTY OF TITLE, NON-INFRINGEMENT OR NON-INTERFERENCE AND THE IMPLIED WARRANTIES AND CONDITIONS OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.;
//  10) Licensee is responsible for all technical assistance for Licensee's Application and any modifications to the Redistributables; and
//  11) Licensee's license agreement with the end user of Licensee's Application must notify the end user that the Redistributables or their modifications may not be i) used for any purpose other than to enable Licensee's Application, ii) copied (except for backup purposes), iii) further distributed or transferred without Licensee's Application or iv) reverse assembled, reverse compiled, or otherwise translated except as specifically permitted by law and without the possibility of a contractual waiver. Furthermore, Licensee's license agreement must be at least as protective of IBM as the terms of this Agreement.
//
//  Feedback License
//
//  In the event Licensee provides feedback to IBM regarding the Program, Licensee agrees to assign to IBM all right, title, and interest (including ownership of copyright) in any data, suggestions, or written materials that 1) are related to the Program and 2) that Licensee provides to IBM.


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
        MBProgressHUD.showHUDAddedTo(window!,animated:true)
        
        iService.signIn(self, username: user, password: password) { (code) -> Void in
            MBProgressHUD.hideHUDForView(window!,animated:true)
            
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
