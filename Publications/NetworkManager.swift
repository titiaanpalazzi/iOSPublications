//
//  NetworkManager.swift
//  Publications
//
//  Created by Titiaan Palazzi on 2/3/15.
//  Copyright (c) 2015 Rocky Mountain Institute. All rights reserved.
//

import Foundation

var query = PFQuery(className: "PublicationsLibraryTest")
query.findObjectsInBackgroundWithBlock {
    (objects: [AnyObject]!, error: NSError!) -> Void in
    if error == nil {
        // The find succeeded.
        NSLog("Successfully retrieved \(objects.count) publications.")
        // Do something with the found objects
        for object in objects {
            NSLog("%@", object.objectId)
        }
    } else {
        // Log details of the failure
        NSLog("Error: %@ %@", error, error.userInfo!)
    }
}