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

class MapController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, ViewControllerDelegate {
    
    // MARK: - Types
    struct Constants {
        struct MapViewIdentifiers {
            static let sonarAnnotationView = "sonarAnnotationView"
        }
    }
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 3000
    var searchedLocation: CLLocation?
    
    //instance of the wikimanager to make request to the API
    let wikiManager = WikiManager();
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
                
        //drop a pin on long pressing
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleGesture:"))
        longPressGesture.delegate = self
        longPressGesture.minimumPressDuration = 0.5 //user must press for 0.5 seconds
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    func handleGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            let touchPoint: CGPoint = sender.locationInView(mapView)
            let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let pointAnn = MKPointAnnotation()
            pointAnn.coordinate = touchMapCoordinate
            self.addAnnotationAtCoordinate(touchMapCoordinate, title: "Dropped Pin")
            
            //remove previous annotations
            let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
            self.mapView.removeAnnotations( annotationsToRemove )
            
            //request wikipedia articles with touch coordinates
            wikiManager.requestResource(touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude, completion: { (gotArticles) in
                Articles.queriedArticles = gotArticles
                
                //if no articles found show alert message
                if (Articles.queriedArticles?.count == 0) {
                    let alertController = UIAlertController(title: "No landmarks found!", message: "Please try a different location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: false, completion: nil)
                } else {
                    //if articles found then annotated them on map
                    for article in Articles.queriedArticles! {
                        let pinLocation = CLLocationCoordinate2DMake(article.latitutde , article.longitude )
                        self.addAnnotationAtCoordinate(pinLocation, title: article.title)
                    }
                }
            })
        }
    }
    
    //Called from view controller initally
    func mapArticlesFromCurrentLocation(vc: ViewController, latitude: Double, longitude: Double) {
        
        //remove previous annotations
        let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
        self.mapView.removeAnnotations( annotationsToRemove )
        
        //request wikipedia articles with touch coordinates
        wikiManager.requestResource(latitude, longitude: longitude, completion: { (gotArticles) in
            Articles.queriedArticles = gotArticles
            
            //if no articles found show alert message
            if (Articles.queriedArticles?.count == 0) {
                let alertController = UIAlertController(title: "No landmarks found!", message: "Please try a different location.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: false, completion: nil)
            } else {
                //if articles found then annotated them on map
                for article in Articles.queriedArticles! {
                    let pinLocation = CLLocationCoordinate2DMake(article.latitutde , article.longitude )
                    self.addAnnotationAtCoordinate(pinLocation, title: article.title)
                }
            }
        })
    }
    
    //center map on user location
    @IBAction func goToMyLocationButton(sender: AnyObject) {
        // Set initial location for map view.
        let initialLocation = CLLocation(latitude: (LocationService.sharedInstance.lastLocation?.coordinate.latitude)!, longitude: (LocationService.sharedInstance.lastLocation?.coordinate.longitude)!)
        centerMapOnLocation(initialLocation)
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
   
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        // Reuse the annotation if possible.
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.MapViewIdentifiers.sonarAnnotationView)
        
        if annotationView == nil {
            annotationView = SonarAnnotationView(annotation: annotation, reuseIdentifier:Constants.MapViewIdentifiers.sonarAnnotationView)
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
