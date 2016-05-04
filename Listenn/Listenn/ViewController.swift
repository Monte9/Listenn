//
//  ViewController.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/2/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit

let kWikilocationBaseURL = "https://en.wikipedia.org"

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var mainView: UIView!
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
            navigationItem.title = "Listenn"
        }
        
        //Customize the navigation bar title and color
        navigationItem.title = "Listenn"
        navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    @IBAction func searchButtonClicked(sender: AnyObject) {
        searchBarDisplay = !searchBarDisplay
        
        if (searchBarDisplay != true) {
            //Hide the search bar
            navigationItem.titleView = nil
            navigationItem.title = "Listenn"
            //Get the search text and make the search field empty
            searchedText = searchBar.text
            if searchedText != "" {
                searchBar.text = ""
                print("Entered search location: \(searchedText)")
                print("Perform segue/ reload the view here")
            }
        } else {
            navigationItem.titleView = searchBar
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBarDisplay = !searchBarDisplay
        //Hide the search bar
        navigationItem.titleView = nil
        navigationItem.title = "Listenn"
        //Get the search text and make the search field empty
        searchedText = searchBar.text
        if searchedText != "" {
            searchBar.text = ""
            print("Entered search location: \(searchedText)")
            print("Perform segue/ reload the view here")
        }
        // performSegueWithIdentifier("searchSegue", sender: self)
    }
    
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
    
    @IBAction func makeAPICall(sender: AnyObject) {
        print("Implement settings here")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

