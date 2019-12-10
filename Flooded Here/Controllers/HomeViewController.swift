//
//  HomeViewController.swift
//  Flooded Here
//
//  Created by Ahmed Afifi on 10/26/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class HomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {

    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var homeScreenLabel: UILabel!
    @IBOutlet weak var addFloodButton: RoundedShadowButton!
    @IBOutlet weak var searchLocationTextField: UITextField!
    
    private var documentRef: DocumentReference!
    
    private(set) var floods = [Flood]()
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var tableView = UITableView()
    
    private lazy var dataBase: Firestore = {
       
        let firestoreDB = Firestore.firestore()
        return firestoreDB
    }()
    
    private lazy var locationManager: CLLocationManager = {
        
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.requestAlwaysAuthorization()
        return manager
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        searchLocationTextField.delegate = self
        
        configureObservers()
        
    }
    
    private func updateAnnotations() {
        
        DispatchQueue.main.async {
            self.floods.forEach {
                self.addFloodToMap($0)
            }
        }
        
    }
    
    // fetching data from firebase database
    private func configureObservers() {
        
        self.dataBase.collection("flooded-regions").addSnapshotListener { [weak self] snapshot, error in
            
            guard let snapshot = snapshot,
                error == nil else {
                    print("Error fetching document")
                    return
            }
            
            snapshot.documentChanges.forEach { diff in
                
                if diff.type == .added {
                    if let flood = Flood(diff.document) {
                        self?.floods.append(flood)
                        self?.updateAnnotations()
                    }
                    
                } else if diff.type == .removed {
                    if let flood = Flood(diff.document) {
                        if let floods = self?.floods {
                            self?.floods = floods.filter { $0.documentId !=
                                flood.documentId }
                            self?.updateAnnotations()
                            
                        }
                    }
                }
            }
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func performSearch() {
        
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchLocationTextField.text
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
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    @IBAction func addFloodButtonPressed() {
        
        saveFloodToFirebase()
        print("add Flood Button Pressed")
        
    }
    
    private func addFloodToMap(_ flood: Flood) {
        
        let annotation = FloodAnotations(flood)
        annotation.coordinate = CLLocationCoordinate2D(latitude: flood.latitude, longitude: flood.longitude)
        annotation.title = "Flooded"
        annotation.subtitle = flood.reportedDate.formatAsString()
        self.mapView.addAnnotation(annotation)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "FloodAnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "FloodAnnotationView")
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "flood-annotation")
            annotationView?.rightCalloutAccessoryView = UIButton.buttonForRightAccessoryView()
            
        }
        
        return annotationView
        
    }
    
    private func saveFloodToFirebase() {
        
        guard let location = self.locationManager.location else {
            return
        }
        
        var flood = Flood(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        self.documentRef = self.dataBase.collection("flooded-regions").addDocument(data: flood.toDictionary()) {
            [weak self] error in
            
            if let error = error {
                print(error)
            } else {
                flood.documentId = self?.documentRef.documentID
                self?.addFloodToMap(flood)
            }
        }
        
    }
    
}

extension HomeViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == searchLocationTextField {
        tableView.frame = CGRect(x: 20, y: view.frame.height, width: view.frame.width - 40, height: view.frame.height - 170)
        tableView.layer.cornerRadius = 10.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tag = 18
        tableView.rowHeight = 60
        
        view.addSubview(tableView)
        animateTableView(shouldShow: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchLocationTextField {
            performSearch()
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        matchingItems = []
        tableView.reloadData()
        self.mapView.showsUserLocation = true
        return true
    }
    
    func animateTableView(shouldShow: Bool) {
        
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: 170, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: 170, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            }) { (finished) in
                for subview in self.view.subviews {
                    if subview.tag == 18 {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
        
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        let mapItem = matchingItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        animateTableView(shouldShow: false)
        print("selected")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if searchLocationTextField.text == "" {
            animateTableView(shouldShow: false)
        }
    }
    
}

