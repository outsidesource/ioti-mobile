//
//  HazardAlertsViewController.swift
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

