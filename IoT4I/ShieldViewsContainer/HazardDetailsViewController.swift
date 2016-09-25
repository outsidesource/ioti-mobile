//
//  HazardDetailsViewController.swift
//  IoT4I
//
//  Created by Amjad Nashashibi on 10/06/2016.
//
// Data Privacy Disclaimer
//
// This Program has been developed for demonstration purposes only to illustrate the technical capabilities and potential business uses of the IBM IoT for Insurance.
// The components included in this Program may involve the processing of personal information (for example location tracking and behaviour analytics). When implemented in practice such processing may be subject to specific legal and regulatory requirements imposed by country specific data protection and privacy laws.  Any such requirements are not addressed in this Program.
// You are responsible for the ensuring your use of this Program and any deployed solution meets applicable legal and regulatory requirements.  This may require the implementation of additional features and functions not included in the Program.
//
// Apple License issue
//
// This Program is intended solely for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools and further customized and distributed under the terms and conditions of your licensed Apple iOS Developer Program or your licensed Apple iOS Enterprise Program.
// You agree to use the Program  to customise and build the application for your own purpose.
// No use of screen dumps, images of the iOS Map service in their product documentation.  This violates the Apple license.
//
// Risk Mitigation / Product Liability Issues
//
// The Program and any resulting application is not intended for design, construction, control, or maintenance of automotive control systems where failure of such sample code or resulting application could give rise to a material threat of death or serious personal injury.
// IBM shall have no responsibility regarding the Program's or resulting application's compliance with laws and regulations applicable to your business and content. You are responsible for your use of the Program and any resulting application.
// As with any development process, you are responsible for developing, sufficiently testing and remediating your products and applications and you are solely responsible for any foreseen or unforeseen consequences or failures of your product or applications.


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
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!
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
