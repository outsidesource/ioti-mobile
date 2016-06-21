//
//  ShieldCollectionViewCell.swift
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

class ShieldCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lblBadge: UILabel!
    @IBOutlet weak var viewBadge: UIView!
    @IBOutlet weak var imgShield: UIImageView!
    @IBOutlet weak var imgBadge: UIImageView!
    
    var shouldVibrate:Bool = false
    
    var shield:Shield! {
        didSet {

            self.name.text = shield.name
            self.imgShield.image = UIImage(named: shield.image!)
            
            let urgentHazardsCount = shield.hazards?.filter(
                {
                    ($0 as! HazardEvent).isUrgent!.boolValue == true && ($0 as! HazardEvent).isHandled!.boolValue == false
                }
                ).count
            
            let regularHazardsCount = shield.hazards?.filter(
                {
                    ($0 as! HazardEvent).isUrgent!.boolValue == false && ($0 as! HazardEvent).isHandled!.boolValue == false
                }
                ).count
            
            if urgentHazardsCount > 0
            {
                viewBadge.hidden = false
                imgBadge.setUrgentBackgroundImage()
                lblBadge.text = String(format: "%d", urgentHazardsCount!)
                name.setRedHazardousBackground()
                shouldVibrate = true
                self.animateUrgentHazards()
            }
            else if regularHazardsCount > 0
            {
                viewBadge.hidden = false
                imgBadge.setHazardousBackgroundImage()
                lblBadge.text = String(format: "%d", regularHazardsCount!)
                name.setOrangeHazardousBackground()
            }
            else
            {
                viewBadge.hidden = true
                lblBadge.text = ""
                imgBadge.clearImage()
                name.clearBackgroundColor()
            }
            
        }
    }
    
    func additionalTasks()
    {
        
    }
    
    let shrinkSize = CGFloat(9.0/10.0)
    
    func animateUrgentHazards()
    {
        let duration = 0.5
        UIView.animateWithDuration(duration / 2, delay: 0.0, options: [.BeginFromCurrentState , .CurveEaseInOut], animations: {
            self.imgBadge.transform = CGAffineTransformMakeScale(1 / self.shrinkSize, 1 / self.shrinkSize)
            }, completion: { finished in

                UIView.animateWithDuration(duration / 2, delay: 0.0, options: [.BeginFromCurrentState , .CurveEaseInOut], animations: {
                    self.imgBadge.transform = CGAffineTransformMakeScale(self.shrinkSize, self.shrinkSize)
                        
                    }, completion: { _ in
                        
                        if (self.shouldVibrate)
                        {
                            self.animateUrgentHazards()
                        }
                })

        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

}
