//
//  InsuranceService.swift
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
import Foundation
import CocoaLumberjack
import BMSCore

public enum HTTPOperationResult {
    
    case ok(Response?)
    case cancelled
    case httpStatus(Int, Response?)
    case error(NSError)
    
}

public enum InsuranceError:Error {
    case noCredentials
    case operationAlreadyExecuting
    case moreThanOneEntity(String)
    case entityNotFound(String)
    case noEntitiesFound(String)
}

open class InsuranceService: NSObject
{
    open internal(set) var didSignedIn = false
    
    open var user:String?
    
    open internal(set) var password:String?

//    internal var mcaAuthenticationDelegate = MCAAuthenticationDelegate()
    
    public init(backendRoute:String, backendGUID:String)
    {
        
        BMSClient.sharedInstance.initialize(bluemixAppRoute: backendRoute, bluemixAppGUID: backendGUID, bluemixRegion: BMSClient.Region.usSouth)
        //BMSClient.sharedInstance.register(mcaAuthenticationDelegate,forRealm: applicationRealName)
        
        // TODO:
        //BMSClient.sharedInstance.authorizationManager.initialize(withTenantId: applicationId)
        
    }
    
    open func sendRequest(_ request: Request, completion: @escaping (_ code: HTTPOperationResult) -> Void) {
        
        request.send { (response, error) -> Void in
            
            if let error = error {
                
                completion(.error(error as NSError))
                
            } else if let response = response {
                
                self.logRequestResponse(request, response: response)
                
                if response.isSuccessful {
                    completion(.ok(response))
                } else {
                    completion(.httpStatus(Int(response.statusCode ?? -1), response))
                }
                
            }
        }
        
    }
    
    open func logRequestResponse(_ request: Request, response: Response) {
        
        debugPrint(request.resourceUrl + " resposeHttpStatus: ", response.statusCode ?? "-1")
        
    }
    
    open func signIn(_ delegate:AnyObject, username:String, password:String ,completion: @escaping (_ code: HTTPOperationResult) -> Void)
    {
        
        // TODO:
//        mcaAuthenticationDelegate.user = username
//        mcaAuthenticationDelegate.password = password
        
        let requestPath = "/reg/protected"
        let request = Request(url: requestPath)
        
        request.send { (response, error) -> Void in
            
            if (error != nil){
                
                completion(.error(error! as NSError))
                
            } else {
                
                self.user = username
                self.password = password

                Utils.writeCredential(username, password: password)
                self.didSignedIn = true
                completion(.ok(response))
                
            }
        }
    }
    
    open func deleteDevicebyId(_ delegate:AnyObject, deviceId:String?, completion: @escaping (_ code: HTTPOperationResult) -> Void) {
        
        let requestPath = "/reg/device/" + (deviceId ?? "")
        let request = Request(url: requestPath, method: .DELETE)
        sendRequest(request, completion: completion)
        
    }
    
    
    
    open func updateDevicebyId(_ delegate:AnyObject, deviceId:String?, attributeName:String?,  attributeValue:String?, completion: @escaping (_ code: HTTPOperationResult) -> Void) {
        
        let requestPath = "/reg/device/\(deviceId ?? "X")/\(attributeName ?? "X")/\(attributeValue ?? "X")"
        let request = Request(url: requestPath)
        sendRequest(request, completion: completion)
        
    }
    
    open func apiGetPathData(_ delegate: AnyObject, path: String, method: String,completion: @escaping (_ code: HTTPOperationResult) -> Void) {
        
        let requestPath = path
        let request = Request(url: requestPath)
        sendRequest(request, completion: completion)
        
    }
    
    open func postWinkToken(_ delegate:AnyObject, token:String, completion: @escaping (_ code: HTTPOperationResult) -> Void) {
        
        let requestPath = "/reg/auth/" + token
        let request = Request(url: requestPath)
        sendRequest(request, completion: completion)
    
    }
    
    open func postAPNToken(_ delegate:AnyObject, completion: @escaping (_ code: HTTPOperationResult) -> Void) {
        
        let requestPath = "/reg/user/setdeviceid/" + (lastDeviceId ?? "")
        let request = Request(url: requestPath)
        sendRequest(request, completion: completion)
        
    }
    
    open func postHazardAction(_ delegate:AnyObject, hazardId:String, hazardAction:String, completion: @escaping (_ code: HTTPOperationResult) -> Void) {

        let requestPath = "/reg/hazardEvents/setStatus/" + hazardId + "/" + hazardAction
        let request = Request(url: requestPath)
        sendRequest(request, completion: completion)
        
    }
    
    open func signOut(_ completion: @escaping (_ code: HTTPOperationResult) -> Void) {
        
        let requestPath = "/reg/logout"
        let request = Request(url: requestPath)
        
        request.send { (response, error) -> Void in
            
            if let error = error {
                
                completion(.error(error as NSError))
                
            } else {
                
                self.didSignedIn = false
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    Utils.removeCredential()
                    DispatchQueue.main.async {
                        completion(.ok(response))
                    }
                }
                
            }
        }
    }
    
}

// TODO:
//open class MCAAuthenticationDelegate : NSObject, IMFAuthenticationDelegate{
//
//    //MARK: IMFAuthenticationDelegate
//
//    open var user:String = ""
//    open var password:String = ""
//
//    open func authenticationContext(_ context: IMFAuthenticationContext!, didReceiveAuthenticationChallenge challenge: [AnyHashable: Any]!) {
//
//        debugPrint("didReceiveAuthenticationChallenge :: %@", challenge)
//
//        let challengeAnswer: [String:String] = [
//            "username":self.user,
//            "password":self.password
//        ]
//
//        context.submitAuthenticationChallengeAnswer(challengeAnswer)
//
//    }
//
//    open func authenticationContext(_ context: IMFAuthenticationContext!, didReceiveAuthenticationSuccess userInfo: [AnyHashable: Any]!) {
//        debugPrint("didReceiveAuthenticationSuccess")
//
//        context.submitAuthenticationSuccess()
//    }
//
//    open func authenticationContext(_ context: IMFAuthenticationContext!, didReceiveAuthenticationFailure userInfo: [AnyHashable: Any]!) {
//        debugPrint("didReceiveAuthenticationFailure")
//
//        context.submitAuthenticationFailure(userInfo)
//
//    }
//
//}

extension Response {
    
    var responseJson: Any? {
        
        if let responseData = self.responseData {
            return try? JSONSerialization.jsonObject(with: responseData, options: [])
        }
        return nil
        
    }
    
}
