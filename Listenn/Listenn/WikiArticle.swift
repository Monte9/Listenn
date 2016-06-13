//
//  WikiArticle.swift
//  WikiLocation
//
//  Created by Christian Menschel on 29.06.14.
//  Copyright (c) 2014 enterprise. All rights reserved.
//

import Foundation

public class WikiArticle : NSObject {
    
    //Mark: - Properties
    public var distance:String!
    public var identifier:Int!
    public var latitutde:Double!
    public var longitude:Double!
    public var url:NSURL!
    public var title:String!
    public var intro:String!
    
    //MARK: - Init
    init(json:Dictionary<String,AnyObject>) {
        super.init()
        
        if let title = json["title"] as? NSString {
            self.title = title as String
        }
        
        if let distance = json["dist"] as? NSNumber {
            self.distance = NSString(format: "Distance: %.2f Meter", distance.doubleValue) as String
        }
        if let id = json["pageid"] as? NSNumber {
            self.identifier = id.integerValue
        }
        if let latitutde = json["lat"] as? NSNumber {
            self.latitutde = latitutde.doubleValue
        }
        if let longitude = json["lon"] as? NSNumber {
            self.longitude = longitude.doubleValue
        }
        self.url = NSURL(string: "http://en.wikipedia.org/wiki?curid=\(self.identifier)")
    }
    
    //add intro to the article
    func addIntro (intro: String) {
        self.intro = intro
    }
}