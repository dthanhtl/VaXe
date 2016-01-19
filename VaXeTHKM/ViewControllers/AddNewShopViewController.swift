//
//  AddNewShopViewController.swift
//  VaXeTHKM
//
//  Created by Thanh Tran on 12/22/15.
//  Copyright © 2015 vaxe. All rights reserved.
//

import UIKit
import SQLite
import MapKit
import Parse
import PKHUD
import Alamofire

class AddNewShopViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate ,GMSMapViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate{

    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfDistrict: UITextField!
    @IBOutlet weak var tfWard: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnAddPhoto: UIButton!
    
    @IBOutlet weak var viewPhone: UIView!
    
    @IBOutlet weak var topConstraintOfAddButton: NSLayoutConstraint!
    
    @IBOutlet weak var googleMap: GMSMapView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var viewNote: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    var listOfAnnotations: [MKAnnotation] = []
    var listOfPhotosName: Array<String> = []
    var listOfPhotos: Array<UIImage> = []
    
    // map
    var userPoint : PFGeoPoint = PFGeoPoint()
    var userCLLocationPoint : CLLocation = CLLocation()
    let locationManager = CLLocationManager()
    var chosenCLLocationPoint : PFGeoPoint = PFGeoPoint()
    var cities: Array<NSDictionary> = []
    var currentCity: String = ""
    
    var district: Array<NSDictionary> = []
    var currentDistrict: String = ""
    
    var wards: Array<NSDictionary> = []
    var currentWards: String = ""
    

    
    var isKBUp: Bool = false
    var tap = UITapGestureRecognizer()
    
    var hasCities: Bool = false
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    override func awakeFromNib() {
        self.view.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.view.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.view.layer.shadowOpacity = 0.5
        self.view.layer.shadowRadius = 1
        self.view.clipsToBounds = true
        self.view.layer.masksToBounds = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.layer.cornerRadius = 4.0
        self.scrollView.clipsToBounds = true
        self.scrollView.layer.masksToBounds = true
        
        self.containerView.layer.cornerRadius = 4.0
        self.containerView.clipsToBounds = true
        self.containerView.layer.masksToBounds = true

        
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
            self.googleMap.settings.myLocationButton = false
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dismissTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(false) { () -> Void in
            
        }
        
    }
    
