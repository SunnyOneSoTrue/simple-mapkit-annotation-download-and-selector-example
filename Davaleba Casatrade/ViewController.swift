//
//  ViewController.swift
//  Davaleba Casatrade
//
//  Created by USER on 26.11.21.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var mapkit: MKMapView!
    
    let locationManager = CLLocationManager()
    var ConnectionToExternalSourceIsPresent = false
    
    var locations:[CustomAnnonation] = [
        CustomAnnonation(title: "Big Ben", subtitle: "this is Big Ben", latitude: 51.5007, longtitude: 0.1246),
        CustomAnnonation(title: "Buckingham palace", subtitle: "this is Buckingham palace", latitude: 51.5014, longtitude: 0.1419),
        CustomAnnonation(title: "LondonEye", subtitle: "this is LondonEye", latitude: 51.5033, longtitude: 0.1196),
        CustomAnnonation(title: "Tower Bridge", subtitle: "this is Tower Bridge", latitude: 51.5055, longtitude: 0.0754)
    ] // MARK: მივიჩნიოთ რომ ეს მონაცემები გარე წყაროსთან წვდომის შედეგად არის მიღებული და არა hard-coded.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpMapKit()
        checkLocationServices()
        
    }
}


extension ViewController: CLLocationManagerDelegate{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorisation()
        }
        else{
            //TODO: Notify That The location services are turned off
            print("error at line 42")
        }
    }
    
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func checkLocationAuthorisation(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            mapkit.showsUserLocation = true
            if let location = locationManager.location?.coordinate{ //sets the place where the user will be looking at upon opening app
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
                mapkit.setRegion(region, animated: true)
            }
            else{
                let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: 51.5007, longitude: 0.1246), latitudinalMeters: 10000, longitudinalMeters: 10000)
                mapkit.setRegion(region, animated: true)
            }
            break
        case .authorizedAlways:
            break
        case .denied:
            //TODO: show notification instructing how to turn on permissions
            break
        case .restricted:
            //TODO: show an alert alerting them restricted mode is on
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}




extension ViewController:  MKMapViewDelegate{
    
    func setUpMapKit(){
        mapkit.delegate = self
        loadLocations()
    }
    
    func loadLocations(){
        if ConnectionToExternalSourceIsPresent{
            LoadFromNetworkCall()
            for annonation in locations{
                mapkit.addAnnotation(annonation)
            }
        }
        else{
            LoadFromCoreData()
            for annonation in locations{
                mapkit.addAnnotation(annonation)
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // this is our unique identifier for view reuse
        let identifier = "Placemark"

        if annotation is MKUserLocation{
            return nil
        }
        
        // attempt to find a cell we can recycle
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            // we didn't find one; make a new one
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            // allow this to show pop up information
            annotationView?.canShowCallout = true

            // attach an information button to the view
            let button =  UIButton(type: .detailDisclosure)
            button.setTitle(annotation.title!!, for: .normal)
            button.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
            annotationView?.rightCalloutAccessoryView = button
            
        } else {
            // we have a view to reuse, so give it the new annotation
            annotationView?.annotation = annotation
        }

        // whether it's a new view or a recycled one, send it back
        return annotationView
    }
    
    @objc func didTapInfoButton(){
        
        print("Did Enter Info Button Function")
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        saveData(view: view)
        print("ss")
    }
    
    
    func saveData(view: MKAnnotationView){
        //TODO: SAVE CORE DATA
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context)
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        
        newEntity.setValue(view.annotation?.title!, forKey: "title")
        newEntity.setValue(view.annotation?.subtitle!, forKey: "subtitle")
        newEntity.setValue(view.annotation?.coordinate.latitude, forKey: "latitude")
        newEntity.setValue(view.annotation?.coordinate.longitude, forKey: "longitude")
        
        do {
            try context.save()
            print("saved!")
        } catch  {
            print("failed to save to Core Data")
        }
    }
    
    func LoadFromCoreData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Locations")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(fetchRequest)
            for data in result{
                locations.append(CustomAnnonation(title: data.value(forKey: "title") as! String,
                                                  subtitle: data.value(forKey: "subtitle") as! String,
                                                  latitude: data.value(forKey: "latitude") as! Double,
                                                  longtitude: data.value(forKey: "longitude") as! Double))
            }
        } catch{
            print("failed to fetch Core Data")
        }
        
    }
    
    func LoadFromNetworkCall(){}

}

