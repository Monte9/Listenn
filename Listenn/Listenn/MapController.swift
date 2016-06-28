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

var optimizedRadius: CLLocationDistance = 0

protocol MapControllerDelegate: class {
    func playSoundForMapView(title: String, intro: String)
}

class MapController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, ViewControllerDelegate {
    
    // MARK: - Types
    struct Constants {
        struct MapViewIdentifiers {
            static let sonarAnnotationView = "sonarAnnotationView"
        }
    }
    
    //delegate for MapController to play sound for article intro
    var delegate: MapControllerDelegate = listViewController!
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    //Region radius for the mapView
    let regionRadius: CLLocationDistance = 2500
    
    //instance of the wikimanager to make request to the API
    let wikiManager = WikiManager();
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
                
        //drop a pin on map for long press
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleGesture:"))
        longPressGesture.delegate = self
        longPressGesture.minimumPressDuration = 0.5 //user must press for 0.5 seconds
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    //handle gesture for long press (drop pin)
    func handleGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            let touchPoint: CGPoint = sender.locationInView(mapView)
            let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let pointAnn = MKPointAnnotation()
            pointAnn.coordinate = touchMapCoordinate
            self.addAnnotationAtCoordinate(touchMapCoordinate, title: "Dropped Pin")
            
            //remove previous annotations and overlays
            clearMap()
            
            //call listView delegate method to update list articles on dropping pin
            listDelegate?.listArticlesFromCurrentLocation!(touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
            
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
                    //center and draw radius around current location
                    self.centerWithRadius(touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
                }
            })
        }
    }
    
    //delegate method for ViewControllerDelegate
    func mapArticlesFromCurrentLocation(latitude: Double, longitude: Double) {
        
        //remove previous annotations and overlays
        clearMap()
        
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
                //center and draw radius around current location
                self.centerWithRadius(latitude, longitude: longitude)
            }
        })
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
    
    //handle on-touch map annotations - play sound, get directions
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let alertController = UIAlertController(title: view.annotation!.title!, message: view.annotation!.subtitle!, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: "Play sound", style: UIAlertActionStyle.Destructive, handler: { (action) in
            for article in Articles.queriedArticles! {
                if (view.annotation!.title! as? String!) == article.title {
                    self.delegate.playSoundForMapView(article.title, intro: article.intro)
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Get directions", style: UIAlertActionStyle.Default, handler: { (action) in
            let appleMapsURL = "http://maps.apple.com/?q=\(view.annotation!.coordinate.latitude),\(view.annotation!.coordinate.longitude)"
            UIApplication.sharedApplication().openURL(NSURL(string: appleMapsURL)!)
        }))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    //add annotation at given coordinates
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    //center map on user location
    @IBAction func goToMyLocationButton(sender: AnyObject) {
        // Set initial location for map view.
        let initialLocation = CLLocation(latitude: (LocationService.sharedInstance.lastLocation?.coordinate.latitude)!, longitude: (LocationService.sharedInstance.lastLocation?.coordinate.longitude)!)
        centerMapOnLocation(initialLocation)
    }
    
    
    // MARK: - Convenience
    
    //center map from current location and draw radius cirle
    func centerWithRadius(latitude: Double, longitude: Double) {
        // draw circular overlay centered in San Francisco
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let circleOverlay: MKCircle = MKCircle(centerCoordinate: coordinate, radius: optimizedRadius)
        mapView.addOverlay(circleOverlay)
        
        //center map on searched results
        let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
        self.centerMapOnLocation(centerLocation)
    }
    
    //draw overlay with radius
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = UIColor.redColor()
        circleView.lineWidth = 1
        return circleView
    }
    
    //center map on given location
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    //clears the map of annotations and overlays
    func clearMap() {
        let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
        self.mapView.removeAnnotations( annotationsToRemove )
        let overlaysToRemove = self.mapView.overlays
        for overlay in overlaysToRemove {
            self.mapView.removeOverlay(overlay)
        }
        
        //reset the radius
        optimizedRadius = 0
    }
    
    
    // MARK: - Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
