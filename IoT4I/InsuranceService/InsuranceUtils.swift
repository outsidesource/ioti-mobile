//
//  InsuranceUtils.swift
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
import CoreData
import MBProgressHUD
import CocoaLumberjack

class InsuranceUtils {
    
    // MARK: - Seeding Data
    static func initialHomeInsuranceData() {
        
        debugPrint("initialHomeInsuranceData")
        
        self.getShields { (success) in
            
            if (success)
            {
                iService.postAPNToken(self, completion: { (code) in
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
                        DDLogInfo("APN OK")
                    }
                })
                
                self.getDevices({ (success) in
                    
                })

                self.getHazards({ (success) in
                    
                })
                
                self.getPromotions({ (success) in
                    didLoadPromotions = true
                    dispatch_async(dispatch_get_main_queue()) {
                        NSNotificationCenter.defaultCenter().postNotificationName(kReloadPromotionView, object: nil)
                    }
                })
            }
            else
            {
                
            }
            
        }
        
    }
    
    static func getShields(completion: (success: Bool) -> Void) {
        
        iService.apiGetPathData(self, path: APIxShieldsPath, method: kGET) { (code) in
            switch code {
            case .Cancelled:
                DDLogInfo("Cancelled")
                break
            case let .Error(error):
                DDLogError(error.localizedDescription)
                completion(success: false)
                break
            case let .HTTPStatus(status,json):
                let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                DDLogError(message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                break
            // Json object
            case let .OK(data):
                let moc = dataController.writerContext
                moc.performBlock {
                    guard let json = data!.responseJson else {
                        DDLogError("No JSON")
                        return
                    }
                    DDLogVerbose("\(json)")
                    guard let total = json["total"] as? Int where total > 0 else {
                        DDLogError("No total for Shields")
                        return
                    }
                    DDLogVerbose("number of shields \(total)")
                    
                    guard let shields = json["shields"] as? [[String:AnyObject]] else {
                        DDLogError("No Array for shields")
                        return
                    }
                    
                    let shieldParams = json["params"] as? [String:AnyObject] ?? [:]
                    
                    for jsonShield in shields {
                        let shield = NSEntityDescription.insertNewObjectForEntityForName(StringFromClass(Shield),
                            inManagedObjectContext:moc) as! Shield
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
                        completion(success: true)
                    } catch {
                        DDLogError("Core Data Error \(error)")
                    }
                }
            }
        }
    }
    
    static func getPromotions(completion: (success: Bool) -> Void) {
        
        iService.apiGetPathData(self, path: APIxPromotionsPath, method: kGET) { (code) in
            switch code {
            case .Cancelled:
                DDLogInfo("Cancelled")
                break
            case let .Error(error):
                DDLogError(error.localizedDescription)
                completion(success: false)
                break
            case let .HTTPStatus(status,json):
                let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                DDLogError(message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                completion(success: false)
                break
            // Json object
            case let .OK(data):
                let moc = dataController.writerContext
                moc.performBlock {
                    guard let json = data!.responseJson else {
                        DDLogError("No JSON")
                        completion(success: false)
                        return
                    }
                    DDLogVerbose("\(json)")
                    guard let total = json["total"] as? Int where total > 0 else {
                        DDLogError("No total for Promotions")
                        completion(success: false)
                        return
                    }
                    DDLogVerbose("number of promotions \(total)")
                    
                    guard let promotions = json["promotions"] as? [[String:AnyObject]] else {
                        DDLogError("No Array for promotions")
                        completion(success: false)
                        return
                    }
                    
                    for jsonPromotion in promotions {
                        let promotion = NSEntityDescription.insertNewObjectForEntityForName(StringFromClass(Promotion),
                            inManagedObjectContext:moc) as! Promotion
                        promotion.id = jsonPromotion["id"] as? String ?? ""
                        promotion.title = jsonPromotion["title"] as? String ?? ""
                        promotion.desc = jsonPromotion["description"] as? String ?? ""
                        promotion.btnTitle = jsonPromotion["buttonTitle"] as? String ?? ""
                        promotion.phone = jsonPromotion["phone"] as? String ?? ""
                        promotion.timestamp = jsonPromotion["timestamp"] as? String ?? ""
                        promotion.image = jsonPromotion["image"] as? String ?? "tipPromo"
                        promotion.type =  jsonPromotion["type"] as? NSNumber ?? NSNumber(int: 0)
                        
                        DDLogVerbose("\(promotion)")
                        
                    }
                    
                    do {
                        try moc.save()
                        completion(success: true)
                    } catch {
                        DDLogError("Core Data Error \(error)")
                    }
                }
            }
        }
    }
    
    static func getDevices(completion: (success: Bool) -> Void) {
        
        iService.apiGetPathData(self, path: APIxDevicesPath, method: kGET) { (code) in
            switch code {
            case .Cancelled:
                DDLogInfo("Cancelled")
                break
            case let .Error(error):
                DDLogError(error.localizedDescription)
                completion(success: false)
                break
            case let .HTTPStatus(status,json):
                let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                DDLogError(message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                break
            // Json object
            case let .OK(data):
                let moc = dataController.writerContext
                moc.performBlock {
                    guard let json = data!.responseJson else {
                        DDLogError("No JSON")
                        return
                    }
                    DDLogVerbose("\(json)")
                    
                    guard let total = json["total"] as? Int where total > 0 else {
                        DDLogError("No total for Devices")
                        return
                    }
                    DDLogVerbose("number of devices \(total)")
                    
                    guard let devices = json["devices"] as? [[String:AnyObject]] else {
                        DDLogError("No Array for devices")
                        return
                    }
                    
                    for jsonDevice in devices {
                        let device = NSEntityDescription.insertNewObjectForEntityForName(StringFromClass(Device),
                            inManagedObjectContext:moc) as! Device

                        device.name = jsonDevice["name"] as? String ?? "Unknown"
                        device.desc = jsonDevice["description"] as? String ?? "Unknown"
                        device.location = jsonDevice["location"] as? String ?? "Unknown"
                        device.image = jsonDevice["image"] as? String ?? ""
                        device.deviceId = jsonDevice["id"] as? String ?? ""
                        device.deviceType = jsonDevice["devicetype"] as? String ?? "Unknown"
                        device.activation =  Utils.parseTimestamp(jsonDevice["activation"] as? String ?? "2000-00-00T00:00:00,982Z")
 
                    }
                    
                    do {
                        try moc.save()
                        completion(success: true)
                    } catch {
                        DDLogError("Core Data Error \(error)")
                    }
                }
            }
        }
    }
    
    static func getHazards(completion: (success: Bool) -> Void) {
        
        iService.apiGetPathData(self, path: APIxHazardEventsPath, method: kGET) { (code) in
            switch code {
            case .Cancelled:
                DDLogInfo("Cancelled")
                break
            case let .Error(error):
                DDLogError(error.localizedDescription)
                completion(success: false)
                break
            case let .HTTPStatus(status,json):
                let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                DDLogError(message)
                if let json = json {
                    DDLogVerbose("\(json)")
                }
                break
            // Json object
            case let .OK(data):

                let moc = dataController.writerContext
                moc.performBlock {
                    do {
                        
                        guard let json = data!.responseJson else {
                            DDLogError("No JSON")
                            return
                        }
                        DDLogVerbose("\(json)")
                        
                        guard let total = json["total"] as? Int where total > 0 else {
                            DDLogError("No total for HazardEvents")
                            return
                        }
                        DDLogVerbose("number of hazards \(total)")
                        
                        guard let newHazardEvents = json["hazardEvents"] as? [[String:AnyObject]] else {
                            DDLogError("No Array for hazards")
                            return
                        }

                        let fetchRequest = NSFetchRequest(entityName: StringFromClass(HazardEvent))
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
                        let currentHazardEvents = try moc.executeFetchRequest(fetchRequest) as! [HazardEvent]
                        DDLogVerbose("\(currentHazardEvents.count) local hazard events")
    
                        var nbInserted = 0
                        
                        for jsonHazardEvent in newHazardEvents {
                            guard let id = jsonHazardEvent["id"] as? String else {
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
                                
                                let hazardEvent = NSEntityDescription.insertNewObjectForEntityForName(StringFromClass(HazardEvent),
                                    inManagedObjectContext:moc) as! HazardEvent
                                
                                hazardEvent.id = id
                                hazardEvent.shield = shield
                                hazardEvent.isHandled = jsonHazardEvent["isHandled"] as? NSNumber ?? NSNumber(int: 0)
                                hazardEvent.isLocal = jsonHazardEvent["islocal"] as? NSNumber  ?? NSNumber(int: 0)
                                hazardEvent.isViolated = jsonHazardEvent["isviolated"] as? NSNumber  ?? NSNumber(int: 0)
                                hazardEvent.latitude = jsonHazardEvent["latitude"] as? NSNumber
                                hazardEvent.longitude = jsonHazardEvent["longitude"] as? NSNumber
                                hazardEvent.title = jsonHazardEvent["title"] as? String ?? ""
                                hazardEvent.timestamp = Utils.parseTimestamp(jsonHazardEvent["timestamp"] as? String ?? "2000-00-00T00:00:00,982Z") ?? NSDate()
                                hazardEvent.isUrgent = jsonHazardEvent["isUrgent"] as? NSNumber  ?? NSNumber(int: 0)
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
                        NSNotificationCenter.defaultCenter().postNotificationName(kDidHazardsLoad, object: nil)
                        
                    } catch let error as InsuranceError {
                        DDLogError("\(error)")
                    } catch let error  {
                        DDLogError("\(error)")
                        fatalError()
                    }
                    
                    dispatch_async(dispatch_get_main_queue()){
                        AppDelegate.updateApplicationBadge()
                    }
                
                }
            }
        }
    }

    
}
