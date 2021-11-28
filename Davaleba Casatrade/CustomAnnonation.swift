//
//  CustomAnnonation.swift
//  Davaleba Casatrade
//
//  Created by USER on 26.11.21.
//

import Foundation
import MapKit

class CustomAnnonation: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, latitude: Double, longtitude: Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        self.title = title
        self.subtitle = subtitle
    }
}
