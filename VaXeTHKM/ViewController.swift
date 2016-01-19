//
//  ViewController.swift
//  VaXeTHKM
//
//  Created by Thanh Tran on 10/29/15.
//  Copyright © 2015 vaxe. All rights reserved.
//

import UIKit
import MapKit
import Parse
class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    

    @IBOutlet weak var lblLoading: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let query = PFQuery(className:"Place")
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, err: NSError?) -> Void in
            
            self.lblLoading.hidden = true
            if err == nil {
                for object in objects! {
                    // Do something
                    print(object)
                }
            } else {
                print(err)
            }
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

