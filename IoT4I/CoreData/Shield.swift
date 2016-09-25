//
//  Shield.swift
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


import Foundation
import CoreData

public enum ShieldUUID:Int {
    case ExcessiveTemperatureExposure = 8
    case FallProtection = 2
    case HeatStress = 11
    case PanicButton = 9
    case HighHeartRateMonitoring = 4
    case HelmetIsOffMonitoring = 5
    case FallProtectioniOS = 1
    case MSBandShields = 7
    case ImpactDetection = 14
    case GasDetection = 15
}

@objc(Shield)
class Shield: NSManagedObject {
    
    var shieldUUID:ShieldUUID? {
        guard let uuid = uuid else {
            return nil
        }
        
        guard let uuid_int = Int(uuid) else {
            return nil
        }
        
        return ShieldUUID(rawValue: uuid_int)
    }
    
}

extension Shield {
    override var description:String {
        var d = ""
        if let id = self.id {
            d += "id: " + id + "\n"
        }
        if let uuid = self.uuid {
            d += "uuid: " + uuid + "\n"
        }
        if let name = self.name {
            d += "name: " + name + "\n"
        }
        if let type = self.type {
            d += "type: " + type + "\n"
        }
        if let description_ = self.description_ {
            d += "description: " + description_ + "\n"
        }
        return d
    }
    
    static func getShieldWithUUID(shieldUUID:String,moc:NSManagedObjectContext) throws -> Shield {
        let fetchRequest = NSFetchRequest(entityName: StringFromClass(Shield))
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", shieldUUID)
        
        do {
            let shields = try moc.executeFetchRequest(fetchRequest) as! [Shield]
            switch shields.count {
            case 0:
                throw InsuranceError.EntityNotFound(shieldUUID)
            case 1:
                return shields.first!
            default:
                throw InsuranceError.MoreThanOneEntity(shieldUUID)
                
            }
        } catch {
            throw error
        }
    }
}