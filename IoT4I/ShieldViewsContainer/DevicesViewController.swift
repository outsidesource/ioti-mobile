//
//  DevicesViewController.swift
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
import SWRevealViewController

class DevicesViewController: UITableViewController {

    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    lazy var fetchedResultController:NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: NSStringFromClass(Device))
        
        let devicesDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [devicesDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        }
        catch let error as NSError {
            assertionFailure("perform fetch error \(error)")
        }
        catch {
            
        }
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
                
        self.tableView.registerNib(UINib(nibName: "DeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceTableViewCellID")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
  
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HazardAlertsViewController.contentsSizeChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func contentsSizeChanged(notification:NSNotification){
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataAndDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.performSegueWithIdentifier("DeviceInformation", sender: indexPath)

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let device = self.fetchedResultController.objectAtIndexPath(indexPath) as! Device
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DeviceTableViewCellID", forIndexPath: indexPath) as! DeviceTableViewCell
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.device = device
        
        return cell
        
    }
    

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case "DeviceDetails":
            
            let deviceDetailsViewController = segue.destinationViewController as! DeviceDetailsViewController
            let indexPath = sender as! NSIndexPath
            deviceDetailsViewController.device = self.fetchedResultController.objectAtIndexPath(indexPath) as? Device
            
            break
            
        case "DeviceInformation":
            
            let deviceDetailsViewController = segue.destinationViewController as! DeviceDescViewController
            let indexPath = sender as! NSIndexPath
            deviceDetailsViewController.device = self.fetchedResultController.objectAtIndexPath(indexPath) as? Device
            
            break

            
        default:
            break
        }
        
    }
    

}

extension DevicesViewController: NSFetchedResultsControllerDelegate {
    
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
