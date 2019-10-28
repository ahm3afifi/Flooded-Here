//
//  ViewController.swift
//  Flooded Here
//
//  Created by Ahmed Afifi on 10/26/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var homeLabel: UILabel!
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    private var locationManager: CLLocationManager = {
        
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLHeadingFilterNone
        manager.requestAlwaysAuthorization()
        return manager
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
    }
    
    func performSearch() {
        
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = destinationTextField.Text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if error != nil {
                print(error.debugDescription)
            } else if response!.mapItems.count == 0 {
                print("No Results")
            } else {
                for mapItem in response!.mapItems {
                    self.matchingItems.append(mapItem as MKMapItem)
//                    self.tableView.reloadData()
                }
            }
        }
    }


}

