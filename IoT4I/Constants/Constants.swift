//
//  Constants.swift
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
import JavaScriptCore

//IoT4I API
let applicationRoute = //PUT APPLICATION ROUTE HERE
let applicationId = //PUT APPLICATION CLIENTID HERE

let DEMO_MODE:Bool = true
let APIURL = applicationRoute
var iService:InsuranceService = InsuranceService(backendRoute: applicationRoute, backendGUID: applicationId)
let Insurance_barTintColor = UIColor(red: 11/255, green: 68/255, blue: 100/255, alpha: 1)
let HazardOrange_TintColor = UIColor(red: 240/255, green: 163/255, blue: 21/255, alpha: 1)
let barTintColor = UIColor(red: (46.0/255.0), green: (159.0/255.0), blue: (225.0/255.0), alpha: 1.0)
let HazardRed_TintColor = UIColor.redColor()

let notificationOK: String! = "OK_IDENTIFIER"
let notificationHELP: String! = "HELP_IDENTIFIER"

let kDidHazardsLoad = "com.ibm.DidHazardLoad"

let APIxShieldsPath = "/reg/shields"
let APIxDevicesPath = "/reg/devices"
let APIxPromotionsPath = "/reg/promotions"
let APIxHazardEventsPath = "/reg/hazardEvents"
let kGET = "GET"
let kPost = "POST"
let kDelete = "DELETE"

let applicationRealName = "IoT4I"
var lastDeviceId:String?

var didLoadPromotions = false

let dataController = DataController()

let kWinkConnectionStateChanged = "kWinkConnectionStateChanged"
let kUpdateShieldsTitle = "kUpdateShieldsTitle"
let kReloadPromotionView = "kReloadPromotionView"

let keyChainDomain = "com.ibm.iot4i.secured"

let WINDOW_WIDTH = UIScreen.mainScreen().bounds.width
let WINDOW_HEIGHT = UIScreen.mainScreen().bounds.height
