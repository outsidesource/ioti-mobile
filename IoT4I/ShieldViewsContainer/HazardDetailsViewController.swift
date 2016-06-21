//
//  HazardDetailsViewController.swift
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

class HazardDetailsViewController: UIViewController {
    
    @IBOutlet weak var dismissButton:UIBarButtonItem!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lbldesc:UILabel!
    @IBOutlet weak var lblTime:UILabel!
    @IBOutlet weak var imgShield:UIImageView!
    
    var hazard:HazardEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dismissButton.target = self
        dismissButton.action = #selector(HazardDetailsViewController.dismiss)
        
        let attrNavigationTitle: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "SFUIDisplay-Semibold", size: 17.0)!  ?? UIFont(name: "Helvetica Neue", size: 17.0)!
        ]
        
        self.navigationController!.navigationBar.titleTextAttributes = attrNavigationTitle
        
        self.title = hazard.shield?.name ?? ""
        
        self.lblTitle.text = hazard.title
        self.lbldesc.text = hazard.sensLocDesc
        self.lblTime.text = hazard.timestamp?.description
        self.imgShield.image = UIImage(named: hazard.shield?.image ?? "")
    }
    
    func dismiss()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionClicked(btn: UIButton!)
    {
        
        var operation:String
        
        switch (btn.tag)
        {
            case 11:
                operation = "Assistance"
                self.call(hazard.shield?.assistancePhone)
                return
            case 22:
                operation = "Snooze"
                break;
            case 33:
                operation = "Reset"
                break;
            case 44:
                operation = "Insurance"
                self.call(hazard.shield?.assistancePhone)
                return
            default:
                operation = ""
                break;
        }

        let window = self.view.window
        MBProgressHUD.showHUDAddedTo(window,animated:true)
        iService.postHazardAction(self, hazardId: hazard.id!, hazardAction: operation) { (code) in
            MBProgressHUD.hideHUDForView(window,animated:true)
            switch code {
            case .OK(_):
                
                let moc = dataController.writerContext
                moc.performBlock {
                    
                    self.hazard.isHandled = true
                    self.hazard.handledAt = NSDate()
                    self.hazard.handledOperation = operation
                    self.hazard.handledBy = UserPreferences.username
                    
                    do {
                        try moc.save()
                    } catch {
                        DDLogError("Core Data Error \(error)")
                    }
                    
                    self.dismiss()
                }
                
            case let .Error(error):
                let message = error.localizedDescription
                DDLogError(message)
            case .HTTPStatus(let status,_):
                let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                DDLogError(message)
            case .Cancelled:
                DDLogInfo("SignIn Cancelled")
            }
        }
        
    }
    
    func call(phone: String?)
    {
        let url:NSURL = NSURL(string: String(format: "tel://%@", phone ?? ""))!
        UIApplication.sharedApplication().openURL(url)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
