//
//  ViewController.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/2/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit

let kWikilocationBaseURL = "https://en.wikipedia.org"

// store wiki articles - GLOBAL VARIABLE
struct Articles {
    static var queriedArticles: [WikiArticle]?
}

@objc protocol ViewControllerDelegate: class {
    optional func mapArticlesFromCurrentLocation(vc: ViewController, latitude: Double, longitude: Double)
    optional func listArticlesFromCurrentLocation(vc: ViewController, latitude: Double, longitude: Double)
}

class ViewController: UIViewController, UISearchBarDelegate, LocationServiceDelegate {

    @IBOutlet weak var mainView: UIView!
    
    //hold references for mapView and listView delegate methods
    weak var mapDelegate: ViewControllerDelegate?
    weak var listDelegate: ViewControllerDelegate?
    
    //container views for map and list
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var listContainerView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //Implement search bar feature
    var searchBar : UISearchBar!
    var searchBarDisplay : Bool! = false
    var searchedText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create the search bar programatically since you won't be
        // able to drag one onto the navigation bar
        self.searchBar = UISearchBar()
        searchBar.delegate = self
        self.searchBar.sizeToFit()
        searchBar.placeholder = "Enter location"
        if (searchBarDisplay == false) {
            navigationItem.title = "Listnn"
        }
        
        //Customize the navigation bar title and color
        navigationItem.title = "Listnn"
        navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //LocationService delegate
        LocationService.sharedInstance.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        //Start updating user location
        LocationService.sharedInstance.startUpdatingLocation()
    }
    
    // MARK: LocationService Delegate
    func trackingLocation(currentLocation: CLLocation) {
        mapDelegate?.mapArticlesFromCurrentLocation!(self, latitude: (LocationService.sharedInstance.lastLocation?.coordinate.latitude)! , longitude: (LocationService.sharedInstance.lastLocation?.coordinate.longitude)!)
        listDelegate?.listArticlesFromCurrentLocation!(self, latitude: (LocationService.sharedInstance.lastLocation?.coordinate.latitude)! , longitude: (LocationService.sharedInstance.lastLocation?.coordinate.longitude)!)
        
        //Stop updating user location
        LocationService.sharedInstance.stopUpdatingLocation()
    }
    
    // MARK: LocationService Delegate
    func trackingLocationDidFailWithError(error: NSError) {
        print("tracing Location Error : \(error.description)")
    }
    
    //Used when the search button clicked to search
    @IBAction func searchButtonClicked(sender: AnyObject) {
        searchBarDisplay = !searchBarDisplay
        
        if (searchBarDisplay != true) {
            //Hide the search bar
            navigationItem.titleView = nil
            navigationItem.title = "Listnn"
            
            //Get the search text and make the search field empty
            searchedText = searchBar.text
            if searchedText != "" {
                searchBar.text = ""
                print("Searched using search button")
                searchWithLocation(searchedText!)
            }
        } else {
            navigationItem.titleView = searchBar
        }
    }
    
    //Used when enter key pressed on search bar
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBarDisplay = !searchBarDisplay
        
        //Hide the search bar
        navigationItem.titleView = nil
        navigationItem.title = "Listnn"
        
        //Get the search text and make the search field empty
        searchedText = searchBar.text
        if searchedText != "" {
            searchBar.text = ""
            print("Searched using enter key on search bar")
            searchWithLocation(searchedText!)
        }
    }
    
    //Gets the coordinates of the searched location
    func searchWithLocation(location: String) {
        print("Using the GeoCoding API to get the latitude and longitude of the search location: \(location)")
        SVGeocoder.geocode(location) { (placemarks: [AnyObject]!, urlResponse: NSHTTPURLResponse!, error: NSError!) in
            
            if error == nil {
                self.mapDelegate?.mapArticlesFromCurrentLocation!(self, latitude: placemarks[0].coordinate.latitude , longitude: placemarks[0].coordinate.longitude)
                self.listDelegate?.listArticlesFromCurrentLocation!(self, latitude: placemarks[0].coordinate.latitude , longitude: placemarks[0].coordinate.longitude)
            } else {
                let alertController = UIAlertController(title: "Unable to find location!", message: "Please try a different search string.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: false, completion: nil)
            }

        }
    }
    
    //used to toggle between map and list view (segmented controller)
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mapContainerView.alpha = 1.0
            listContainerView.alpha = 0.0
        case 1:
            mapContainerView.alpha = 0.0
            listContainerView.alpha = 1.0
        default:
            break;
        }
    }
    
    //implement settings view
    @IBAction func appSettings(sender: AnyObject) {
        print("Implement settings here")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "MapViewSegue" {
                let mapController = segue.destinationViewController as! MapController
                mapDelegate = mapController
            } else if identifier == "ListViewSegue" {
                let listController = segue.destinationViewController as! ListController
                listDelegate = listController
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

