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

//Store state of the speech Uterrance for pause/play functionality
struct TextToSpeech {
    static var pausing: Bool? = false
    static var previousIndex: NSIndexPath = NSIndexPath()
}

class ListController: UIViewController, UITableViewDataSource, UITableViewDelegate, ArticleCellDelegate, ViewControllerDelegate, MapControllerDelegate {
    
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
    
      func listArticlesFromCurrentLocation(latitude: Double, longitude: Double) {
        //request wikipedia articles from user location
        wikiManager.requestResource(latitude, longitude: longitude, completion: { (gotArticles) in
            Articles.queriedArticles = gotArticles
            self.tableView.reloadData()
        })
    }
    
    //delegate methods for the Article Cell
    func playSoundButtonClicked (articleCell: ArticleCell!) {
        let index = tableView.indexPathForCell(articleCell)
        let text = "Landmark. " + Articles.queriedArticles![(index?.row)!].title + ". Introduction. " + Articles.queriedArticles![(index?.row)!].intro

        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = rate
        speechUtterance.pitchMultiplier = pitch
        speechUtterance.volume = volume
        
        //settings for Play/Pause feature of sound
        if (index != TextToSpeech.previousIndex) {
            speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
            speechSynthesizer.speakUtterance(speechUtterance)
            TextToSpeech.pausing = false
            TextToSpeech.previousIndex = index!
        } else if (index == TextToSpeech.previousIndex && TextToSpeech.pausing == false){
            TextToSpeech.pausing = !TextToSpeech.pausing!
            speechSynthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Word)
        } else if (index == TextToSpeech.previousIndex && TextToSpeech.pausing == true){
            TextToSpeech.pausing = !TextToSpeech.pausing!
            speechSynthesizer.continueSpeaking()
        }
    }
    
    func playSoundForMapView(title: String, intro: String) {
        speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        
        let text = "Landmark. " + title + ". Introduction. " + intro
        
        let speechUtterance = AVSpeechUtterance(string: text)
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