    func uploadImage(){
    
        for (var i:Int = 0 ; i < self.listOfPhotos.count ; i++){
            
            let image: UIImage = self.listOfPhotos[i]
            let imageData = UIImagePNGRepresentation(image)

            let imageName: String = self.listOfPhotosName[i]
            
            let base64String = imageData!.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
            
            var requestURL: String = ""
            var params: NSDictionary = NSDictionary()
            requestURL = "http://104.155.199.97/imgupload/upload_image.php"
            params = ["image" : base64String, "filename": self.listOfPhotosName[i] ]

            Alamofire.upload(
                .POST,
                requestURL,
                multipartFormData: { multipartFormData in
                
                    multipartFormData.appendBodyPart(data: base64String.dataUsingEncoding(NSUTF8StringEncoding)! , name: "image")
                    multipartFormData.appendBodyPart(data: imageName.dataUsingEncoding(NSUTF8StringEncoding)! , name: "filename")
    
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            
                            debugPrint(response)
                            
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                        
                        
                    }
                }
            )
        }

        
    
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        
        if((PFUser.currentUser()  != nil)){

            self.uploadImage()
            
            let vaxeShop = VaxeShops()
            vaxeShop.city = self.tfCity.text!
            vaxeShop.district = self.tfDistrict.text!
            vaxeShop.ward = self.tfWard.text!
            vaxeShop.photos = self.listOfPhotosName
            vaxeShop.street = self.tfAddress.text!
            vaxeShop.location = self.chosenCLLocationPoint
            vaxeShop.timeInterval = NSDate().timeIntervalSince1970
            vaxeShop.phone = self.tfPhone.text!
            vaxeShop.note = self.tfNote.text!
            vaxeShop.saveInBackgroundWithBlock({ (result, err) -> Void in
                if(result){

                    NSNotificationCenter.defaultCenter().postNotificationName("NewPlaceAdded", object: nil)
                    self.dismissViewControllerAnimated(false) { () -> Void in
                        
                    }
                }
                
            })
            
        }else{
            
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Login đi mấy chế!")
            PKHUD.sharedHUD.show()
            
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
            
        }
    }
    
    
    @IBAction func chooseCity(sender: AnyObject) {
        
            do {
                
                let path = NSBundle.mainBundle().pathForResource("vietnam", ofType: "sqlite")!
                
                let db = try Connection(path, readonly: true)
                
                let alert = UIAlertController(title: "Vá Xe", message: "Chọn Thành Phố / Tỉnh", preferredStyle: .ActionSheet)
                
                let imageView = UIImageView(frame: CGRectMake(8, 12, 40, 40))
                imageView.image = UIImage(named: "PT_logo_square")
                imageView.contentMode = .ScaleAspectFit
                
                alert.view.addSubview(imageView)
                
                for row in try db.prepare("SELECT provinceid, name, type FROM province ORDER BY type ASC") {
                    
                    let rowID: String = row[0] as! String
                    let rowName: String = row[1] as! String
                    let rowType: String = row[2] as! String
                    let cityName: String = "\(rowType) \(rowName)"

                    alert.addAction(UIAlertAction(title: cityName, style: .Default, handler: { (action: UIAlertAction!) -> Void in
                        //                    self.lblKieuNau.text = kieunau
                        self.currentCity = rowID
                        self.tfCity.text = cityName
                        
                        self.validateInputs()
                    }))
                }
                
                self.hasCities = true
                
                alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            } catch {
                self.hasCities = false
                print(error)
            }
        
    }

    @IBAction func chooseDistrict(sender: AnyObject) {
        
        if(self.currentCity != ""){
            do {
                
                let path = NSBundle.mainBundle().pathForResource("vietnam", ofType: "sqlite")!
                
                let db = try Connection(path, readonly: true)
                
                let alert = UIAlertController(title: "Vá Xe", message: "Chọn Thành Quận / Huyện", preferredStyle: .ActionSheet)
                
                let imageView = UIImageView(frame: CGRectMake(8, 12, 40, 40))
                imageView.image = UIImage(named: "PT_logo_square")
                imageView.contentMode = .ScaleAspectFit
                alert.view.addSubview(imageView)
                
                for row in try db.prepare("SELECT districtid, name, type FROM district WHERE provinceid='\(self.currentCity)' ORDER BY type DESC") {
                    
                    let rowID: String = row[0] as! String
                    let rowName: String = row[1] as! String
                    let rowType: String = row[2] as! String
                    let cityName: String = "\(rowType) \(rowName)"
                    
                    alert.addAction(UIAlertAction(title: cityName, style: .Default, handler: { (action: UIAlertAction!) -> Void in
                        self.currentDistrict = rowID
                        self.tfDistrict.text = cityName
                        self.validateInputs()
                    }))
                }
                
                self.hasCities = true
                
                alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            } catch {
                self.hasCities = false
                print(error)
            }
        }else{
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Chọn Thành Phố/Tỉnh đi")
            PKHUD.sharedHUD.show()
            
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
        }
        
        
        
    }
    
    @IBAction func chooseWard(sender: AnyObject) {
        
        if(self.currentDistrict != ""){
            do {
                
                let path = NSBundle.mainBundle().pathForResource("vietnam", ofType: "sqlite")!
                
                let db = try Connection(path, readonly: true)
                
                let alert = UIAlertController(title: "Vá Xe", message: "Chọn Thành Phường / Xã", preferredStyle: .ActionSheet)
                
                let imageView = UIImageView(frame: CGRectMake(8, 12, 40, 40))
                imageView.image = UIImage(named: "PT_logo_square")
                imageView.contentMode = .ScaleAspectFit
                alert.view.addSubview(imageView)
                
                for row in try db.prepare("SELECT wardid, name, type FROM ward WHERE districtid='\(self.currentDistrict)' ORDER BY type DESC") {
                    
                    let rowID: String = row[0] as! String
                    let rowName: String = row[1] as! String
                    let rowType: String = row[2] as! String
                    let cityName: String = "\(rowType) \(rowName)"
                    
                    alert.addAction(UIAlertAction(title: cityName, style: .Default, handler: { (action: UIAlertAction!) -> Void in
                        self.currentWards = rowID
                        self.tfWard.text = cityName
                        self.validateInputs()
                    }))
                }
                
                self.hasCities = true
                
                alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            } catch {
                self.hasCities = false
                print(error)
            }
        }else{
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Chọn Quận/Huyện đi")
            PKHUD.sharedHUD.show()
            
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
        
        }
        
        
        
    }
    
    
    //MARK: - textfield
    
    func handleTap(){
        
        resetTF()
    }
    
    func resetTF(){
        
        if(self.isKBUp){
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height - 204)
            self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
            
            self.isKBUp = false
        }
        
        self.tfAddress.resignFirstResponder()
        self.tfNote.resignFirstResponder()
        self.tfPhone.resignFirstResponder()
        
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.tap = UITapGestureRecognizer(target: self, action: Selector("handleTap"))
        self.view.addGestureRecognizer(self.tap)
        
        self.isKBUp = true
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 204)
        
        if(textField == self.tfAddress){
            self.scrollView.setContentOffset(CGPointMake(0, self.viewAddress.frame.origin.y - 32), animated: true)
        }else if(textField == self.tfPhone){
            self.scrollView.setContentOffset(CGPointMake(0, self.view.frame.size.height / 4), animated: true)
        }else if(textField == self.tfNote){
            self.scrollView.setContentOffset(CGPointMake(0, self.view.frame.size.height / 4 + 8), animated: true)
        }

        
    }
    func textViewDidEndEditing(textView: UITextView) {
        
        self.view.removeGestureRecognizer(self.tap)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        
        let address: String = "\(self.tfAddress.text!), \(self.tfWard.text!), \(self.tfDistrict.text!), \(self.tfCity.text!), Vietnam"
        print(address)
        if(textField == self.tfAddress){

            
            self.geocodeAddress(address, withCompletionHandler: { (status, success) -> Void in
                if !success {
                    print(status)

                }
                else {
                    let coordinate = CLLocationCoordinate2D(latitude: self.fetchedAddressLatitude, longitude: self.fetchedAddressLongitude)
                    self.reverseGeocodeCoordinate(coordinate)
                    
                    self.validateInputs()
                }
            })

            
            
        }
        
         self.resetTF()
        
        return true
    }
    
    func validateInputs(){
        
        if(self.tfCity.text != "" && self.tfDistrict.text != "" && self.tfWard.text != "" && self.tfAddress.text != ""){
            
            self.btnSave.setTitleColor(UIColor.orangeColor(), forState: .Normal)
            self.btnSave.userInteractionEnabled = true
        }else{
            self.btnSave.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            self.btnSave.userInteractionEnabled = false
        }
    }
    

    // MARK: - GMSMapViewDelegate

        func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
            reverseGeocodeCoordinate(position.target)
            
        }
        
        func mapView(mapView: GMSMapView!, willMove gesture: Bool) {

        }
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void)) {
        
        if let lookupAddress = address {
            
            var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
            geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            let geocodeURL = NSURL(string: geocodeURLString)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
                do {
                    
                    
//                    let error: NSError!
                    let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                    
//                    if (error != nil) {
//                        print(error)
//                        completionHandler(status: "", success: false)
//                    }
//                    else {
                        // Get the response status.
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                            self.lookupAddressResults = allResults[0]
                            
                            // Keep the most important values.
                            self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
                            let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
                            self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                            self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
//                    }
                }catch {
                    self.hasCities = false
                    print(error)
                }
            })
        }
        else {
            completionHandler(status: "No valid address.", success: false)
        }
    }
    
    // 6
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            // 7
            self.googleMap.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // 8
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            //            self.addressLabel.unlock()
            if let address = response?.firstResult() {
                print(address)
                let country: String = address.country
                
                if(country != "Vietnam"){
                    let alert = UIAlertController(title: "Sorry", message: "We only support addresses in Vietnam. Hope to see you somewhere there soon.", preferredStyle: .Alert)
                    
                    let imageView = UIImageView(frame: CGRectMake(8, 12, 40, 40))
                    imageView.image = UIImage(named: "PT_logo_square")
                    imageView.contentMode = .ScaleAspectFit
                    
                    alert.view.addSubview(imageView)
                    

                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
                            //                    self.lblKieuNau.text = kieunau
                        self.dismissViewControllerAnimated(false) { () -> Void in
                            
                        }
                    }))
                    
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }else{
                
                    let lines = address.lines as! [String]
                    let add: String = lines[0]
                    let adds = add.componentsSeparatedByString(",")
                    
                    self.tfAddress.text = adds[0]
                    self.tfWard.text = adds[adds.count - 2]
                    self.tfDistrict.text = adds[adds.count - 1]
                    self.tfCity.text = lines[1]
                    self.googleMap.animateToLocation(coordinate)
                    
                    self.chosenCLLocationPoint = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    self.validateInputs()
                }
                
            }
        }
    }
    
    //MARK: - photo
    
    @IBAction func addPhotoTapped(sender: AnyObject) {
        
        if((PFUser.currentUser()  != nil)){
            let deviceHasCamera: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
            print("In \(__FUNCTION__)")
            
            //Create an alert controller that asks the user what type of image to choose.
            let anActionSheet = UIAlertController(title: "Pick Image Source",
                message: nil,
                preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            //If the current device has a camera, add a "Take a New Picture" button
            var takePicAction: UIAlertAction? = nil
            if deviceHasCamera
            {
                takePicAction = UIAlertAction(
                    title: "Take a New Picture",
                    style: UIAlertActionStyle.Default,
                    handler:
                    {
                        (alert: UIAlertAction!)  in
                        self.pickImageFromSource(
                            ImageSource.Camera,
                            fromButton: sender as! UIButton)
                    }
                )
            }
            
            //Allow the user to selecxt an amage from their photo library
            let selectPicAction = UIAlertAction(
                title:"Select Picture from library",
                style: UIAlertActionStyle.Default,
                handler:
                {
                    (alert: UIAlertAction!)  in
                    self.pickImageFromSource(
                        ImageSource.PhotoLibrary,
                        fromButton: sender as! UIButton)
                }
            )
            
            let cancelAction = UIAlertAction(
                title:"Cancel",
                style: UIAlertActionStyle.Cancel,
                handler:
                {
                    (alert: UIAlertAction!)  in
                    print("User chose cancel button")
                    
                }
            )
            
            
            if let requiredtakePicAction = takePicAction
            {
                anActionSheet.addAction(requiredtakePicAction)
            }
            anActionSheet.addAction(selectPicAction)
            anActionSheet.addAction(cancelAction)
            
            let popover = anActionSheet.popoverPresentationController
            popover?.sourceView = sender as! UIView
            popover?.sourceRect = sender.bounds;
            
            self.presentViewController(anActionSheet, animated: true)
                {
                    //println("In action sheet completion block")
            }
        }else{
            
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Login đi mấy chế!")
            PKHUD.sharedHUD.show()
            
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
            
        }
    }
    enum ImageSource: Int
    {
        case Camera = 1
        case PhotoLibrary
    }
    
    func pickImageFromSource(
        theImageSource: ImageSource,
        fromButton: UIButton)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        switch theImageSource
        {
        case .Camera:
            print("User chose take new pic button")
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front;
        case .PhotoLibrary:
            print("User chose select pic button")
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        }
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad
        {
            if theImageSource == ImageSource.Camera
            {
                self.presentViewController(
                    imagePicker,
                    animated: true)
                    {
                        //println("In image picker completion block")
                }
            }
            else
            {
                self.presentViewController(
                    imagePicker,
                    animated: true)
                    {
                        //println("In image picker completion block")
                }

            }
        }
        else
        {
            self.presentViewController(
                imagePicker,
                animated: true)
                {
                    print("In image picker completion block")
            }
            
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            picker.dismissViewControllerAnimated(true) { () -> Void in
                
                image = self.resizeImage(image, newHeight: image.size.height/4)
                
                let username: String = (PFUser.currentUser()?.username)!
                let timeString: Int = Int(NSDate().timeIntervalSince1970)
                let imageName: String = "\(username)_\(timeString).png"
                
                self.listOfPhotos.append(image)
                self.listOfPhotosName.append(imageName)
                self.collectionView.hidden = false
                self.collectionView.reloadData()
                self.topConstraintOfAddButton.constant = 8
                
            }
        }
        
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listOfPhotos.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let photo: UIImage! = self.listOfPhotos[indexPath.row]

        
        cell.ivPhoto.image = photo
        return cell
    }
    
    
}
