//
//  VaxePin.swift
//  VaXeTHKM
//
//  Created by Thanh Tran on 11/10/15.
//  Copyright © 2015 vaxe. All rights reserved.
//

import Foundation
import MapKit

class VaxePin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
    }
}