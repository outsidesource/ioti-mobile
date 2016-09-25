//
//  TipsCollectionController.swift
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
import CocoaLumberjack
import MBProgressHUD

private let tipsCollectionViewCell = "TipsCollectionViewCell"

class TipsCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView:UICollectionView!
    
    @IBOutlet weak var btnRight:UIButton!
    @IBOutlet weak var btnLeft:UIButton!
    
    var tipsJson:[Promotion]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: tipsCollectionViewCell)
        let moc = dataController.writerContext
        tipsJson = try? Promotion.getPromotions(moc)

        self.collectionView!.registerNib(UINib(nibName: "TipCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: tipsCollectionViewCell)
        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView!.backgroundColor = UIColor(colorLiteralRed: (229.0/255.0), green: (229.0/255.0), blue: (229.0/255.0), alpha: 1.0)
 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TipsCollectionController.reloadView), name: kReloadPromotionView, object: nil)
        
        if (!didLoadPromotions)
        {
            MBProgressHUD.showHUDAddedTo(self.view,animated:true)
        }
        
    }
    
    func reloadView(notification:NSNotification) {
        
        let moc = dataController.writerContext
        tipsJson = try? Promotion.getPromotions(moc)
        
        self.collectionView.reloadData()
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        self.scrollViewDidEndDecelerating(self.collectionView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        showHideLeftRightButtons(NSIndexPath(forRow: 0, inSection: 0))
        return tipsJson?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(tipsCollectionViewCell, forIndexPath: indexPath) as! TipCollectionViewCell
    
        cell.promotion = tipsJson![indexPath.row]
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size:CGSize = CGSizeMake(self.collectionView!.frame.width, self.collectionView!.frame.height)
        return size
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
}

extension TipsCollectionController: UIScrollViewDelegate{
    
    @IBAction func leftClicked()
    {
        
        let currentIndexPath = self.collectionView.indexPathForCell(self.collectionView!.visibleCells().first!)
        
        if currentIndexPath!.row == 0
        {
            return
        }
        
        let previousIndexPath = NSIndexPath(forRow: currentIndexPath!.row - 1, inSection: 0)
        self.collectionView!.scrollToItemAtIndexPath(previousIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        self.scrollViewDidEndDecelerating(self.collectionView!)
        
        self.showHideLeftRightButtons(previousIndexPath)
    }
    
    @IBAction func rightClicked()
    {
        
        let currentIndexPath = self.collectionView.indexPathForCell(self.collectionView!.visibleCells().first!)
        
        if currentIndexPath!.row == (tipsJson?.count)! - 1
        {
            return
        }
        
        let nextIndexPath = NSIndexPath(forRow: currentIndexPath!.row + 1, inSection: 0)
        self.collectionView!.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        
        self.showHideLeftRightButtons(nextIndexPath)
        
    }
    
    func showHideLeftRightButtons(indexPath: NSIndexPath)
    {
        btnLeft.hidden = indexPath.row == 0
        btnRight.hidden = indexPath.row == (tipsJson?.count ?? 1)! - 1
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        btnLeft.hidden = scrollView.contentOffset.x == 0.0
        btnRight.hidden = scrollView.contentOffset.x == CGFloat((tipsJson?.count ?? 1) - 1) * self.collectionView!.frame.width
        
    }
}
