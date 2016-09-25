//
//  MenuSideBarController.swift
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
import CocoaLumberjack
import UICKeyChainStore

public enum SideMenu {
    
    case Overview
    case Policy
    case Empty
    case Shields
    case Devices
    case Domains
    case WinkAccount
    case Logout
    
}

extension SideMenu {
    
    init(rawValue: Int) {
        switch rawValue {
            
        case 0: self = .Overview
        case 1: self = . Policy
        case 2: self = . Empty
        case 3: self = . Shields
        case 4: self = . Devices
        case 5: self = . Domains
        case 6: self = . WinkAccount
        case 7: self = . Logout
        default: self = .Shields
        }
    }
    
    static var count: Int { return SideMenu.Logout.hashValue + 1}
    
    var description : String {
        switch self {
            case .Overview: return "Overview"
            case .Policy: return "Policy"
            case .Empty: return ""
            case .Shields: return "Shields"
            case .Devices: return "Devices"
            case .Domains: return "Domains"
            case .WinkAccount: return "Account"
            case .Logout: return "Logout"
        }
    }
    
}

class MenuSideBarController: UITableViewController {

    var sideMenuHeader:SideMenuHeader!
    
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.blackColor()
        
        gradientLayer.frame = self.view.bounds
        
        let color = UIColor(red: (49.0/255.0), green: (65.0/255.0), blue: (85.0/255.0), alpha: 1.0)
        self.tableView.backgroundColor = color
        self.tableView.scrollEnabled = false
        
        let views = NSBundle.mainBundle().loadNibNamed("SideMenuHeader",owner:self,options:nil) as! [UIView]
        sideMenuHeader = views[0] as! SideMenuHeader
        self.tableView.tableHeaderView = sideMenuHeader
        
        let keychain = UICKeyChainStore(service:keyChainDomain)
        guard let data = try? keychain.dataForKey(UserPreferences.username!, error: ()) else {
            debugPrint("IoT foundation credential missing in the Key Chain")
            return
        }
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data,options:[]) as! [String:AnyObject] else {
            debugPrint("Wrong IoT foundation json data in the Key Chain")
            return
        }
        
        do {
            let userJson = json["imf.user"] as! [String:AnyObject]
            sideMenuHeader.lblInfo.text = String(format: "%@ | %@", userJson["displayName"] as? String ?? "", "Policy 123456")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SideMenu.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuReuseIdentifier", forIndexPath: indexPath)

        cell.textLabel?.text = SideMenu(rawValue: indexPath.row).description
        cell.textLabel?.textColor = UIColor.whiteColor()

        switch  SideMenu(rawValue: indexPath.row) {
        case .Overview,.Policy:
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)!
            break
        default:
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)!
            break
        }
        
        
        return cell
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch  SideMenu(rawValue: indexPath.row) {
        case .Shields:
            self.performSegueWithIdentifier("ShieldsSegue", sender: indexPath)
        case .WinkAccount:
            self.performSegueWithIdentifier("WinkSegue", sender: indexPath)
        case .Devices:
            self.performSegueWithIdentifier("DevicesSegue", sender: indexPath)
        case .Logout:
            
            let window = self.view.window

            MBProgressHUD.showHUDAddedTo(window,animated:true)
            iService.signOut({ (code) in
                
                MBProgressHUD.hideHUDForView(window,animated:true)
             
                switch code {
                case .Cancelled:
                    DDLogInfo("Cancelled")
                case let .Error(error):
                    DDLogError(error.localizedDescription)
                case let .HTTPStatus(status,_):
                    let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                    DDLogError(message)
                // Json object
                case .OK(_):
                    DDLogInfo("LOGOUT OK")
                    IMFAuthorizationManager.sharedInstance().logout({ (response, error) in
                        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                        let window = UIApplication.sharedApplication().keyWindow
                        let sb = UIStoryboard(name:"SignInController",bundle:nil)
                        let vc = sb.instantiateInitialViewController()
                        window!.rootViewController = vc
                        })
                    }
                })
        default:
            break
        }

    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    

}
