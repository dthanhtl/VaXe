//
//  VaXeMainViewController.swift
//  VaXeTHKM
//
//  Created by Thanh Tran on 11/4/15.
//  Copyright © 2015 vaxe. All rights reserved.
//
import UIKit
import Parse
import MapKit
import SQLite
import PKHUD
import GoogleMobileAds

class VaXeMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate,UIPopoverPresentationControllerDelegate,GMSMapViewDelegate {
    
    @IBOutlet weak var adBanner: GADBannerView!
    @IBOutlet weak var googleMap: GMSMapView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    let regionRadius: CLLocationDistance = 2000
    var allVaXeShops: [VaxeShops] = []
    var listOfAnnotations: [MKAnnotation] = []
    var listOfMarker: [PlaceMarker] = []
    var listOfImages: [String] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var radiusSlider: UISlider!
    
    var vaxePin : PlaceMarker!
    
    var userPoint : PFGeoPoint = PFGeoPoint()
    var userCLLocationPoint : CLLocation = CLLocation()
    var hasData: Bool = false
    var circle: GMSCircle = GMSCircle()
    var radius: Double = 0
    
    let locationManager = CLLocationManager()
    
    var selectedRow: Int = 1988
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ca-app-pub-7749316975500402/3080263771 -- real one
//        ca-app-pub-3940256099942544/2934735716 -- test one
        self.adBanner.adUnitID = "ca-app-pub-7749316975500402/3080263771"
        self.adBanner.rootViewController = self
        self.adBanner.loadRequest(GADRequest())
        
        
        self.radiusSlider.maximumValue = 2000
        self.radiusSlider.minimumValue = 50
        self.radiusSlider.value = 500
        
        self.radiusSlider.setThumbImage(UIImage(named: "slider_thumb_btn"), forState: UIControlState.Normal)
        self.radiusSlider.setThumbImage(UIImage(named: "slider_thumb_btn"), forState: UIControlState.Selected)
        
