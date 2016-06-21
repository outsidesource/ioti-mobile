//
//  AppDelegate.swift
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
import CoreData
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var pushHazardEvent:HazardEvent?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UITabBar.appearance().barTintColor = Insurance_barTintColor
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        UISegmentedControl.appearance().tintColor = UIColor.clearColor()
        
        let attrNormal: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor(red: (255.0/255.0), green: (255.0/255.0), blue: (255.0/255.0), alpha: 0.8),
            NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 16.0) ?? UIFont(name: "Helvetica Neue", size: 16.0)!
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(attrNormal as [NSObject : AnyObject] , forState: .Normal)
        
        let attrSelected: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor(red: (255.0/255.0), green: (255.0/255.0), blue: (255.0/255.0), alpha: 1.0),
            NSFontAttributeName: UIFont(name: "SFUIDisplay-Medium", size: 16.0) ?? UIFont(name: "Helvetica Neue", size: 16.0)!
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(attrSelected as [NSObject : AnyObject] , forState: .Selected)
        
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = Insurance_barTintColor
        UINavigationBar.appearance().tintColor = barTintColor
        UIToolbar.appearance().barTintColor = Insurance_barTintColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        DDLog.addLogger(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        DDLog.addLogger(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
        
        // http://stackoverflow.com/questions/6411549/where-is-logfile-stored-using-cocoalumberjack
        let documentsFileManager = DDLogFileManagerDefault(logsDirectory:Utils.documentsDirectory.path)
        
        let fileLogger: DDFileLogger = DDFileLogger(logFileManager: documentsFileManager) // File Logger
        fileLogger.rollingFrequency = 60*60*24  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.addLogger(fileLogger)
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        let sb = UIStoryboard(name:"SignInController",bundle:nil)
        let vc = sb.instantiateInitialViewController()
        self.window!.rootViewController = vc
        
        print(iService)
        
        return true
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName)
            print("Font Names = [\(names)]")
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        if iService.didSignedIn {
            InsuranceUtils.getHazards({ (success) in
                DDLogInfo("GetHazards Request OK")
            })
        }
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        
        var queryStrings = [String: String]()
        if let query = url.query {
            for qs in query.componentsSeparatedByString("&") {
                // Get the parameter name
                let key = qs.componentsSeparatedByString("=")[0]
                // Get the parameter value
                var value = qs.componentsSeparatedByString("=")[1]
                value = value.stringByReplacingOccurrencesOfString("+", withString: " ")
//                value = value.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                value = value.stringByRemovingPercentEncoding!
                
                queryStrings[key] = value
            }
        }
        
        UserPreferences.tokenWink = queryStrings["code"]
        NSNotificationCenter.defaultCenter().postNotificationName(kWinkConnectionStateChanged, object: self,userInfo:nil)
        
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
            case .OK(_):
                debugPrint("OK")
            case let .Error(error):
                let message = error.localizedDescription
                DDLogError(message)
            case .HTTPStatus(let status,_):
                let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                DDLogError(message)
            case .Cancelled:
                DDLogInfo("Wink Token Failed")
            }
  
        }

    }
    
    static func gotoInitialController() {
        
        debugPrint("gotoInitialController")
        
        self.fetchHazards()
        let window = UIApplication.sharedApplication().delegate?.window!
        
        let sb = UIStoryboard(name:"MenuManagerStoryboard",bundle:nil)
        let vc = sb.instantiateInitialViewController()
        
        UIView.transitionWithView(window!, duration: 0.5, options: .TransitionCrossDissolve, animations: { () -> Void in
            UIView.performWithoutAnimation({ () -> Void in
                window!.rootViewController = vc
            })
            }, completion: nil)
    }
    
    static func updateApplicationBadge() {
        let moc = dataController.mainContext
        
        let fetchRequest = NSFetchRequest(entityName: StringFromClass(HazardEvent))
        fetchRequest.predicate = NSPredicate(format: "isHandled == false")
        
        var error:NSError? = nil
        let count = moc.countForFetchRequest(fetchRequest, error: &error)
        if count == NSNotFound {
            DDLogError("Core Data Error \(error)")
        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber = count
        }
        
        let window = UIApplication.sharedApplication().delegate?.window!
        if let tbc = window?.rootViewController as? UITabBarController {
            if count == 0 {
                tbc.tabBar.items![1].badgeValue = nil
            } else {
                tbc.tabBar.items![1].badgeValue = String(count)
            }
        }
        
    }
    
    //MARK: APN
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        DDLogInfo("Device Token: \(deviceToken)")
        
        let push = IMFPushClient.sharedInstance()
        push.registerDeviceToken(deviceToken, completionHandler: { (response, error) -> Void in
            if error != nil {
                print("Error during device registration \(error.description)")
            }
            else {
                let json = response.responseJson
                if let deviceId = json["deviceId"] as? String {
                    lastDeviceId = deviceId
                } else {
                    DDLogError("Missing Device Id for push registration")
                }
                
                print("Response during device registration json: \(response.responseJson.description)")
            }
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError){
        
        DDLogError("APNS Registration Error \(error)")
        
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        DDLogInfo("handleActionWithIdentifier: \(identifier)")
        completionHandler()
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print(userInfo)
        
        DDLogInfo("didReceiveRemoteNotification \(userInfo)")
        DDLogInfo("applicationState:\(UIApplication.sharedApplication().applicationState.rawValue)")
        
        switch UIApplication.sharedApplication().applicationState {
        case .Active:
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
            
            let data: NSData = payload.dataUsingEncoding(NSUTF8StringEncoding)!
            guard let json:[String : AnyObject] = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String : AnyObject] else
            {
                DDLogError("didReceiveRemoteNotification /Users/amjadn\(userInfo)")
                break
            }
            
            Utils.addHazardEvent(json, hazardTitle: alertTitle)
            
        default:
            break
        }

    }
    
    private func showHazardEvent()
    {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "HazardDetailsStoryboard", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! UINavigationController
        (vc.topViewController as! HazardDetailsViewController).hazard = pushHazardEvent
        
        window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showErrorNotification(message:String)
    {
        let alert = UIAlertController(title: NSLocalizedString("Home Insurance",comment:""), message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok Button"), style: .Default, handler: { (alertAction) -> Void in
        }))
        
        window?.rootViewController
        window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showHazardNotification(message:String, hazardEvent:HazardEvent)
    {
        self.pushHazardEvent = hazardEvent
        
        if ((window?.rootViewController?.presentedViewController as? UINavigationController)?.topViewController?.isKindOfClass(HazardDetailsViewController) == true)
        {
            debugPrint("HazardDetailsViewController already visible")
            
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: NSLocalizedString("Home Insurance",comment:""), message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Show", comment: "Show Button"), style: .Default, handler: { (alertAction) -> Void in
                self.showHazardEvent()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Dismiss Button"), style: .Cancel, handler: { (alertAction) -> Void in
            }))
            
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        })

    }
    
    //MARK:
    
    static func fetchHazards() {
        
        let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
        dispatch_sync(lockQueue) {
            dataController.removeStore()
        }

        InsuranceUtils.initialHomeInsuranceData()
    }

}

