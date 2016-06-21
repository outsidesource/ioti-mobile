//
//  InsuranceService.swift
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
        let requestPath = IMFClient.sharedInstance().backendRoute + "/device/" + (deviceId ?? "")
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
        let requestPath = IMFClient.sharedInstance().backendRoute + "/device/" + (deviceId ?? "X") + "/" + (attributeName ?? "X") + "/" + (attributeValue ?? "X")
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
