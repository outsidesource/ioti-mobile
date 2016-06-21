//
//  HazardAlertCell.swift
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

class HazardAlertCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTimestamp: UILabel!
    @IBOutlet weak var imgEvent: UIImageView!
    
    //Triggered
    @IBOutlet weak var lblTriggeredDays: UILabel!
    @IBOutlet weak var lblTriggeredMinutes: UILabel!
    
    //Handled
    @IBOutlet weak var lblHandledBy: UILabel!
    @IBOutlet weak var lblHandledAtDays: UILabel!
    @IBOutlet weak var lblHandledAtMinutes: UILabel!
    @IBOutlet weak var lblHandledOperation: UILabel!
    
    var expanded = false
    var delegate:HazardAlertCellDelegate?
    
    var event:HazardEvent! {
        didSet {
            self.lblName.text = event.title
            self.lblDesc.text = event.sensLocDesc
            self.lblTimestamp.text = Utils.DDMMYY_HHMM(event.timestamp)
            
            //Triggered
            self.lblTriggeredDays.text = Utils.DDMMYY(event.timestamp)
            self.lblTriggeredMinutes.text = Utils.HHMM(event.timestamp)

            //Handled
            self.lblHandledBy.text = event.handledBy
            self.lblHandledAtDays.text = Utils.DDMMYY(event.handledAt)
            self.lblHandledAtMinutes.text = Utils.HHMM(event.handledAt)
            self.lblHandledOperation.text = event.handledOperation

        }
    }
    
    @IBAction func expandBoxClicked(sender: UIButton)
    {
        self.delegate?.tableViewDidSelectExpandButton(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setExpanded(expanded: Bool, animated: Bool) {
        
        self.expanded = expanded
        
    }
    
}
