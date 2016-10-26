//
//  DeviceEditViewController.swift
//  IoT4I
//
//  Created by Amjad Nashashibi on 10/06/2016.
//
//  Data Privacy Disclaimer
//
//  This Program has been developed for demonstration purposes only to illustrate the technical capabilities and potential business uses of the IBM IoT for Insurance
//  The components included in this Program may involve the processing of personal information (for example location tracking and behavior analytics). When implemented in practice such processing may be subject to specific legal and regulatory requirements imposed by country specific data protection and privacy laws.  Any such requirements are not addressed in this Program.
//  Licensee is responsible for the ensuring Licenseeís use of this Program and any deployed solution meets applicable legal and regulatory requirements.  This may require the implementation of additional features and functions not included in the Program.
//
//  Apple License issue
//
//  This Program is intended solely for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools and further customized and distributed under the terms and conditions of Licenseeís licensed Apple iOS Developer Program or Licenseeís licensed Apple iOS Enterprise Program.
//  Licensee agrees to use the Program to customize and build the application for Licenseeís own purpose and distribute in accordance with the terms of Licenseeís Apple developer program
//  Risk Mitigation / Product Liability Issues
//  The Program and any resulting application is not intended for design, construction, control, or maintenance of automotive control systems where failure of such sample code or resulting application could give rise to a material threat of death or serious personal injury.  The Program is not intended for use where bodily injury, tangible property damage, or environmental contamination might occur as a result of a failure of or problem with such Program.
//  IBM shall have no responsibility regarding the Program's or resulting application's compliance with laws and regulations applicable to Licenseeís business and content. Licensee is responsible for use of the Program and any resulting application.
//  As with any development process, Licensee is responsible for developing, sufficiently testing and remediating Licenseeís products and applications and Licensee is solely responsible for any foreseen or unforeseen consequences or failures of Licenseeís products or applications.
//
//  REDISTRIBUTABLES
//
//  If the Program includes components that are Redistributable, they will be identified in the REDIST file that accompanies the Program. In addition to the license rights granted in the Agreement, Licensee may distribute the Redistributables subject to the following terms:
//  1) Redistribution must be in source code form only and must conform to all directions, instruction and specifications in the Program's accompanying REDIST or documentation;
//  2) If the Program's accompanying documentation expressly allows Licensee to modify the Redistributables, such modification must conform to all directions, instruction and specifications in that documentation and these modifications, if any, must be treated as Redistributables;
//  3) Redistributables may be distributed only as part of Licensee's application that was developed using the Program ("Licensee's Application") and only to support Licensee's customers in connection with their use of Licensee's Application. Licensee's application must constitute significant value add such that the Redistributables are not a substantial motivation for the acquisition by end users of Licensee's software product;
//  4) If the Redistributables include a Java Runtime Environment, Licensee must also include other non-Java Redistributables with Licensee's Application, unless the Application is designed to run only on general computer devices (e.g., laptops, desktops and servers) and not on handheld or other pervasive devices (i.e., devices that contain a microprocessor but do not have computing as their primary purpose);
//  5) Licensee may not remove any copyright or notice files contained in the Redistributables;
//  6) Licensee must hold IBM, its suppliers or distributors harmless from and against any claim arising out of the use or distribution of Licensee's Application;
//  7) Licensee may not use the same path name as the original Redistributable files/modules;
//  8) Licensee may not use IBM's, its suppliers or distributors names or trademarks in connection with the marketing of Licensee's Application without IBM's or that supplier's or distributor's prior written consent;
//  9) IBM, its suppliers and distributors provide the Redistributables and related documentation without obligation of support and "AS IS", WITH NO WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING THE WARRANTY OF TITLE, NON-INFRINGEMENT OR NON-INTERFERENCE AND THE IMPLIED WARRANTIES AND CONDITIONS OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.;
//  10) Licensee is responsible for all technical assistance for Licensee's Application and any modifications to the Redistributables; and
//  11) Licensee's license agreement with the end user of Licensee's Application must notify the end user that the Redistributables or their modifications may not be i) used for any purpose other than to enable Licensee's Application, ii) copied (except for backup purposes), iii) further distributed or transferred without Licensee's Application or iv) reverse assembled, reverse compiled, or otherwise translated except as specifically permitted by law and without the possibility of a contractual waiver. Furthermore, Licensee's license agreement must be at least as protective of IBM as the terms of this Agreement.
//
//  Feedback License
//
//  In the event Licensee provides feedback to IBM regarding the Program, Licensee agrees to assign to IBM all right, title, and interest (including ownership of copyright) in any data, suggestions, or written materials that 1) are related to the Program and 2) that Licensee provides to IBM.

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier! {
        case "typeSegue":
            
            let deviceTypeViewController = segue.destination as! DeviceTypeViewController
            deviceTypeViewController.delegate = self
            break
            
        default:
            break
        }
        
    }
    

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch (indexPath as NSIndexPath).row
        {
            
            case 0:
                self.showTextAlert(DeviceRow.name)
                break
            
            case 1:
                self.showTextAlert(DeviceRow.deviceType)
                break
            
            case 2:
                self.showTextAlert(DeviceRow.location)
                break
            
            case 3:
                self.showTextAlert(DeviceRow.Description)
                break
            
            // Case Delete Device
            case 4:

                let window = self.view.window
                MBProgressHUD.showAdded(to: window!,animated:true)
                iService.deleteDevicebyId(self, deviceId: self.device?.deviceId, completion: { (code) in
                    MBProgressHUD.hide(for: window!,animated:true)
                    switch code {
                    case .ok(_):
                        debugPrint("Delete Device OK")
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    case let .error(error):
                        let message = error.localizedDescription
                        DDLogError(message)
                        self.showError(message,title: "DeleteDevice.Alert.Title")
                    case .httpStatus(let status,_):
                        let message = HTTPURLResponse.localizedString(forStatusCode: status)
                        DDLogError(message)
                    case .cancelled:
                        DDLogInfo("Delete Device Failed")
                    }
                    
                })
                
                break
            // Other Cases -  Do Nothing
            default:
                break
        }
    }
    
    fileprivate func showTextAlert(_ deviceRow: DeviceRow)
    {
        
        var inputTextField: UITextField?
        let passwordPrompt = UIAlertController(title: "Attribute Edit", message: NSString(format: "You have selected to edit %@ attribute.", deviceRow.description) as String, preferredStyle: UIAlertControllerStyle.alert)
        passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        passwordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in

            let window = self.view.window
            MBProgressHUD.showAdded(to: window!,animated:true)
            
            iService.updateDevicebyId(self, deviceId: self.device?.deviceId, attributeName: deviceRow.attributeName, attributeValue: inputTextField?.text ?? "", completion: { (code) in
                MBProgressHUD.hide(for: window!,animated:true)
                switch code {
                case .ok(_):
                    debugPrint("Edit Device OK")

                    let moc = dataController.writerContext
                    moc.perform {
                        
                        switch deviceRow
                        {
                            case .name:
                                self.device?.name = inputTextField?.text ?? ""
                                self.txtName.text = inputTextField?.text ?? ""
                                break
                            
                            case .Description:
                                self.device?.desc = inputTextField?.text ?? ""
                                self.txtDesc.text = inputTextField?.text ?? ""
                                break
                            
                            case .location:
                                self.device?.location = inputTextField?.text ?? ""
                                self.txtLocation.text = inputTextField?.text ?? ""
                                break
                            
                            case .deviceType:
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

                case let .error(error):
                    let message = error.localizedDescription
                    DDLogError(message)
                    self.showError(message,title: "EditDevice.Alert.Title")
                case .httpStatus(let status,_):
                    let message = HTTPURLResponse.localizedString(forStatusCode: status)
                    DDLogError(message)
                case .cancelled:
                    DDLogInfo("Edit Device Failed")
                }
                
            })
            
        }))
        
        passwordPrompt.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = ""
            inputTextField = textField
        })
        
        present(passwordPrompt, animated: true, completion: nil)
    
    }
    
    fileprivate func showError(_ message:String, title:String){
        
        let alert = UIAlertController(title: NSLocalizedString(title,comment:"Delete Device Error"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button"), style: .default, handler: { (alertAction) -> Void in
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Device Type Delegate
    
    func updateDeviceType(_ str: String) {
        
    }
    
}
