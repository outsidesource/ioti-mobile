//
//  DeviceEditViewController.swift
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
import MBProgressHUD
import CocoaLumberjack

class DeviceEditViewController: UITableViewController, DeviceTypeDelegate {

    @IBOutlet weak var txtName:UITextField!
    @IBOutlet weak var txtLocation:UITextField!
    @IBOutlet weak var txtType:UITextField!
    @IBOutlet weak var txtDesc:UITextView!
    
    var device:Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.device != nil
        {
            self.txtName.text = self.device?.name
            self.txtLocation.text = self.device?.location
            self.txtDesc.text = self.device?.desc
            self.txtType.text = self.device?.deviceType
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        switch segue.identifier! {
        case "typeSegue":
            
            let deviceTypeViewController = segue.destinationViewController as! DeviceTypeViewController
            deviceTypeViewController.delegate = self
            break
            
        default:
            break
        }
        
    }
    

    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.row
        {
            
            case 0:
                self.showTextAlert(DeviceRow.Name)
                break
            
            case 1:
                self.showTextAlert(DeviceRow.DeviceType)
                break
            
            case 2:
                self.showTextAlert(DeviceRow.Location)
                break
            
            case 3:
                self.showTextAlert(DeviceRow.Description)
                break
            
            // Case Delete Device
            case 4:

                let window = self.view.window
                MBProgressHUD.showHUDAddedTo(window,animated:true)
                iService.deleteDevicebyId(self, deviceId: self.device?.deviceId, completion: { (code) in
                    MBProgressHUD.hideHUDForView(window,animated:true)
                    switch code {
                    case .OK(_):
                        debugPrint("Delete Device OK")
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    case let .Error(error):
                        let message = error.localizedDescription
                        DDLogError(message)
                        self.showError(message,title: "DeleteDevice.Alert.Title")
                    case .HTTPStatus(let status,_):
                        let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                        DDLogError(message)
                    case .Cancelled:
                        DDLogInfo("Delete Device Failed")
                    }
                    
                })
                
                break
            // Other Cases -  Do Nothing
            default:
                break
        }
    }
    
    private func showTextAlert(deviceRow: DeviceRow)
    {
        
        var inputTextField: UITextField?
        let passwordPrompt = UIAlertController(title: "Attribute Edit", message: NSString(format: "You have selected to edit %@ attribute.", deviceRow.description) as String, preferredStyle: UIAlertControllerStyle.Alert)
        passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        passwordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in

            let window = self.view.window
            MBProgressHUD.showHUDAddedTo(window,animated:true)
            
            iService.updateDevicebyId(self, deviceId: self.device?.deviceId, attributeName: deviceRow.attributeName, attributeValue: inputTextField?.text ?? "", completion: { (code) in
                MBProgressHUD.hideHUDForView(window,animated:true)
                switch code {
                case .OK(_):
                    debugPrint("Edit Device OK")

                    let moc = dataController.writerContext
                    moc.performBlock {
                        
                        switch deviceRow
                        {
                            case .Name:
                                self.device?.name = inputTextField?.text ?? ""
                                self.txtName.text = inputTextField?.text ?? ""
                                break
                            
                            case .Description:
                                self.device?.desc = inputTextField?.text ?? ""
                                self.txtDesc.text = inputTextField?.text ?? ""
                                break
                            
                            case .Location:
                                self.device?.location = inputTextField?.text ?? ""
                                self.txtLocation.text = inputTextField?.text ?? ""
                                break
                            
                            case .DeviceType:
                                self.device?.deviceType = inputTextField?.text ?? ""
                                self.txtType.text = inputTextField?.text ?? ""
                                break
                        }
                        
                        do {
                            try moc.save()
                        } catch {
                            DDLogError("Core Data Error \(error)")
                        }
                    }

                case let .Error(error):
                    let message = error.localizedDescription
                    DDLogError(message)
                    self.showError(message,title: "EditDevice.Alert.Title")
                case .HTTPStatus(let status,_):
                    let message = NSHTTPURLResponse.localizedStringForStatusCode(status)
                    DDLogError(message)
                case .Cancelled:
                    DDLogInfo("Edit Device Failed")
                }
                
            })
            
        }))
        
        passwordPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = ""
            inputTextField = textField
        })
        
        presentViewController(passwordPrompt, animated: true, completion: nil)
    
    }
    
    private func showError(message:String, title:String){
        
        let alert = UIAlertController(title: NSLocalizedString(title,comment:"Delete Device Error"), message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button"), style: .Default, handler: { (alertAction) -> Void in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Device Type Delegate
    
    func updateDeviceType(str: String) {
        
    }
    
}
