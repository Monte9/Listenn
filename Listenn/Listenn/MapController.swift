//
//  MapController.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/3/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController, MKMapViewDelegate {
    
    var isMapView : Bool! = false
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        mapView.delegate = self
        
        if (isMapView != false) {
//            let pinLocation = CLLocationCoordinate2DMake((business.latitude as? Double!)!, (business.longitude as? Double!)!)
//            addAnnotationAtCoordinate(pinLocation, title: business.name!)
//            
//            let centerLocation = CLLocation(latitude: (business.latitude as? Double!)!, longitude: (business.longitude as? Double!)!)
//            goToLocation(centerLocation)
        }
    }
            
        

}
