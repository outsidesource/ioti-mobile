//
//  UserPreferences.swift
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

struct UserPreferences {

    static var alertSpeak: Bool {
        set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "AlertSpeak")
        NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("AlertSpeak")
        }
    }
    
    static var alreadyAskedForTouchID: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "alreadyAskedForTouchID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("alreadyAskedForTouchID")
        }
    }

    static var username: String? {
        set {
        NSUserDefaults.standardUserDefaults().setObject(newValue,forKey: "usernameMMM")
        NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("usernameMMM")
        }
    }
    
    static var tokenWink: String? {
        set {
        NSUserDefaults.standardUserDefaults().setObject(newValue,forKey: "tokenWinkMMM")
        NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("tokenWinkMMM")
        }
    }
    
}
