//
//  HazardAlertCell.swift
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
