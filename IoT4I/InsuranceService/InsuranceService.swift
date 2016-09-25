//
//  InsuranceService.swift
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
import Foundation
import CocoaLumberjack

public enum HTTPOperationResult {
    
    case OK(AnyObject?)
    case Cancelled
    case HTTPStatus(Int,AnyObject?)
    case Error(NSError)
    
}

public enum InsuranceError:ErrorType {
    case NoCredentials
    case OperationAlreadyExecuting
    case MoreThanOneEntity(String)
    case EntityNotFound(String)
    case NoEntitiesFound(String)
}

public class InsuranceService: NSObject
{
    public internal(set) var didSignedIn = false
    
    public var user:String?
    
    public internal(set) var password:String?

    internal var mcaAuthenticationDelegate = MCAAuthenticationDelegate()
    
    public init(backendRoute:String, backendGUID:String)
    {
        
        IMFClient.sharedInstance().initializeWithBackendRoute(applicationRoute, backendGUID: applicationId)
        IMFClient.sharedInstance().registerAuthenticationDelegate(mcaAuthenticationDelegate,forRealm: applicationRealName)
        
        //Register to APN after initializing BlueMix backend
        let settings = UIUserNotificationSettings(forTypes: [.Badge,.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()

    }
    
    public func signIn(delegate:AnyObject, username:String, password:String ,completion: (code: HTTPOperationResult) -> Void)
    {
        mcaAuthenticationDelegate.user = username
        mcaAuthenticationDelegate.password = password
        
        let requestPath = IMFClient.sharedInstance().backendRoute + "/reg/protected"
        let request = IMFResourceRequest(path: requestPath, method: kGET)
        
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                completion(code: .Error(error))
            } else {
                self.user = username
                self.password = password
                
                Utils.writeCredential(username, password: password)
                self.didSignedIn = true
                completion(code: .OK(response))
            }
        };
    }
    
