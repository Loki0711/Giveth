//
//  RestaurantDetailsViewController.swift
//  Giveth
//
//  Created by Jack on 25/01/22.
//

import UIKit
import MapKit
import CoreLocation

class RestaurantDetailsViewController: UIViewController {
    @IBOutlet weak var resNameLabel: UILabel!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var uNameLabel: UILabel!
    @IBOutlet weak var uMobileLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var resTableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var desText: UILabel!
    
    var entity : Entity? = nil
    private let geocoder = CLGeocoder()
    var foodItemCount = 0
    
    var namesArry: [String] = []
    var valuesArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height + 200)
        self.displayResDetails()
        
    }
    
    func displayResDetails(){
        
        resNameLabel.text = entity?.name
        desText.text = entity?.desc
        uNameLabel.text = entity?.deliveryPartnerInfo![0]
        uMobileLabel.text = entity?.deliveryPartnerInfo![1]
        foodItemsList()
        image1.image = UIImage(named: entity!.images![0])
        image2.image = UIImage(named: entity!.images![1])
        getLocation()
    }
    
    func foodItemsList(){

        let keys = entity?.foodItems?.map{$0.key}
        let values = entity?.foodItems?.map {$0.value}
        keys?.indices.forEach({ index in
            namesArry.append((keys?[index])!)
            valuesArray.append("\((values?[index])!)")
        })
        
        foodItemCount =  keys!.count
        self.resTableView.dataSource = self
        self.resTableView.delegate = self
        self.resTableView.reloadData()
   
      
    }
    
    
    private func getLocation(){
        
        let street = entity?.address![0]
        let city = entity?.address![1]
        let country = entity?.address![2]
    
        let postalAddress = "\(country ?? ""), \(city ?? ""), \(street ?? "")"
        print("Postal Address \(postalAddress)")
        
        //self.getLocation(address: postalAddress)
        
        
        self.geocoder.geocodeAddressString(postalAddress, completionHandler: { (placemark, error) in
            self.processGeoResponse(placemarks: placemark, error: error)
        })
    }
    
    private func processGeoResponse(placemarks: [CLPlacemark]?, error: Error?){
        if error != nil{
            print("Unable to get location coordinates")
        }else{
            var obtainedLocation : CLLocation?
            
            if let placemark = placemarks, placemarks!.count > 0{
                obtainedLocation = placemark.first?.location
            }
            
            if obtainedLocation != nil{
                self.displayLocationOnMap(location: obtainedLocation!.coordinate)
                print("LOCATION: \(obtainedLocation?.coordinate.latitude) : \(obtainedLocation?.coordinate.longitude)")
            }else{
                print("No Coordinates Found")
            }
        }
    }
    

    func displayLocationOnMap(location : CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.mapView?.setRegion(region, animated: true)
        
        //display annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "You'r here"
        self.mapView?.addAnnotation(annotation)
    }


}


extension RestaurantDetailsViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "res_cell", for: indexPath) as! ResTableViewCell
        cell.foodNameLabel.text = namesArry[indexPath.row]
        cell.foodPrice.text = valuesArray[indexPath.row]
        return cell
    }
    
}
