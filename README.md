# IoT for Insurance Mobile Application

IoT for Insurance Starter Application is a Sample App written in Swift

## Overview

```
IoT for Insurance Starter Application establishes a link between internet-of-things devices, insurance companies and insurance holders. The IBM IoT for Insurance Mobile application is a reference 
implementation for a mobile client of the IoT4I Solution. The application allows registering new devices in the system and receiving alerts for these devices
```

```
This IoT for Insurance Starter Application is intended solely for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools and further customized and distributed under the terms and conditions of your licensed Apple developer program.
```

## Requirements

- An IBM® Bluemix® account. A 30-day trial account is free.
- The IoT for Insurance service deployed in Bluemix.
- An iOS 9.0 or higher iPhone mobile device.
- Apple Xcode 7.3 or higher integrated development environment.
- CocoaPods installed on your computer. See the CocoaPods website.
- The parameters that are required to connect the mobile starter app to your instance of the service.


##<a name="cocoaInstall"></a> Install CocoaPods

You need [CocoaPods](http://cocoapods.org) to install IoT4I. To install CocoaPods, run the following command:
```
sudo gem install cocoapods 
```

## Running the sample

The repository comes with a sample, the IoT4I project. To run this sample, you need:

- clone the repository:
```
git clone https://github.com/ibm-watson-iot/ioti-mobile.git
```
- Install the pods
```
pod install
```

## Parameters required - Locating the parameters for your mobile starter app

- To locate the correct values for the parameters that are required in your constants.swift file, as follows:

1) In your Bluemix dashboard, select your IoT for Insurance service to display the console.

2) Click Service Credentials. applicationRoute/applicationId

3) Specify the bluemix service - applicationRoute/applicationId in Constants.swift  (app will not compile without this parameters):

```Swift
let applicationRoute = //PUT APPLICATION ROUTE HERE
let applicationId = //PUT APPLICATION CLIENTID HERE

```

## CocoaPods frameworks used

* [MBProgressHUD](https://cocoapods.org/?q=MBProgressHUD)
* [MQTTClient](https://cocoapods.org/?q=MQTTClient)
* [CocoaLumberjack/Swift](https://cocoapods.org/?q=CocoaLumberjack)
* [UICKeyChainStore](https://cocoapods.org/?q=UICKeyChainStore)
* [Reachability](https://cocoapods.org/?q=Reachability)
* [DZNEmptyDataSet](https://cocoapods.org/?q=DZNEmptyDataSet)
* [IMFCore](https://cocoapods.org/?q=IMFCore)
* [IMFPush](https://cocoapods.org/?q=IMFPush)
* [SWRevealViewController](https://cocoapods.org/?q=SWRevealViewController)
* [UICollectionView+NSFetchedResultsController](https://cocoapods.org/?q=UICollectionView%2BNSFetchedResultsController)

## Documentation references

* [IBM IoT for Insurance](https://console.ng.bluemix.net/docs/services/IotInsurance/index.html)
* [IBM IoT for Insurance Mobile Documentation](https://console.ng.bluemix.net/docs/services/IotInsurance/index.html)

## Useful links

* [IBM Watson IoT](https://internetofthings.ibmcloud.com)
* [IBM Watson Internet of Things](http://www.ibm.com/internet-of-things/)  
* [IBM Watson IoT Platform](http://www.ibm.com/internet-of-things/iot-solutions/watson-iot-platform/)   
* [IBM Watson IoT Platform Developers Community](https://developer.ibm.com/iotplatform/)
* [IBM Bluemix](https://bluemix.net/)  
* [IBM Bluemix Documentation](https://www.ng.bluemix.net/docs/)  
* [IBM Bluemix Developers Community](http://developer.ibm.com/bluemix)  