    public func deleteDevicebyId(delegate:AnyObject, deviceId:String?, completion: (code: HTTPOperationResult) -> Void)
    {
        let requestPath = IMFClient.sharedInstance().backendRoute + "/reg/device/" + (deviceId ?? "")
        let request = IMFResourceRequest(path: requestPath, method: kDelete)
        
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                completion(code: .Error(error))
            } else {
                
                debugPrint(requestPath + " resposeHttpStatus: ", response.httpStatus)
                
                switch response.httpStatus
                {
                case 200:
                    completion(code: .OK(response))
                    break
                    
                default:
                    completion(code: .HTTPStatus(Int(response.httpStatus),response.responseJson))
                    break
                }
                
            }
        };
    }
    
    public func updateDevicebyId(delegate:AnyObject, deviceId:String?, attributeName:String?,  attributeValue:String?, completion: (code: HTTPOperationResult) -> Void)
    {
        let requestPath = IMFClient.sharedInstance().backendRoute + "/reg/device/" + (deviceId ?? "X") + "/" + (attributeName ?? "X") + "/" + (attributeValue ?? "X")
        let request = IMFResourceRequest(path: requestPath, method: kPost)
        
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                completion(code: .Error(error))
            } else {
                
                debugPrint(requestPath + " resposeHttpStatus: ", response.httpStatus)
                
                switch response.httpStatus
                {
                case 200:
                    completion(code: .OK(response))
                    break
                    
                default:
                    completion(code: .HTTPStatus(Int(response.httpStatus),response.responseJson))
                    break
                }
                
            }
        };
    }
    
    public func apiGetPathData(delegate: AnyObject, path: String, method: String,completion: (code: HTTPOperationResult) -> Void)
    {
        debugPrint("API REQUEST " + path)
        
        let requestPath = IMFClient.sharedInstance().backendRoute + path
        let request = IMFResourceRequest(path: requestPath, method: method)
        
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                completion(code: .Error(error))
            } else {
                
                debugPrint(requestPath + " resposeHttpStatus: ", response.httpStatus)
                
                switch response.httpStatus
                {
                case 200:
                    completion(code: .OK(response))
                    break
                    
                default:
                    completion(code: .HTTPStatus(Int(response.httpStatus),response.responseJson))
                    break
                }
            }
        };
    }
    
    public func postWinkToken(delegate:AnyObject, token:String, completion: (code: HTTPOperationResult) -> Void)
    {
        let requestPath = IMFClient.sharedInstance().backendRoute + "/reg/auth/" + token
        let request = IMFResourceRequest(path: requestPath, method: kPost)
        
        debugPrint("TOKEN")
        debugPrint(token)
        
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                completion(code: .Error(error))
            } else {
                
                debugPrint(requestPath + " resposeHttpStatus: ", response.httpStatus)
                
                switch response.httpStatus
                {
                case 200:
                    completion(code: .OK(response))
                    break
                    
                default:
                    completion(code: .HTTPStatus(Int(response.httpStatus),response.responseJson))
                    break
                }
                
            }
        };
    }
    
    public func postAPNToken(delegate:AnyObject, completion: (code: HTTPOperationResult) -> Void)
    {
        let requestPath = IMFClient.sharedInstance().backendRoute + "/reg/user/setdeviceid/" + (lastDeviceId ?? "")
        let request = IMFResourceRequest(path: requestPath, method: kPost)
        
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                completion(code: .Error(error))
            } else {
                
                debugPrint(requestPath + " resposeHttpStatus: ", response.httpStatus)
                
                switch response.httpStatus
                {
                case 200:
                    completion(code: .OK(response))
                    break
                    
                default:
                    completion(code: .HTTPStatus(Int(response.httpStatus),response.responseJson))
                    break
                }
                
            }
        };
    }
    
    public func postHazardAction(delegate:AnyObject, hazardId:String, hazardAction:String, completion: (code: HTTPOperationResult) -> Void)
    {

        let requestPath = IMFClient.sharedInstance().backendRoute + "/reg/hazardEvents/setStatus/" + hazardId + "/" + hazardAction
        let request = IMFResourceRequest(path: requestPath, method: kPost)

        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                completion(code: .Error(error))
            } else {
                
                debugPrint(requestPath + " resposeHttpStatus: ", response.httpStatus)
                
                switch response.httpStatus
                {
                case 200:
                    completion(code: .OK(response))
                    break
                    
                default:
                    completion(code: .HTTPStatus(Int(response.httpStatus),response.responseJson))
                    break
                }
                
            }
        };
        
    }
    
    public func signOut(completion: (code: HTTPOperationResult) -> Void) {
        
        let requestPath = IMFClient.sharedInstance().backendRoute + "/reg/logout"
        let request = IMFResourceRequest(path: requestPath, method: kPost)
        
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (nil != error){
                completion(code: .Error(error))
            } else {
                self.didSignedIn = false
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    Utils.removeCredential()
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(code: .OK(response))
                    }
                }
            }
        };
    }
    
}


public class MCAAuthenticationDelegate : NSObject, IMFAuthenticationDelegate{
    
    //MARK: IMFAuthenticationDelegate

    public var user:String = ""
    public var password:String = ""
    
    public func authenticationContext(context: IMFAuthenticationContext!, didReceiveAuthenticationChallenge challenge: [NSObject : AnyObject]!) {
        
        debugPrint("didReceiveAuthenticationChallenge :: %@", challenge)

        let challengeAnswer: [String:String] = [
            "username":self.user,
            "password":self.password
        ]
        
        context.submitAuthenticationChallengeAnswer(challengeAnswer)
        
    }
    
    public func authenticationContext(context: IMFAuthenticationContext!, didReceiveAuthenticationSuccess userInfo: [NSObject : AnyObject]!) {
        debugPrint("didReceiveAuthenticationSuccess")
        
        context.submitAuthenticationSuccess()
    }

    public func authenticationContext(context: IMFAuthenticationContext!, didReceiveAuthenticationFailure userInfo: [NSObject : AnyObject]!) {
        debugPrint("didReceiveAuthenticationFailure")
        
        context.submitAuthenticationFailure(userInfo)
        
    }
    
}
