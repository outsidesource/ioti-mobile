//
//  Utils.swift
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
import AVFoundation
import CoreData
import CocoaLumberjack
import UICKeyChainStore

class Utils {
    static var sharedInstance = Utils()
    
}


extension Utils {
    
    class func addHazardEvent(_ hzrdEvntDic :[String:AnyObject], hazardTitle:String)
    {
        
        let moc = dataController.writerContext
        
        guard let shieldUUID = hzrdEvntDic["shieldUUID"] as? String else {
            DDLogError("HazardEvent ShieldUUID not found")
            return
        }
        
        guard let hazardID = hzrdEvntDic["hazardID"] as? String else {
            DDLogError("HazardEvent hazardEventId not found")
            return
        }
        
        guard let isUrgent = hzrdEvntDic["urgent"] as? Bool else {
            DDLogError("HazardEvent urgent not found")
            return
        }
        
        guard let locationDesc = hzrdEvntDic["locationDesc"] as? String else {
            DDLogError("HazardEvent locationDesc not found")
            return
        }
        
        guard let sensorDesc = hzrdEvntDic["deviceDesc"] as? String else {
            DDLogError("HazardEvent deviceDesc not found")
            return
        }
        
        guard let shield = try? Shield.getShieldWithUUID(shieldUUID, moc: moc) else {
            DDLogError("Shield \(shieldUUID) not found")
            return
        }
        
        moc.perform {
            
            let hazardEvent = NSEntityDescription.insertNewObject(forEntityName: StringFromClass(HazardEvent.self),
                into:moc) as! HazardEvent
            hazardEvent.id = hazardID
            hazardEvent.shield = shield
            hazardEvent.isHandled = false
            hazardEvent.isLocal = false
            hazardEvent.isViolated = false
            hazardEvent.latitude = 0
            hazardEvent.longitude = 0
            hazardEvent.title = hazardTitle
            hazardEvent.timestamp = Utils.parseTimestamp(hzrdEvntDic["timestamp"] as? String ?? "2000-00-00T00:00:00,982Z") ?? Date()
            hazardEvent.isUrgent = isUrgent as NSNumber?
            hazardEvent.locationDesc = locationDesc
            hazardEvent.sensorDesc = sensorDesc
            

            do {
                try moc.save()
            } catch {
                DDLogError("Core Data Error \(error)")
            }
            
            (UIApplication.shared.delegate as! AppDelegate).showHazardNotification(hazardTitle, hazardEvent: hazardEvent)

        }
    }
    
}

extension Utils {
    
    static let dateISO8601FormaterPoint = Utils.createISO8601DateFormatter(".")
    static let dateISO8601FormaterComma = Utils.createISO8601DateFormatter(",")
    
    static func setPlaceHolderColor(_ textField:UITextField,color:UIColor) {
        
        textField.attributedPlaceholder = NSAttributedString(string:textField.placeholder!,attributes:[NSForegroundColorAttributeName: color])
        
    }
    
    
    static func createISO8601DateFormatter(_ commaSeparator:Character) -> DateFormatter {
        
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'" + String(commaSeparator) + "'SSS'Z'"
        
        return df
        
    }
    
    static func parseTimestamp(_ ts:String?) -> Date? {
        
        guard let ts = ts else {
            return nil
        }
        
        var timestamp = dateISO8601FormaterPoint.date(from: ts)
        if timestamp == nil {
            timestamp = dateISO8601FormaterComma.date(from: ts)
        }
        return timestamp
        
    }
    
    static func DDMMYY(_ date: Date?) -> String?
    {
        guard let _ = date else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        
        return dateFormatter.string(from: date!)

    }
    
    static func DDMMYY_HHMM(_ date: Date?) -> String
    {
        guard let _ = date else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        
        return dateFormatter.string(from: date!)
        
    }
    
    static func HHMM(_ date: Date?) -> String
    {
        guard let _ = date else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date!)
        
    }
    
}

extension Utils {
    
    // MARK: - Sandbox directory
    static let applicationCachesDirectory:URL = {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }()
    
