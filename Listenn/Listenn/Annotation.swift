//
//  Annotation.swift
//  MapLocationAnimation
//
//  Created by Larry Natalicio on 4/17/16.
//  Copyright © 2016 Larry Natalicio. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    
    // MARK: - Properties
    let coordinate: CLLocationCoordinate2D
    var title: String?
    
    // MARK: - Initializers
    init(coordinate: CLLocationCoordinate2D, title: String?) {
        self.coordinate = coordinate
        self.title = title
    }
}
