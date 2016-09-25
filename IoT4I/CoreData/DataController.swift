//
//  DataController.swift
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

import Foundation
import CoreData

public class DataController:NSObject {
    
    private let recursiveLock = NSRecursiveLock()
    
    private var _mainContext:NSManagedObjectContext!
    public var mainContext:NSManagedObjectContext  {
        
        self.recursiveLock.lock()
        if self._mainContext == nil {
            let coordinator = self.mainPersistentStoreCoordinator
            //MainQueueConcurrencyType -  is specifically for use with your application interface and can only be used on the main queue of an application.
            self._mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            self._mainContext.persistentStoreCoordinator = coordinator
            self._mainContext.undoManager = nil
        }
        self.recursiveLock.unlock()
        return self._mainContext
    }
    
    private var _writerContext:NSManagedObjectContext!
    public var writerContext:NSManagedObjectContext  {
        self.recursiveLock.lock()
        if self._writerContext == nil {
            let coordinator = self.writerPersistentStoreCoordinator
            //PrivateQueueConcurrencyType -  managed object context’s parent store is a persistent store coordinator.
            self._writerContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            self._writerContext.persistentStoreCoordinator = coordinator
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataController.contextChanged(_:)), name: NSManagedObjectContextDidSaveNotification, object: self._writerContext)
          self.recursiveLock.unlock()
        }
        
        return self._writerContext
    }
    
    private var _writerPersistentStoreCoordinator:NSPersistentStoreCoordinator!
    public var writerPersistentStoreCoordinator:NSPersistentStoreCoordinator {
        
        self.recursiveLock.lock()
        if self._writerPersistentStoreCoordinator == nil {
            self._writerPersistentStoreCoordinator = self.createPersistentStoreCoordinator()
        }
        self.recursiveLock.unlock()
        
        return self._writerPersistentStoreCoordinator
        
    }
    
    private var _mainPersistentStoreCoordinator:NSPersistentStoreCoordinator!
    public var mainPersistentStoreCoordinator:NSPersistentStoreCoordinator {
        
        self.recursiveLock.lock()
        if self._mainPersistentStoreCoordinator == nil {
            self._mainPersistentStoreCoordinator = self.createPersistentStoreCoordinator()
        }
        self.recursiveLock.unlock()
        
        return self._mainPersistentStoreCoordinator
        
    }
    
    private func createPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        
        let dir = NSString(string:Utils.applicationLibraryDirectory.path!).stringByAppendingPathComponent("database")

        let exists = NSFileManager.defaultManager().fileExistsAtPath(dir)
        
        if !exists {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("createDirectoryAtPath ERROR - \(error)")
            }
            Utils.setResourceAttributeExcludedFromBackupKeyToPath(dir)
        }
        
        let storeUrl = Utils.applicationLibraryDirectory.URLByAppendingPathComponent("database/IoT4IDataBase.sqlite")
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!)
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            fatalError("addPersistentStoreWithType ERROR - \(error)")
        }
        
        return coordinator;
        
    }
    
    public func removeStore() {
        let dir = NSString(string:Utils.applicationLibraryDirectory.path!).stringByAppendingPathComponent("database")
        if NSFileManager.defaultManager().fileExistsAtPath(dir) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(dir)
            } catch {
                debugPrint("Store is unavailable, maybe it is the app first run, can continue")
            }
        }
        
        self.recursiveLock.lock()
        self._mainContext = nil
        self._writerContext = nil
        self._writerPersistentStoreCoordinator = nil
        self.recursiveLock.unlock()
        
    }
    
    func contextChanged(notification:NSNotification) {
        dispatch_async(dispatch_get_main_queue()){
            if notification.object as! NSManagedObjectContext != self.mainContext {
                self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
                
            }
        }
    }
    
    
}

