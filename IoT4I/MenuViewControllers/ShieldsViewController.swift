//
//  ShieldsViewController.swift
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
