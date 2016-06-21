//
//  ShieldViewController.swift
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

class ShieldViewController: UIViewController {

    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var devicesView: UIView!
    @IBOutlet weak var hazardsView: UIView!
    @IBOutlet weak var indicvatorView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgTitle: UIImageView!
    
    var shield:Shield!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = shield.name
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.lblTitle.text = self.shield.description_
        self.imgTitle.image = UIImage(named: self.shield.image!)
    }

    override func viewDidAppear(animated: Bool) {
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            
        case "Hazards":
            let hazardsViewController = segue.destinationViewController as! HazardAlertsViewController
            hazardsViewController.shield = self.shield
            break
            
        default:
            break
        }
    }


}

extension ShieldViewController {
    
    @IBAction func selector(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        
        let bounds = UIScreen.mainScreen().bounds
        if index == 0 {
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                self.devicesView.transform = CGAffineTransformMakeTranslation(bounds.width, 0)
                self.hazardsView.transform = CGAffineTransformIdentity
                self.indicvatorView.frame.origin.x = (self.selector.frame.width / 4) - self.indicvatorView.bounds.width / 2
                }, completion: { (finished) -> Void in
            })
            
        } else {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                self.devicesView.transform = CGAffineTransformIdentity
                self.hazardsView.transform = CGAffineTransformMakeTranslation(-bounds.width, 0)
                self.indicvatorView.frame.origin.x = (((self.selector.frame.width / 4) * 3) - self.indicvatorView.bounds.width / 2)
                }, completion: { (finished) -> Void in
            })
            
        }
        
    }
    
}
