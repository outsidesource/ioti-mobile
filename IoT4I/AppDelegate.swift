//
//  AppDelegate.swift
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
import CoreData
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var pushHazardEvent:HazardEvent?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().barTintColor = Insurance_barTintColor
        UITabBar.appearance().tintColor = UIColor.white
        
        UISegmentedControl.appearance().tintColor = UIColor.clear
        
        let attrNormal: [AnyHashable: Any] = [
            NSForegroundColorAttributeName: UIColor(red: (255.0/255.0), green: (255.0/255.0), blue: (255.0/255.0), alpha: 0.8),
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16.0)!
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(attrNormal as [AnyHashable: Any] , for: UIControlState())
        
        let attrSelected: [AnyHashable: Any] = [
            NSForegroundColorAttributeName: UIColor(red: (255.0/255.0), green: (255.0/255.0), blue: (255.0/255.0), alpha: 1.0),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 16.0)!
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(attrSelected as [AnyHashable: Any] , for: .selected)
        
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = Insurance_barTintColor
        UINavigationBar.appearance().tintColor = barTintColor
        UIToolbar.appearance().barTintColor = Insurance_barTintColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        DDLog.add(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
        
        // http://stackoverflow.com/questions/6411549/where-is-logfile-stored-using-cocoalumberjack
        let documentsFileManager = DDLogFileManagerDefault(logsDirectory:Utils.documentsDirectory.path)
        
        let fileLogger: DDFileLogger = DDFileLogger(logFileManager: documentsFileManager) // File Logger
        fileLogger.rollingFrequency = 60*60*24  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let sb = UIStoryboard(name:"SignInController",bundle:nil)
        let vc = sb.instantiateInitialViewController()
        self.window!.rootViewController = vc
        
        print(iService)
        
        return true
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        if iService.didSignedIn {
            InsuranceUtils.getHazards({ (success) in
                DDLogInfo("GetHazards Request OK")
            })
        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        
        var queryStrings = [String: String]()
        if let query = url.query {
            for qs in query.components(separatedBy: "&") {
                // Get the parameter name
                let key = qs.components(separatedBy: "=")[0]
                // Get the parameter value
                var value = qs.components(separatedBy: "=")[1]
                value = value.replacingOccurrences(of: "+", with: " ")
//                value = value.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
//                value = value.stringByRemovingPercentEncoding!
                value = value.removingPercentEncoding!
                
                queryStrings[key] = value
            }
        }
        
        UserPreferences.tokenWink = queryStrings["code"]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kWinkConnectionStateChanged), object: self,userInfo:nil)
        
        self.postWinkToken()
        
        return true
    }
    
    func postWinkToken()
    {
        guard let token = UserPreferences.tokenWink else {
            return
        }
        
        iService.postWinkToken(self, token: token) { (code) -> Void in
            switch code {
            case .ok(_):
                debugPrint("OK")
            case let .error(error):
                let message = error.localizedDescription
                DDLogError(message)
            case .httpStatus(let status,_):
                let message = HTTPURLResponse.localizedString(forStatusCode: status)
                DDLogError(message)
            case .cancelled:
                DDLogInfo("Wink Token Failed")
            }
  
        }

    }
    
    static func gotoInitialController() {
        
        debugPrint("gotoInitialController")
        
        self.fetchHazards()
        let window = UIApplication.shared.delegate?.window!
        
        let sb = UIStoryboard(name:"MenuManagerStoryboard",bundle:nil)
        let vc = sb.instantiateInitialViewController()
        
        UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
            UIView.performWithoutAnimation({ () -> Void in
                window!.rootViewController = vc
            })
            }, completion: nil)
    }
    
    static func updateApplicationBadge() {
        let moc = dataController.mainContext
        
        let fetchRequest = NSFetchRequest<HazardEvent>(entityName: StringFromClass(HazardEvent.self))
        fetchRequest.predicate = NSPredicate(format: "isHandled == false")
        
        let count = try? moc.count(for: fetchRequest)
        if count == NSNotFound {
            DDLogError("Core Data Error, AppDelegate updateApplicationBadge")
        } else {
            UIApplication.shared.applicationIconBadgeNumber = count!
        }
        
        let window = UIApplication.shared.delegate?.window!
        if let tbc = window?.rootViewController as? UITabBarController {
            if count == 0 {
                tbc.tabBar.items![1].badgeValue = nil
            } else {
                tbc.tabBar.items![1].badgeValue = String(describing: count)
            }
        }
        
    }
    
    //MARK: APN
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        DDLogInfo("Device Token: \(deviceToken)")
        
        let push = IMFPushClient.sharedInstance()
        
        push?.initialize(withAppGUID: PushRoute, clientSecret: PushSecret)
        push?.register(withDeviceToken: deviceToken) { (response, error) in
            if error != nil {
                print("Error during device registration \(error.debugDescription)")
            }
            else {
                let json = response?.responseJson
                if let deviceId = json?["deviceId"] as? String {
                    lastDeviceId = deviceId
                    
                    iService.postAPNToken(self, completion: { (code) in
                        switch code {
                        case .cancelled:
                            DDLogInfo("Cancelled")
                        case let .error(error):
                            DDLogError("postAPNToken: " + error.localizedDescription)
                        case let .httpStatus(status,_):
                            let message = HTTPURLResponse.localizedString(forStatusCode: status)
                            DDLogError("postAPNToken: " + message)
                        // Json object
                        case .ok(_):
                            DDLogInfo("APN OK")
                        }
                    })
                    
                } else {
                    DDLogError("Missing Device Id for push registration")
                }
                
                print("Response during device registration json: \(response?.responseJson.description)")
            }
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error){
        
        DDLogError("APNS Registration Error \(error)")
        
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        
        DDLogInfo("handleActionWithIdentifier: \(identifier)")
        completionHandler()
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        print(userInfo)
        
        DDLogInfo("didReceiveRemoteNotification \(userInfo)")
        DDLogInfo("applicationState:\(UIApplication.shared.applicationState.rawValue)")
        
        switch UIApplication.shared.applicationState {
        case .active:
            guard let aps = userInfo["aps"] as? [String:AnyObject] else {
                DDLogError("didReceiveRemoteNotification \(userInfo)")
                break
            }
            guard let alert = aps["alert"] as? [String:AnyObject] else {
                DDLogError("didReceiveRemoteNotification \(userInfo)")
                break
            }
            
            guard let alertTitle = alert["body"] as? String else {
                DDLogError("didReceiveRemoteNotification \(userInfo)")
                break
            }
            
            guard let payload = userInfo["payload"] as? String else {
                DDLogError("didReceiveRemoteNotification \(userInfo)")
                break
            }
            
            let data: Data = payload.data(using: String.Encoding.utf8)!
            guard let json:[String : AnyObject] = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject] else
            {
                DDLogError("didReceiveRemoteNotification /Users/amjadn\(userInfo)")
                break
            }
            
            Utils.addHazardEvent(json, hazardTitle: alertTitle)
            
        default:
            break
        }

    }
    
    fileprivate func showHazardEvent()
    {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "HazardDetailsStoryboard", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! UINavigationController
        (vc.topViewController as! HazardDetailsViewController).hazard = pushHazardEvent
        
        window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    func showErrorNotification(_ message:String)
    {
        let alert = UIAlertController(title: NSLocalizedString("Home Insurance",comment:""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok Button"), style: .default, handler: { (alertAction) -> Void in
        }))
        
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showHazardNotification(_ message:String, hazardEvent:HazardEvent)
    {
        self.pushHazardEvent = hazardEvent
        
        if ((window?.rootViewController?.presentedViewController as? UINavigationController)?.topViewController?.isKind(of: HazardDetailsViewController.self) == true)
        {
            debugPrint("HazardDetailsViewController already visible")
            
            return
        }
        
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: NSLocalizedString("Home Insurance",comment:""), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Show", comment: "Show Button"), style: .default, handler: { (alertAction) -> Void in
                self.showHazardEvent()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Dismiss Button"), style: .cancel, handler: { (alertAction) -> Void in
            }))
            
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        })

    }
    
    //MARK:
    
    static func fetchHazards() {
        
        let lockQueue = DispatchQueue(label: "com.test.LockQueue", attributes: [])
        lockQueue.sync {
            dataController.removeStore()
        }

        InsuranceUtils.initialHomeInsuranceData()
    }

}

