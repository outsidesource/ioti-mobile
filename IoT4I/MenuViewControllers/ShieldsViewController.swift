//
//  ShieldsViewController.swift
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
import QuartzCore
import CoreData
import SWRevealViewController

class ShieldsViewController: UIViewController {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var lblTitle:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 315
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShieldsViewController.updateTitle), name: kUpdateShieldsTitle, object: nil)
        
        self.updateTitle()
        
    }

    func updateTitle()
    {
        let moc = dataController.mainContext
        
        let fetchRequest = NSFetchRequest(entityName: StringFromClass(HazardEvent))
        fetchRequest.predicate = NSPredicate(format: "isHandled == false AND isUrgent == true")
        
        var error:NSError? = nil
        let count = moc.countForFetchRequest(fetchRequest, error: &error)
        if count == NSNotFound {
            debugPrint("Core Data Error \(error)")
        } else {
            
            if count != 0
            {
                lblTitle.text = "Your immediate attention is required!"
            }
            else
            {
                let fetchRequest = NSFetchRequest(entityName: StringFromClass(HazardEvent))
                fetchRequest.predicate = NSPredicate(format: "isHandled == false AND isUrgent == false")
                
                var error:NSError? = nil
                let count = moc.countForFetchRequest(fetchRequest, error: &error)
                if count == NSNotFound {
                    debugPrint("Core Data Error \(error)")
                } else {
                    
                    lblTitle.text = (count != 0) ? "An issue needs your attention" : "Your house is fully protected!"

                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
