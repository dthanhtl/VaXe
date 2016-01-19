//
//  VaxeShops.swift
//  VaXeTHKM
//
//  Created by Thanh Tran on 11/4/15.
//  Copyright © 2015 vaxe. All rights reserved.
//

import UIKit
import Parse

class VaxeShops: PFObject, PFSubclassing {
    
    @NSManaged var shopID: String
    @NSManaged var city: String
    @NSManaged var district: String
    @NSManaged var street: String
    @NSManaged var ward: String
    @NSManaged var info: String // descriptions
    @NSManaged var location: PFGeoPoint
    @NSManaged var name: String
    @NSManaged var phone: String
    @NSManaged var images: [String]
    @NSManaged var photos: [String]
    @NSManaged var timeInterval: Double
    @NSManaged var note: String

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Place"
    }
}
