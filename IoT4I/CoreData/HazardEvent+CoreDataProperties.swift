//
//  HazardEvent+CoreDataProperties.swift
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

extension HazardEvent {

    @NSManaged var id: String?
    @NSManaged var isHandled: NSNumber?
    @NSManaged var isLocal: NSNumber?
    @NSManaged var isUrgent: NSNumber?
    @NSManaged var isViolated: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var locationDesc: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var sensorDesc: String?
    @NSManaged var timestamp: NSDate?
    @NSManaged var title: String?
    @NSManaged var handledOperation:String?
    @NSManaged var handledBy: String?
    @NSManaged var handledAt: NSDate?
    @NSManaged var shield: Shield?

}
