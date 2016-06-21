//
//  InsuranceUtils.swift
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
