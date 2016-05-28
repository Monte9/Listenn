//
//  MapController.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/3/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Types
    struct Constants {
        struct MapViewIdentifiers {
            static let sonarAnnotationView = "sonarAnnotationView"
        }
    }
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 3000
    
    var locationManager : CLLocationManager!
    var currentLocation : CLLocation?
    var searchedLocation: CLLocation?
    
    //instance of the wikimanager to make request to the API
    let wikiManager = WikiManager();
    
    // store wiki articles
    var queriedArticles: [WikiArticle]?
    
    // MARK: - View Life Cycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
        
        //drop a pin on long pressing
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleGesture:"))
        longPressGesture.delegate = self
        longPressGesture.minimumPressDuration = 0.5 //user must press for 0.5 seconds
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locations.isEmpty) {
            let myLocation = locations.last
            self.currentLocation = myLocation
        }
    }
    
    @IBAction func goToMyLocationButton(sender: AnyObject) {
        locationManager.startUpdatingLocation()
        print("Got'em")
        
        // Set initial location for map view.
        let initialLocation = CLLocation(latitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!)
        centerMapOnLocation(initialLocation)
    }
    
//    //delegate methods for the Search functionality
//    func plotSearchedLocation(viewController: ViewController) {
//        addAnnotationAtCoordinate(coordinate, title: title)
//        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        centerMapOnLocation(location)
//    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func handleGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            let touchPoint: CGPoint = sender.locationInView(mapView)
            let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let pointAnn = MKPointAnnotation()
            pointAnn.coordinate = touchMapCoordinate
            self.addAnnotationAtCoordinate(touchMapCoordinate, title: "Dropped Pin")
            locationManager.stopUpdatingLocation()
            print("Stop updating current location")
            
            let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
            self.mapView.removeAnnotations( annotationsToRemove )
            
            wikiManager.requestResource(touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude, completion: { (gotArticles) in
                self.queriedArticles = gotArticles
                
                if (self.queriedArticles?.count == 0) {
                    let alertController = UIAlertController(title: "No landmarks found!", message: "Please try a different location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: false, completion: nil)
                }
                
                for article in self.queriedArticles! {
                    let pinLocation = CLLocationCoordinate2DMake(article.latitutde , article.longitude )
                    self.addAnnotationAtCoordinate(pinLocation, title: article.title)
                }
            })
        }
        
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        // Reuse the annotation if possible.
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.MapViewIdentifiers.sonarAnnotationView)
        
        if annotationView == nil {
            annotationView = SonarAnnotationView(annotation: annotation, reuseIdentifier: Constants.MapViewIdentifiers.sonarAnnotationView)
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    // MARK: - Convenience
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    // MARK: - Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