    static let applicationLibraryDirectory:URL = {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
    }()
    
    
    static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first!
    }()
    
}

extension Utils {
    
    static func setResourceAttributeExcludedFromBackupKeyToPath(_ filePath:String) {
        if let url:URL = URL(fileURLWithPath: filePath) {
            do {
                try (url as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
            } catch let err as NSError {
                fatalError("fatal error - \(err)")
            }
        }
    }
    
}

extension Utils {
    class func registerToAPN(_ application:UIApplication)
    {
        let okAction = UIMutableUserNotificationAction()
        okAction.identifier = notificationOK
        okAction.title = NSLocalizedString("APNS.OK", comment: "OK Push notification")
        
        okAction.activationMode = .background
        okAction.isDestructive = false
        okAction.isAuthenticationRequired = false
        
        let helpAction = UIMutableUserNotificationAction()
        helpAction.identifier = notificationHELP
        helpAction.title = NSLocalizedString("APNS.HELP", comment: "Help Push notification")
        
        helpAction.activationMode = .foreground
        helpAction.isDestructive = true
        helpAction.isAuthenticationRequired = false
        
        let checkInCategory = UIMutableUserNotificationCategory()
        checkInCategory.identifier = "CHECKIN_CATEGORY"
        checkInCategory.setActions([okAction], for: .default)
        checkInCategory.setActions([okAction], for: .minimal)
        
        let categories:NSSet = NSSet(array: [checkInCategory])
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories as? Set<UIUserNotificationCategory>)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
    }
}

extension Utils {
    class var isCredentialsPresent: Bool {
        
        do {
            
            let (username,password) = try self.getCredintials()
            
            if username != nil && username != "" && password != nil && password != "" {
                return true
            }
            
        } catch {
            return false
        }
        
        return false
    }
    
    
    class func getCredintials() throws -> (String?, String?)
    {
        let keychain = UICKeyChainStore(service:keyChainDomain)
        
        do {
            return (try keychain.string(forKey: "appUsername", error: ()), try keychain.string(forKey: "appPassword", error: ()))
        } catch {
            DDLogError("KeyChain Error \(error)")
            throw error
        }
    }
    
    class func writeCredential(_ user:String,password: String) {
        
        let keychain = UICKeyChainStore(service:keyChainDomain)
        keychain.setString(password, forKey: "appPassword")
        keychain.setString(user, forKey: "appUsername")
        
        UserPreferences.username = user
        
    }
    
    class func removeCredential() {
        let keychain = UICKeyChainStore(service:keyChainDomain)
        keychain.removeAllItems()
    }
    
}

public func StringFromClass(_ obj: AnyClass) -> String {
    return obj.description().components(separatedBy: ".").last!
}
extension UILabel {
    
    func setOrangeHazardousText()
    {
        self.textColor = HazardOrange_TintColor
    }
    
    func setRedHazardousText()
    {
        self.textColor = HazardRed_TintColor
    }
    
}

extension UIView {
    
    func setOrangeHazardousBackground()
    {
        self.backgroundColor = HazardOrange_TintColor
    }
    
    func clearBackgroundColor()
    {
        self.backgroundColor = UIColor.clear
    }
    
    func setRedHazardousBackground()
    {
        self.backgroundColor = HazardRed_TintColor
    }
    
}

extension UIImageView {
    
    func setOrangeBackgroundImage()
    {
        self.image = UIImage(named: "dotOrange")
    }
    
    func setRedBackgroundImage()
    {
        self.image = UIImage(named: "dotRed")
    }
    
    func setFullBackgroundImage()
    {
        self.image = UIImage(named: "dotFull")
    }
    
    func setOutlineBackgroundImage()
    {
        self.image = UIImage(named: "dotOutline")
    }
    
    func setHazardousBackgroundImage()
    {
        self.image = UIImage(named: "hazardousCircle")
    }
    
    func setUrgentBackgroundImage()
    {
        self.image = UIImage(named: "urgentCircle")
    }
    
    func clearImage()
    {
        self.image = nil
    }
}