        self.radiusSlider.setMinimumTrackImage(UIImage(named: "slider_bar")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)), forState: .Normal)

        self.radiusSlider.setMaximumTrackImage(UIImage(named: "slider_bar"), forState: .Normal)
 
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        self.googleMap.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            //5
            self.googleMap.myLocationEnabled = true
            self.googleMap.settings.myLocationButton = true
        }
        
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Đang xác định vị trí của bạn...")
        PKHUD.sharedHUD.show()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                // do something with the new geoPoint
                self.userPoint = geoPoint!
                self.userCLLocationPoint = CLLocation(latitude: self.userPoint.latitude, longitude: self.userPoint.longitude)

                self.circle = GMSCircle(position: self.userCLLocationPoint.coordinate, radius: (Double)(self.radiusSlider.value))
                self.circle.fillColor = UIColor.clearColor()
                self.circle.strokeColor = UIColor.orangeColor()
                self.circle.strokeWidth = 1.0
                self.circle.map = self.googleMap
                
                
                if ((NSUserDefaults.standardUserDefaults().objectForKey("updatedDate") as? Double) == nil){
                    
                    self.getAllData()
                    self.getVaxeShopFromParse()
                }else{
                    self.getVaxeShopFromLocal()
                }
                
                for object: UIView in self.googleMap.subviews{
                    print(object.dynamicType.description())
                    if(object.dynamicType.description() == "GMSUISettingsView"){
                        for sView: UIView in object.subviews{

                            var sCenter: CGPoint = sView.center
                            sCenter.y -= 75
                        }
                    
                    }
                }
                
                
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchNewData:", name:"NewPlaceAdded", object: nil)
        self.fetchNewDataFromParse()
        
        
    }
    
    func fetchNewData(notification: NSNotification){
        //Take Action on Notification
        self.fetchNewDataFromParse()
    }
    
    func getAllData(){
        
        let queryOnserver = PFQuery(className:"Place")
        queryOnserver.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, err: NSError?) -> Void in
            if (err == nil && objects!.count > 0){
                let date = NSDate()

                
                    for object in objects! {
                        
                        let vaxeshop: VaxeShops = object as! VaxeShops

                        vaxeshop.pinInBackground()
                    }

                NSUserDefaults.standardUserDefaults().setObject(date.timeIntervalSince1970, forKey: "updatedDate")
                NSUserDefaults.standardUserDefaults().synchronize()

                
            } else if(err == nil){

            }else{
                
            }
            
        }
        
    }
    
    
    func getVaxeShopFromLocal(){
    
        let query = PFQuery(className:"Place")
        query.whereKey("location", nearGeoPoint: self.userPoint, withinKilometers: (Double)(self.radiusSlider.value / 1000))
        query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, err: NSError?) -> Void in
            
            self.allVaXeShops.removeAll(keepCapacity: false)

            if (err == nil && objects!.count > 0){
                self.googleMap.clear()
                for object in objects! {
                    
                    let vaxeshop: VaxeShops = object as! VaxeShops
                    print(vaxeshop)
                    self.allVaXeShops.append(vaxeshop)
                    
                    let clPoint: CLLocation = CLLocation(latitude: vaxeshop.location.latitude, longitude: vaxeshop.location.longitude)

                    let anno: PlaceMarker = PlaceMarker(cordi: clPoint.coordinate)
                    
                    anno.map = self.googleMap
                    self.listOfMarker.append(anno)
                    
                }
                
                PKHUD.sharedHUD.hide()
                
                self.hasData = true
                
                if(self.allVaXeShops.count >= 4){
                    self.tableViewHeightConstraint.constant = (CGFloat)(3 * 80)
                }else if(self.allVaXeShops.count == 0){
                    self.tableViewHeightConstraint.constant = (CGFloat)(1 * 80)
                }else{
                    self.tableViewHeightConstraint.constant = (CGFloat)(self.allVaXeShops.count * 80)
                }
                
                self.tableView.reloadData()
                
                

            } else if(objects!.count == 0){
                PKHUD.sharedHUD.hide()
                self.googleMap.clear()
                self.hasData = false
                self.tableViewHeightConstraint.constant = (CGFloat)(1 * 120)
                self.tableView.reloadData()
            } else {
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: err?.domain)
                PKHUD.sharedHUD.hide(afterDelay: 1.5)
            }
            self.tableView.reloadData()
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
            self.googleMap.padding = UIEdgeInsets(top: 0, left: 0,
                bottom: self.view.frame.size.height - self.tableView.frame.origin.y, right: 0)
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
            
            
            self.circle = GMSCircle(position: self.userCLLocationPoint.coordinate, radius: (Double)(self.radiusSlider.value))
            
            self.circle.fillColor = UIColor.clearColor()
            self.circle.strokeColor = UIColor.orangeColor()
            self.circle.strokeWidth = 1.0
            self.circle.map = self.googleMap
            
            
            
            
            
            let newPlace = GMSCameraPosition.cameraWithLatitude(self.userCLLocationPoint.coordinate.latitude,
                longitude: self.userCLLocationPoint.coordinate.longitude, zoom: GMSCameraPosition.zoomAtCoordinate(self.userCLLocationPoint.coordinate, forMeters: (Double)(self.radiusSlider.value), perPoints: 150))
            
            self.googleMap.camera = newPlace
        }
    }
    
    func getVaxeShopFromParse(){
        
        
        let query = PFQuery(className:"Place")
        query.whereKey("location", nearGeoPoint: self.userPoint, withinKilometers: (Double)(self.radiusSlider.value / 1000))
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, err: NSError?) -> Void in
            self.allVaXeShops.removeAll(keepCapacity: false)

            if (err == nil && objects!.count > 0){
                
                for object in objects! {
                    
                    let vaxeshop: VaxeShops = object as! VaxeShops
                    self.allVaXeShops.append(vaxeshop)
                    
                    let clPoint: CLLocation = CLLocation(latitude: vaxeshop.location.latitude, longitude: vaxeshop.location.longitude)

                    let anno: PlaceMarker = PlaceMarker(cordi: clPoint.coordinate)
                    
                    anno.map = self.googleMap

                    self.listOfMarker.append(anno)
                    
                }
                PKHUD.sharedHUD.hide()
                self.hasData = true
                
                if(self.allVaXeShops.count >= 4){
                    self.tableViewHeightConstraint.constant = (CGFloat)(3 * 80)
                }else if(self.allVaXeShops.count == 0){
                    self.tableViewHeightConstraint.constant = (CGFloat)(1 * 80)
                }else{
                    self.tableViewHeightConstraint.constant = (CGFloat)(self.allVaXeShops.count * 80)
                }
                
                self.tableView.reloadData()
                
                
                
            } else if(objects!.count == 0){
                PKHUD.sharedHUD.hide()
                self.hasData = false
                self.tableView.reloadData()
            } else {
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: err?.domain)
                PKHUD.sharedHUD.hide(afterDelay: 1.5)
            }
            self.tableView.reloadData()
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
            self.googleMap.padding = UIEdgeInsets(top: 0, left: 0,
                bottom: self.view.frame.size.height - self.tableView.frame.origin.y, right: 0)
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
        }
    
    }
    
    func fetchNewDataFromParse(){
        let queryOnserver = PFQuery(className:"Place")

        if ((NSUserDefaults.standardUserDefaults().objectForKey("updatedDate") as? Double) != nil){
            
            let updateDate: Double = NSUserDefaults.standardUserDefaults().objectForKey("updatedDate") as! Double
        queryOnserver.whereKey("timeInterval", greaterThan: updateDate)
        queryOnserver.findObjectsInBackgroundWithBlock { (var objects: [PFObject]?, err: NSError?) -> Void in
            if (err == nil && objects!.count > 0){
                let date = NSDate()

                objects = objects?.reverse()
                for object in objects! {
                    
                    let vaxeshop: VaxeShops = object as! VaxeShops
                    self.allVaXeShops.append(vaxeshop)

                    vaxeshop.pinInBackground()
                    
                    let clPoint: CLLocation = CLLocation(latitude: vaxeshop.location.latitude, longitude: vaxeshop.location.longitude)

                    let anno: PlaceMarker = PlaceMarker(cordi: clPoint.coordinate)
                    
                    anno.map = self.googleMap
                    self.listOfMarker.append(anno)
                }
                self.hasData = true
                
                PKHUD.sharedHUD.hide()
                if(self.allVaXeShops.count >= 4){
                    self.tableViewHeightConstraint.constant = (CGFloat)(3 * 80)
                }else if(self.allVaXeShops.count == 0){
                    self.tableViewHeightConstraint.constant = (CGFloat)(1 * 80)
                }else{
                    self.tableViewHeightConstraint.constant = (CGFloat)(self.allVaXeShops.count * 80)
                }
                
                
                NSUserDefaults.standardUserDefaults().setObject(date.timeIntervalSince1970, forKey: "updatedDate")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.tableView.reloadData()
                
                
            } else if(err == nil){
                PKHUD.sharedHUD.hide()
            }else{
                print(err)
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: err?.domain)
                PKHUD.sharedHUD.hide(afterDelay: 1.5)
            }
            
        }
        }
        
    }
    
    func getAllFromLocal(){
        let query = PFQuery(className:"Place")
        query.fromLocalDatastore()
        query.whereKey("location", nearGeoPoint: self.userPoint, withinKilometers: (Double)(self.radiusSlider.value / 1000) * 2.5)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, err: NSError?) -> Void in
            
            self.allVaXeShops.removeAll(keepCapacity: false)
            self.listOfAnnotations.removeAll(keepCapacity: false)
            
            if (err == nil && objects!.count > 0){

                for object in objects! {
                    
                    let vaxeshop: VaxeShops = object as! VaxeShops
                    self.allVaXeShops.append(vaxeshop)
                    print(self.allVaXeShops)
                    
                    let clPoint: CLLocation = CLLocation(latitude: vaxeshop.location.latitude, longitude: vaxeshop.location.longitude)
                    let anno: PlaceMarker = PlaceMarker(cordi: clPoint.coordinate)
                    
                    anno.map = self.googleMap
                    self.listOfMarker.append(anno)
                    
                }

                self.hasData = true
                
                if(self.allVaXeShops.count >= 4){
                    self.tableViewHeightConstraint.constant = (CGFloat)(3 * 80)
                }else if(self.allVaXeShops.count == 0){
                    self.tableViewHeightConstraint.constant = (CGFloat)(1 * 80)
                }else{
                    self.tableViewHeightConstraint.constant = (CGFloat)(self.allVaXeShops.count * 80)
                }
                
            } else if(objects!.count == 0){
                self.hasData = false
                self.tableView.reloadData()
            } else {
                print(err)
            }
            self.tableView.reloadData()
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
            self.googleMap.padding = UIEdgeInsets(top: 0, left: 0,
                bottom: self.view.frame.size.height - self.tableView.frame.origin.y, right: 0)
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()


    }
    //MARK: - slider
    
    @IBAction func sliderAction(sender: AnyObject) {

        self.getVaxeShopFromLocal()
        
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.hasData){
            return self.allVaXeShops.count
        }else{
            return 1
        }
        
    }
    
    func  tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.clearColor();

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(hasData){
            if((self.selectedRow) == indexPath.row){
                return 160
            }else{
                return 80
            }
            
        }else{
            return 120
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(hasData){
            if((self.selectedRow) == indexPath.row){
                let cell = tableView.dequeueReusableCellWithIdentifier("placeCellID_WithImages", forIndexPath: indexPath) as! VaXeCell_WithImages
                let vaxeshop = self.allVaXeShops[indexPath.row] as VaxeShops
                
                let address : String
                address = "\(vaxeshop.street), \(vaxeshop.ward), \(vaxeshop.district), \(vaxeshop.city)"
                
                var distance : Double = 0
                distance = self.userPoint.distanceInKilometersTo(vaxeshop.location)
                
                if(distance < 1){
                    distance = distance * 1000
                    distance = self.roundToPlaces(distance, places: 2)
                    cell.lblDistance.text = "\(distance)m"
                }else{
                    distance = self.roundToPlaces(distance, places: 2)
                    cell.lblDistance.text = "\(distance)km"
                }
                cell.lblAddress.text = address
                cell.lblPhone.text = vaxeshop.phone
                cell.listOfPhotos.removeAll(keepCapacity: false)
                cell.listOfPhotos = self.listOfImages
                cell.refresh()
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("placeCellID", forIndexPath: indexPath) as! VaXeCell
                let vaxeshop = self.allVaXeShops[indexPath.row] as VaxeShops
                
                let address : String
                address = "\(vaxeshop.street), \(vaxeshop.ward), \(vaxeshop.district), \(vaxeshop.city)"
                
                var distance : Double = 0
                distance = self.userPoint.distanceInKilometersTo(vaxeshop.location)
                
                if(distance < 1){
                    distance = distance * 1000
                    distance = self.roundToPlaces(distance, places: 2)
                    cell.lblDistance.text = "\(distance)m"
                }else{
                    distance = self.roundToPlaces(distance, places: 2)
                    cell.lblDistance.text = "\(distance)km"
                }
                cell.lblAddress.text = address
                cell.lblPhone.text = vaxeshop.phone
                
                return cell
            }
            
        }else{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("noplaceCellID", forIndexPath: indexPath) as! VaXeNoDataCell
            return cell
        }
        
    }
    
    func roundToPlaces(value:Double, places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.001
        
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        
        self.selectedRow = indexPath.row
        
        if(cell is VaXeCell || cell is VaXeCell_WithImages){
            let vaxeshop = self.allVaXeShops[indexPath.row] as VaxeShops
            
            self.listOfImages.removeAll(keepCapacity: false)
            self.listOfImages = vaxeshop.photos

            print(vaxeshop)
            self.tableView.reloadData()

            self.googleMap.animateToLocation(CLLocationCoordinate2D(latitude: vaxeshop.location.latitude, longitude: vaxeshop.location.longitude))
        }else{
            self.getAllFromLocal()
        }

    }
    
    //MARK: - segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //segue for the popover configuration window
        if segue.identifier == "toSetting" {

            let popoverViewController = segue.destinationViewController 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self

            let popover = popoverViewController.popoverPresentationController
        
            popoverViewController.preferredContentSize = CGSizeMake(500,600)
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRectMake(100,100,0,0)

        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .OverFullScreen
    }

    @IBAction func settingTapped(sender: AnyObject) {
        
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("settingVCID")
        
        popoverContent!.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = popoverContent!.popoverPresentationController
        popoverContent!.preferredContentSize = CGSizeMake(self.view.frame.width - 8,self.view.frame.height - 100)
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRectMake(0,0,0,0)
        popover?.permittedArrowDirections = []

        self.presentViewController(popoverContent!, animated: false, completion: nil)
    }
    
    @IBAction func addTapped(sender: AnyObject) {
        
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("addNewVCID")
        popoverContent!.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = popoverContent!.popoverPresentationController
        popoverContent!.preferredContentSize = CGSizeMake(self.view.frame.width - 8,self.view.frame.height)
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRectMake(0,0,0,0)
        popover?.permittedArrowDirections = []
        
        self.presentViewController(popoverContent!, animated: false, completion: nil)
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        
    }
    
    
    // 6
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            // 7
            print(self.radiusSlider.value)
            self.googleMap.camera = GMSCameraPosition(target: location.coordinate, zoom: 15.5, bearing: 0, viewingAngle: 0)
            
            // 8
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {

        return false
    }
    
    //MARK: - map

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let cView = MKCircleRenderer(overlay: overlay)
            cView.strokeColor = UIColor.orangeColor()
            cView.fillColor = UIColor.clearColor()
            cView.lineWidth = 2.0
            return cView
        }
        
        return MKCircleRenderer()
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        if anView == nil {
            
            let reuseId = "pin"
            let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView = pinView
            anView?.image = UIImage(named: "ic_pin_24dp")
            
            anView!.canShowCallout = false
        }
        else {
            anView!.annotation = annotation
        }
        
        return anView
    }
    
    
}

