//
//  MapViewController.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 1/21/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class MapViewController:  UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var mapView: MKMapView!
    
    var senderScreen = String()
    var job = JobPost()
    var jobType = String()
    var sendJob = [String:Any]()
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backPressed(_ sender: Any) {
        performSegue(withIdentifier: "Back", sender: self)
    }
    let qfGreen = UIColor(colorLiteralRed: 49/255, green: 74/255, blue: 82/255, alpha: 1.0)
    let startAnnotation = MKPointAnnotation()
    let destAnnotation = MKPointAnnotation()
    @IBOutlet weak var directionsCollect: UICollectionView!
    var destLat = CLLocationDegrees()
    var destLong = CLLocationDegrees()
    let locationManager = CLLocationManager()
    var address = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorisation from the User.
       backButton.layer.cornerRadius = 7
        directionsCollect.layer.cornerRadius = 7
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        let geoCoder = CLGeocoder()
        
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            self.destLat = location.coordinate.latitude
            self.destLong = location.coordinate.longitude
            // Use your location
           
            
            print("destLAtself.: \(self.destLat)")
            self.mapView.delegate = self
            self.destAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.destLat, longitude: self.destLong)
            self.mapView.addAnnotation(self.destAnnotation)
            self.startAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.startLat, longitude: self.startLong)
            self.mapView.addAnnotation(self.startAnnotation)
            
        let request = MKDirectionsRequest()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.startLat, longitude: self.startLong), addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.destLat, longitude: self.destLong), addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                
                self.mapView.add(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                for step in route.steps {
                    //use step.distance to change direction
                    self.directionsArray.append(step.instructions)
                    //print(step.instructions)
                }
               self.directionsArray.reverse()
                var tempDirect = self.directionsArray[0]
                self.directionsArray.remove(at: 0)
                self.directionsArray.append(tempDirect)
                self.directionsCollect.delegate = self
                self.directionsCollect.dataSource = self
                print("routes: \(route)")
            }
        }
        }
    }
    
  
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return directionsArray.count
    }
    var jobID = String()
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DirectionCell", for: indexPath) as! DirectionCell
        
        cell.layer.cornerRadius = 10
        //print((workers[indexPath.row].values.first as! [String:Any])["name"] as! String)
        
        cell.directionText.text = directionsArray[indexPath.row]
        cell.countLabel.text = "\(indexPath.row + 1)"
        
        
       
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    
    var directionsArray = [String]()
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        print("herreeeee")
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = qfGreen
        return renderer
    }
    var startLat = CLLocationDegrees()
    var startLong = CLLocationDegrees()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.startLat = locValue.latitude
        self.startLong = locValue.longitude
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? JobLogJobViewController{
            vc.senderScreen = self.senderScreen
            vc.job = self.job
            vc.jobType = self.jobType
            vc.sendJob = self.sendJob
        }
    }
    
}
