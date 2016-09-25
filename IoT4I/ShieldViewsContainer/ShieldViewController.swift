//
//  ShieldViewController.swift
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
