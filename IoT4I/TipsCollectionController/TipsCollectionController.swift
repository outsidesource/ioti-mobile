//
//  TipsCollectionController.swift
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
