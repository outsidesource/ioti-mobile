//
//  Shield.swift
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