//
//  DataController.swift
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

