//
//  InsuranceUtils.swift
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
import MBProgressHUD
import CocoaLumberjack
import BMSCore

class InsuranceUtils {
    
    // MARK: - Seeding Data
    static func initialHomeInsuranceData() {
        
        debugPrint("initialHomeInsuranceData")
        
        self.getShields { (success) in
            
            if (success)
            {
                
                self.getConfigData({ (success) in
                    
                })
                
                self.getDevices({ (success) in
                    
                })

                self.getHazards({ (success) in
                    
                })
                
                self.getPromotions({ (success) in
                    didLoadPromotions = true
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kReloadPromotionView), object: nil)
                    }
                })
            }
            else
            {
                
            }
            
        }
        
    }
    
    static func getShields(_ completion: @escaping (_ success: Bool) -> Void) {
        
        iService.apiGetPathData(self, path: APIxShieldsPath, method: kGET) { (code) in
            switch code {
            case .cancelled:
                DDLogInfo("Cancelled")
                break
            case let .error(error):
                DDLogError(error.localizedDescription)
                completion(false)
                break
            case let .httpStatus(status,json):
                let message = HTTPURLResponse.localizedString(forStatusCode: status)
                DDLogError(message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                break
            // Json object
            case let .ok(data):
                let moc = dataController.writerContext
                moc.perform {
                    guard let json = data?.responseJson as? [String: Any] else {
                        DDLogError("No JSON")
                        completion(false)
                        return
                    }
                    DDLogVerbose("\(json)")
                    guard let total = json["total"] as? Int , total > 0 else {
                        DDLogError("No total for Shields")
                        completion(false)
                        return
                    }
                    DDLogVerbose("number of shields \(total)")
                    
                    guard let shields = json["shields"] as? [[String:AnyObject]] else {
                        DDLogError("No Array for shields")
                        completion(false)
                        return
                    }
                    
                    let shieldParams = json["params"] as? [String:AnyObject] ?? [:]
                    
                    for jsonShield in shields {
                        let shield = NSEntityDescription.insertNewObject(forEntityName: StringFromClass(Shield.self),
                            into:moc) as! Shield
                        shield.id = jsonShield["id"] as? String
                        shield.uuid = jsonShield["UUID"] as? String
                        shield.name = jsonShield["name"] as? String
                        shield.image = jsonShield["image"] as? String ?? ""
                        shield.description_ = jsonShield["description"] as? String
                        shield.assistancePhone = shieldParams["assistancePhone"] as? String ?? "000"
                        shield.insurancePhone = jsonShield["insurancePhone"] as? String ?? "000"
                        DDLogVerbose("\(shield)")
                        
                    }
                    
                    do {
                        try moc.save()
                        completion(true)
                    } catch {
                        DDLogError("Core Data Error \(error)")
                    }
                }
            }
        }
    }
    
    static func getPromotions(_ completion: @escaping (_ success: Bool) -> Void) {
        
        iService.apiGetPathData(self, path: APIxPromotionsPath, method: kGET) { (code) in
            switch code {
            case .cancelled:
                DDLogInfo("Cancelled")
                break
            case let .error(error):
                DDLogError(error.localizedDescription)
                completion(false)
                break
            case let .httpStatus(status,json):
                let message = HTTPURLResponse.localizedString(forStatusCode: status)
                DDLogError(message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                completion(false)
                break
            // Json object
            case let .ok(data):
                let moc = dataController.writerContext
                moc.perform {
                    guard let json = data?.responseJson as? [String: Any] else {
                        DDLogError("No JSON")
                        completion(false)
                        return
                    }
                    DDLogVerbose("\(json)")
                    guard let total = json["total"] as? Int , total > 0 else {
                        DDLogError("No total for Promotions")
                        completion(false)
                        return
                    }
                    DDLogVerbose("number of promotions \(total)")
                    
                    guard let promotions = json["promotions"] as? [[String:AnyObject]] else {
                        DDLogError("No Array for promotions")
                        completion(false)
                        return
                    }
                    
                    for jsonPromotion in promotions {
                        let promotion = NSEntityDescription.insertNewObject(forEntityName: StringFromClass(Promotion.self),
                            into:moc) as! Promotion
                        promotion.id = jsonPromotion["id"] as? String ?? ""
                        promotion.title = jsonPromotion["title"] as? String ?? ""
                        promotion.desc = jsonPromotion["description"] as? String ?? ""
                        promotion.btnTitle = jsonPromotion["buttonTitle"] as? String ?? ""
                        promotion.phone = jsonPromotion["phone"] as? String ?? ""
                        promotion.timestamp = jsonPromotion["timestamp"] as? String ?? ""
                        promotion.image = jsonPromotion["image"] as? String ?? "tipPromo"
                        promotion.type =  jsonPromotion["type"] as? NSNumber ?? NSNumber(value: 0 as Int32)
                        
                        DDLogVerbose("\(promotion)")
                        
                    }
                    
                    do {
                        try moc.save()
                        completion(true)
                    } catch {
                        DDLogError("Core Data Error \(error)")
                    }
                }
            }
        }
    }
    
    static func getConfigData(_ completion: @escaping (_ success: Bool) -> Void) {
        iService.apiGetPathData(self, path: APIxConfigPath, method: kGET) { (code) in
            switch code {
            case .cancelled:
                DDLogInfo("Cancelled")
                break
            case let .error(error):
                DDLogError("getConfigData: " + error.localizedDescription)
                completion(false)
                break
            case let .httpStatus(status,json):
                let message = HTTPURLResponse.localizedString(forStatusCode: status)
                DDLogError("getConfigData: " + message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                completion(false)
                break
            // Json object
            case let .ok(data):
                
                guard let json = data?.responseJson as? [String: Any] else {
                    DDLogError("No JSON")
                    return
                }
                
                guard let imfPushJson = json["imfpush"] as? [String:AnyObject] else {
                    DDLogError("No JSON, imfPushJson")
                    return
                }
                
                guard let kPushRoute = imfPushJson["appGuid"] as? String else {
                    DDLogError("No JSON, imfPushJson")
                    return
                }
                
                guard let kPushSecret = imfPushJson["clientSecret"] as? String else {
                    DDLogError("No JSON, imfPushJson")
                    return
                }
                
                PushRoute = kPushRoute
                PushSecret = kPushSecret
                
                //Register to APN after initializing BlueMix backend
                let settings = UIUserNotificationSettings(types: [.badge,.alert, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
                UIApplication.shared.registerForRemoteNotifications()
                
                break
            }
        }
    }
    
    static func getDevices(_ completion: @escaping (_ success: Bool) -> Void) {
        
        iService.apiGetPathData(self, path: APIxDevicesPath, method: kGET) { (code) in
            switch code {
            case .cancelled:
                DDLogInfo("Cancelled")
                break
            case let .error(error):
                DDLogError(error.localizedDescription)
                completion(false)
                break
            case let .httpStatus(status,json):
                let message = HTTPURLResponse.localizedString(forStatusCode: status)
                DDLogError(message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                break
            // Json object
            case let .ok(data):
                let moc = dataController.writerContext
                moc.perform {
                    guard let json = data?.responseJson as? [String: Any] else {
                        DDLogError("No JSON")
                        completion(false)
                        return
                    }
                    DDLogVerbose("\(json)")
                    
                    guard let total = json["total"] as? Int , total > 0 else {
                        DDLogError("No total for Devices")
                        completion(false)
                        return
                    }
                    DDLogVerbose("number of devices \(total)")
                    
                    guard let devices = json["devices"] as? [[String:AnyObject]] else {
                        DDLogError("No Array for devices")
                        completion(false)
                        return
                    }
                    
                    for jsonDevice in devices {
                        let device = NSEntityDescription.insertNewObject(forEntityName: StringFromClass(Device.self),
                            into:moc) as! Device

                        device.name = jsonDevice["name"] as? String ?? "Unknown"
                        device.desc = jsonDevice["model_name"] as? String ?? "Unknown"
                        device.location = jsonDevice["location"] as? String ?? "Unknown"
                        device.image = jsonDevice["image"] as? String ?? "defaultSensorIconBlue"
                        device.deviceId = jsonDevice["_id"] as? String ?? ""
                        device.deviceType = jsonDevice["devicetype"] as? String ?? "Unknown"
                        device.activation =  Utils.parseTimestamp(jsonDevice["activation"] as? String ?? "2000-00-00T00:00:00,982Z")
 
                    }
                    
                    do {
                        try moc.save()
                        completion(true)
                    } catch {
                        DDLogError("Core Data Error \(error)")
                    }
                }
            }
        }
    }
    
    static func getHazards(_ completion: @escaping (_ success: Bool) -> Void) {
        
        iService.apiGetPathData(self, path: APIxHazardEventsPath, method: kGET) { (code) in
            switch code {
            case .cancelled:
                DDLogInfo("Cancelled")
                break
            case let .error(error):
                DDLogError(error.localizedDescription)
                completion(false)
                break
            case let .httpStatus(status,json):
                let message = HTTPURLResponse.localizedString(forStatusCode: status)
                DDLogError(message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                break
            // Json object
            case let .ok(data):

                let moc = dataController.writerContext
                moc.perform {
                    do {
                        
                        guard let json = data?.responseJson as? [String: Any] else {
                            DDLogError("No JSON")
                            completion(false)
                            return
                        }
                        DDLogVerbose("\(json)")
                        
                        guard let total = json["total"] as? Int , total > 0 else {
                            DDLogError("No total for HazardEvents")
                            completion(false)
                            return
                        }
                        DDLogVerbose("number of hazards \(total)")
                        
                        guard let newHazardEvents = json["hazardEvents"] as? [[String:AnyObject]] else {
                            DDLogError("No Array for hazards")
                            completion(false)
                            return
                        }

                        let fetchRequest = NSFetchRequest<HazardEvent>(entityName: StringFromClass(HazardEvent.self))
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
                        let currentHazardEvents = try moc.fetch(fetchRequest) 
                        DDLogVerbose("\(currentHazardEvents.count) local hazard events")
    
                        var nbInserted = 0
                        
                        for jsonHazardEvent in newHazardEvents {
                            guard let id = jsonHazardEvent["hazardid"] as? String else {
                                DDLogError("No hazardEvent ID")
                                continue
                            }
                            
                            if HazardEvent.hazardExists(id, moc: moc)
                            {
                                continue
                            }
                            
                            let newHazardEvent = true

                            if newHazardEvent {

                                var shieldUUID:String! = ""
                                
                                if (jsonHazardEvent["shieldUUID"] as? String) != nil
                                {
                                    shieldUUID = jsonHazardEvent["shieldUUID"] as! String
                                }
                                else if (jsonHazardEvent["shieldUUID"] as? Int) != nil
                                {
                                    shieldUUID = String(jsonHazardEvent["shieldUUID"] as! Int)
                                }
                                
                                // New Hazard event
                                guard shieldUUID != "" else {
                                    DDLogError("No shield UUID for hazardEvent \(id)")
                                    continue
                                }
                                
                                guard let shield = try? Shield.getShieldWithUUID(shieldUUID, moc: moc) else {
                                    DDLogError("Shield \(shieldUUID) not found")
                                    continue
                                }
                                
                                print(jsonHazardEvent)
                                
                                let hazardEvent = NSEntityDescription.insertNewObject(forEntityName: StringFromClass(HazardEvent.self),
                                    into:moc) as! HazardEvent
                                
                                hazardEvent.id = id
                                hazardEvent.shield = shield
                                hazardEvent.isHandled = jsonHazardEvent["isHandled"] as? NSNumber ?? NSNumber(value: 0 as Int32)
                                hazardEvent.isLocal = jsonHazardEvent["islocal"] as? NSNumber  ?? NSNumber(value: 0 as Int32)
                                hazardEvent.isViolated = jsonHazardEvent["isviolated"] as? NSNumber  ?? NSNumber(value: 0 as Int32)
                                hazardEvent.latitude = jsonHazardEvent["latitude"] as? NSNumber
                                hazardEvent.longitude = jsonHazardEvent["longitude"] as? NSNumber
                                hazardEvent.title = jsonHazardEvent["title"] as? String ?? ""
                                hazardEvent.timestamp = Utils.parseTimestamp(jsonHazardEvent["timestamp"] as? String ?? "2000-00-00T00:00:00,982Z") ?? Date()
                                hazardEvent.isUrgent = jsonHazardEvent["isUrgent"] as? NSNumber  ?? NSNumber(value: 0 as Int32)
                                hazardEvent.locationDesc = jsonHazardEvent["locationDesc"] as? String ?? "Unknown Location"
                                hazardEvent.sensorDesc = jsonHazardEvent["sensorDesc"] as? String
                                
                                if hazardEvent.latitude == nil {
                                    hazardEvent.latitude = 0
                                    hazardEvent.longitude = 0
                                }
                                
                                print(hazardEvent)
                                nbInserted += 1
                                
                                
                            }
                        }
                        
                        try moc.save()
                        DDLogInfo("\(nbInserted) hazard inserted")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kDidHazardsLoad), object: nil)
                        
                    } catch let error as InsuranceError {
                        DDLogError("\(error)")
                    } catch let error  {
                        DDLogError("\(error)")
                        fatalError()
                    }
                    
                    DispatchQueue.main.async{
                        AppDelegate.updateApplicationBadge()
                    }
                
                }
            }
        }
    }

    
}
