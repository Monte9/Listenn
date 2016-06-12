//
//  ListController.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/3/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ListController: UIViewController, UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate, ViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //instance of the wikimanager to make request to the API
    let wikiManager = WikiManager();
    
    // text-to-speech code
    let speechSynthesizer = AVSpeechSynthesizer()
    var rate: Float!
    var pitch: Float!
    var volume: Float!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        //Table view delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        //Text-to-Speech settings
        if !loadSettings() {
            registerDefaultSettings()
        }
    }
    
    // MARK: - Table View Delegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Articles.queriedArticles?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell", forIndexPath: indexPath) as! ArticleCell
        
        cell.buttonDelegate = self
        
        cell.titleLabel.text = Articles.queriedArticles![indexPath.row].title
        cell.distanceLabel.text = Articles.queriedArticles![indexPath.row].distance
        cell.setSelected(false, animated: true)
        
        return cell
    }
    
      func listArticlesFromCurrentLocation(vc: ViewController, latitude: Double, longitude: Double) {
        //request wikipedia articles with touch coordinates
        wikiManager.requestResource(latitude, longitude: longitude, completion: { (gotArticles) in
            Articles.queriedArticles = gotArticles
            self.tableView.reloadData()
        })
    }
    
    //delegate methods for the Article Cell
    func playSoundButtonClicked (articleCell: ArticleCell!) {
        let speechUtterance = AVSpeechUtterance(string: articleCell.titleLabel.text!)
        speechUtterance.rate = rate
        speechUtterance.pitchMultiplier = pitch
        speechUtterance.volume = volume
        
        speechSynthesizer.speakUtterance(speechUtterance)
    }
    
    //Text-to-Speech default settings
    func registerDefaultSettings() {
        rate = AVSpeechUtteranceDefaultSpeechRate
        pitch = 1.0
        volume = 1.0
        
        let defaultSpeechSettings: Dictionary<String, AnyObject> = ["rate": rate, "pitch": pitch, "volume": volume]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultSpeechSettings)
    }
    
    //load Text-to-Speech default settings
    func loadSettings() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let theRate: Float = userDefaults.valueForKey("rate") as? Float {
            rate = theRate
            pitch = userDefaults.valueForKey("pitch") as! Float
            volume = userDefaults.valueForKey("volume") as! Float
            return true
        }
        return false
    }
    
    //show wikipedia article using url
    func getInfoButtonClicked (articleCell: ArticleCell!) {
        let index = tableView.indexPathForCell(articleCell)
        let infoUrl = Articles.queriedArticles![(index?.row)!].url
        
        UIApplication.sharedApplication().openURL(infoUrl)
    }
}
