//
//  MapViewController.swift
//  Pizza_App
//
//  Created by Toleen Jaradat on 7/27/16.
//  Copyright © 2016 Toleen Jaradat. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var locationView :LocationView!
    @IBOutlet weak var mapView :MKMapView!
    
    var locationManager :CLLocationManager!

    var pizzaPlaces = [PizzaPlace]()
    var logoImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populatePizzaPlaces()
        showPizzaPlacesOnMap()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
    }
    
    private func populatePizzaPlaces(){
        
        let pizzaPlacesAPI = "https://dl.dropboxusercontent.com/u/20116434/locations.json"
        
        guard let url = NSURL(string: pizzaPlacesAPI) else {
            
            fatalError("Invalid URL")
        }
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithURL(url) { (data :NSData?, response :NSURLResponse?, error :NSError?) in
            
            let jsonPizzaPlacesArray = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
            
            
            for item in jsonPizzaPlacesArray {
                
                let pizzaPlace = PizzaPlace()
                pizzaPlace.name = item.valueForKey("name") as! String
                pizzaPlace.photoUrl = item.valueForKey("photoUrl") as! String
                pizzaPlace.latitude = item.valueForKey("latitude") as! CLLocationDegrees
                pizzaPlace.longitude = item.valueForKey("longitude") as! CLLocationDegrees
                
                self.pizzaPlaces.append(pizzaPlace)
                
            }
            
                for pizzaPlace in self.pizzaPlaces {
                
                guard let imageURL = NSURL(string: pizzaPlace.photoUrl) else {
                    fatalError("Invalid URL")
                }
                
                let imageData = NSData(contentsOfURL: imageURL)
                
                let image = UIImage(data: imageData!)
                
                self.logoImages.append(image!)
                
            }

            dispatch_async(dispatch_get_main_queue(), {
                
                self.showPizzaPlacesOnMap()
                
            })
            
            }.resume()
        
        
    }
    
    private func showPizzaPlacesOnMap(){
        
        for pizzaPlace in pizzaPlaces {
            
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.title = pizzaPlace.name
            
            pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: pizzaPlace.latitude, longitude: pizzaPlace.longitude)
            
            self.mapView.addAnnotation(pinAnnotation)
            

        }
        
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        if let annotationView = views.first {
            
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 650, 650)
                    self.mapView.setRegion(region, animated: true)
                    
                }
            }
        }
        
    }

    private func createAccessoryView() -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        view.backgroundColor = UIColor.redColor()
        
        let widthConstraint = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300)
        view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300)
        view.addConstraint(heightConstraint)
        
        return view
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var pizzaAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("PizzaAnnotationView")
        
        if pizzaAnnotationView == nil {
            
            
            pizzaAnnotationView = PizzaAnnotationView(annotation: annotation, reuseIdentifier: "PizzaAnnotationView")
            
        }
        
        pizzaAnnotationView?.canShowCallout = true
        
        pizzaAnnotationView?.detailCalloutAccessoryView = self.createAccessoryView()
        
        pizzaAnnotationView?.detailCalloutAccessoryView = self.locationView
        
        // why the following doesn't work?????
        
        if (annotation.title! == "Location 1") {
            self.locationView.pinImage.image = self.logoImages[0] // need to be fixed
            self.locationView.pinLabel.text = pizzaPlaces[0].name // need to be fixed
            //   pizzaAnnotationView.
            
        }
        if (annotation.title! == "Location 2") {
            self.locationView.pinImage.image = self.logoImages[1] // need to be fixed
            self.locationView.pinLabel.text = pizzaPlaces[1].name // need to be fixed
            
        }
        if (annotation.title! == "Location 3") {
            self.locationView.pinImage.image = self.logoImages[2] // need to be fixed
            self.locationView.pinLabel.text = pizzaPlaces[2].name // need to be fixed
            
        }
        //.......
        


        return pizzaAnnotationView

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    

}
