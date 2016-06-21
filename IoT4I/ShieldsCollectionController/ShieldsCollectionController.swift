//
//  ShieldsCollectionController.swift
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
