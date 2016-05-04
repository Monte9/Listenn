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
    
    class var sharedInstance: MapController {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            
            static var instance: MapController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = MapController()
        }
        return Static.instance!
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    var isMapView : Bool! = false
    var locationManager : CLLocationManager!
    var currentLocation : CLLocation?
    
    //instance of the wikimanager to make request to the API
    let wikiManager = WikiManager();
    
    // store wiki articles
    var queriedArticles: [WikiArticle]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locations.isEmpty) {
            let myLocation = locations.last
            self.currentLocation = myLocation
            mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake((myLocation?.coordinate.latitude)!, (myLocation?.coordinate.longitude)!), MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        }
    }

    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
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
                for article in self.queriedArticles! {
                     let pinLocation = CLLocationCoordinate2DMake(article.latitutde , article.longitude )
                     self.addAnnotationAtCoordinate(pinLocation, title: article.title)
                }
            })
        }
        
//            let alertController = UIAlertController(title: "Error!", message: "Unknown error occured. Please try again", preferredStyle: UIAlertControllerStyle.Alert)
//            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alertController, animated: false, completion: nil)
    }
}
