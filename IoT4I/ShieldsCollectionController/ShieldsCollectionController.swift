//
//  ShieldsCollectionController.swift
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
import CocoaLumberjack
import UICollectionView_NSFetchedResultsController

let kNumberOfShieldsUpdated = "kNumberOfShieldsUpdated"

private let reuseIdentifier = "ShieldCollectionViewCell"

class ShieldsCollectionController: UICollectionViewController, NSFetchedResultsControllerDelegate {

    private lazy var fetchedResultsController:NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName:StringFromClass(Shield))
        
        let idSortDescriptor = NSSortDescriptor(key: "name", ascending: false)

        fetchRequest.sortDescriptors = [idSortDescriptor]
        fetchRequest.fetchBatchSize = 25
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            DDLogError("perform fetch error \(error)")
            fatalError()
        }
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.registerNib(UINib(nibName: "ShieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView!.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0)
    }

    override func viewDidAppear(animated: Bool) {
        self.collectionView?.reloadData()
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            case "ShieldSegue":
                
                let shieldViewController = segue.destinationViewController as! ShieldViewController
                let indexPath = sender as! NSIndexPath
                shieldViewController.shield = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Shield
                
                break
            
            default:
                break
        }
    }
 

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections!.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShieldCollectionViewCell

        cell.shouldVibrate = false
        let shield = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Shield
        cell.shield = shield
        cell.additionalTasks()
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShieldCollectionViewCell
        cell.shouldVibrate = false
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 120.0)
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        self.performSegueWithIdentifier("ShieldSegue", sender: indexPath)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        self.collectionView?.addChangeForObjectAtIndexPath(indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        self.collectionView?.addChangeForSection(sectionInfo, atIndex: UInt(sectionIndex), forChangeType: type)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.collectionView?.commitChanges()
    }

}
