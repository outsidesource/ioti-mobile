//
//  MenuSideBarController.swift
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
