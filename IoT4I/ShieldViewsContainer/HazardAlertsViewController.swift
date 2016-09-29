//
//  HazardAlertsViewController.swift
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

protocol HazardAlertCellDelegate{
    func tableViewDidSelectExpandButton(cell: UITableViewCell)
    func tableViewDidSelectHandleButton(indexPath: NSIndexPath)
}

let hazardAlertCellHeight:CGFloat = 107.0

class HazardAlertsViewController: UITableViewController {

    var shield:Shield!
    
    var expandedCellNumber:Int = -1
    
    lazy var fetchedResultController:NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: NSStringFromClass(HazardEvent))
        
        let hazardTimestampDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        let hazardHandledDescriptor = NSSortDescriptor(key: "isHandled", ascending: true)
        let hazardUrgentDescriptor = NSSortDescriptor(key: "isUrgent", ascending: false)
        fetchRequest.sortDescriptors = [hazardHandledDescriptor, hazardUrgentDescriptor, hazardTimestampDescriptor]
        fetchRequest.predicate = NSPredicate(format: "SELF.shield.uuid == %@", self.shield.uuid!)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        }
        catch let error as NSError {
            //print(error)
            assertionFailure("perform fetch error \(error)")
        }
        catch {
            
        }
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "HazardAlertCell", bundle: nil), forCellReuseIdentifier: "HazardAlertCellID")
        self.tableView.registerNib(UINib(nibName: "HazardAlertHandleCell", bundle: nil), forCellReuseIdentifier: "HazardAlertHandleCellID")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HazardAlertsViewController.contentsSizeChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func contentsSizeChanged(notification:NSNotification){
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case "HazardDetails":
            let hzrdDetNavigationController = segue.destinationViewController as! UINavigationController
            let indexPath = sender as! NSIndexPath
            (hzrdDetNavigationController.topViewController as! HazardDetailsViewController).hazard = self.fetchedResultController.objectAtIndexPath(indexPath) as? HazardEvent
            break
        default:
            break
        }
        
    }

    // MARK: UITableViewDataAndDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let event = self.fetchedResultController.objectAtIndexPath(indexPath) as! HazardEvent
        
        if (event.isHandled!.boolValue)
        {
            return (expandedCellNumber != indexPath.row) ? hazardAlertCellHeight : (hazardAlertCellHeight + 80.0)
        }
        
        return 180.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = self.fetchedResultController.objectAtIndexPath(indexPath) as! HazardEvent
        
        if event.isHandled!.boolValue
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("HazardAlertCellID", forIndexPath: indexPath) as! HazardAlertCell
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            cell.event = event
            cell.delegate = self
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("HazardAlertHandleCellID", forIndexPath: indexPath) as! HazardAlertHandleCell
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            cell.indexPath = indexPath
            cell.event = event
            cell.delegate = self
            
            return cell
        }
        
    }
    
}

extension HazardAlertsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch(type){
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
   
}

extension HazardAlertsViewController: HazardAlertCellDelegate
{
    func tableViewDidSelectExpandButton(cell: UITableViewCell)
    {
        let indexPath:NSIndexPath = self.tableView.indexPathForCell(cell)!
        
        if (expandedCellNumber == -1)
        {
            expandedCellNumber = indexPath.row
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! HazardAlertCell
            cell.setExpanded(true, animated: true)
        }
        else
        {
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: expandedCellNumber, inSection: 0)) as! HazardAlertCell
            cell.setExpanded(false, animated: true)
            expandedCellNumber = -1
        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()

        self.tableView.separatorStyle = .SingleLine
        
    }
    
    func tableViewDidSelectHandleButton(indexPath: NSIndexPath)
    {
        self.performSegueWithIdentifier("HazardDetails", sender: indexPath)
    }
}

