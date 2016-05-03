//
//  ViewController.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/2/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit
import Alamofire

let kWikilocationBaseURL = "https://en.wikipedia.org"

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //Implement search bar feature
    var searchBar : UISearchBar!
    var searchBarDisplay : Bool! = false
    var searchedText: String?
    
    
    // store wiki articles
    var queriedArticles = [WikiArticle]()
    
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
            detailLabel.text = "Map view under construction"
        case 1:
            detailLabel.text = "List view coming soon"
        default:
            break;
        }
    }
    
    @IBAction func makeAPICall(sender: AnyObject) {
        requestResource { (queriedArticles) in
            for articles in queriedArticles {
                print(articles.title)
            }
        }
        
    }
    func requestResource(completion:(([WikiArticle]) -> Void)) {
        print("Calling API here..")
        
        let path = "/w/api.php?action=query&format=json&list=geosearch&gscoord=37.808153%7C-122.476447&gsradius=10000"
        let fullURLString = kWikilocationBaseURL + path
        let url = NSURL(string: fullURLString)
        
        Alamofire.request(.GET, url!)
            .responseJSON { response in
            var articles = NSMutableOrderedSet()
                
            if let JSON = response.result.value {
                if let result = JSON["query"] as? NSDictionary {
                    if let jsonarticles = result["geosearch"]! as? NSArray {
                        for item : AnyObject in jsonarticles {
                            var article = WikiArticle(json: item as! Dictionary<String, AnyObject>)
                            articles.addObject(article)
                        }
                    }
                }
            }
            completion(articles.array as! [WikiArticle])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

