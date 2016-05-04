//
//  ListController.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/3/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation

class ListController: UIViewController, UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //instance of the wikimanager to make request to the API
    let wikiManager = WikiManager();
    
    // store wiki articles
    var queriedArticles: [WikiArticle]?
    
    // text-to-speech code
    let speechSynthesizer = AVSpeechSynthesizer()
    var rate: Float!
    var pitch: Float!
    var volume: Float!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if !loadSettings() {
            registerDefaultSettings()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        wikiManager.requestResource(
            37.8199, longitude: -122.4783) { (gotEmArticles) in
                self.queriedArticles = gotEmArticles
                self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queriedArticles?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell", forIndexPath: indexPath) as! ArticleCell
        
        cell.buttonDelegate = self
        
        cell.titleLabel.text = queriedArticles![indexPath.row].title
        cell.distanceLabel.text = queriedArticles![indexPath.row].distance
        cell.setSelected(false, animated: true)
        
        return cell
    }

    //delegate methods for the Article Cell
    func playSoundButtonClicked (articleCell: ArticleCell!) {
        let speechUtterance = AVSpeechUtterance(string: articleCell.titleLabel.text!)
        speechUtterance.rate = rate
        speechUtterance.pitchMultiplier = pitch
        speechUtterance.volume = volume
        
        speechSynthesizer.speakUtterance(speechUtterance)
    }
    
    func registerDefaultSettings() {
        rate = AVSpeechUtteranceDefaultSpeechRate
        pitch = 1.0
        volume = 1.0
        
        let defaultSpeechSettings: Dictionary<String, AnyObject> = ["rate": rate, "pitch": pitch, "volume": volume]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultSpeechSettings)
    }
    
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
    
    func getInfoButtonClicked (articleCell: ArticleCell!) {
        let index = tableView.indexPathForCell(articleCell)
        
        print(index)
        let infoUrl = queriedArticles![(index?.row)!].url
        
        UIApplication.sharedApplication().openURL(infoUrl)
    }

}
