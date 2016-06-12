//
//  WikiManager.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/3/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit
import Alamofire

class WikiManager: NSObject {
    
    //Get articles using Lat and Long
    func requestResource(latitude: Double!, longitude: Double!, completion:(([WikiArticle]) -> Void)) {
        let path = "/w/api.php?action=query&format=json&list=geosearch&gscoord=\(latitude)%7C\(longitude)&gsradius=10000"
        
        let fullURLString = kWikilocationBaseURL + path
        let url = NSURL(string: fullURLString)
        
        Alamofire.request(.GET, url!)
            .responseJSON { response in
                let articles = NSMutableOrderedSet()
                
                if let JSON = response.result.value {
                    if let result = JSON["query"] as? NSDictionary {
                        if let jsonarticles = result["geosearch"]! as? NSArray {
                            for item : AnyObject in jsonarticles {
                                let article = WikiArticle(json: item as! Dictionary<String, AnyObject>)
                                articles.addObject(article)
                                self.getArticleIntro("\(item["pageid"] as! Int)") { (intro) in
                                    article.addIntro(intro)
                                }
                            }
                        }
                    }
                }
                completion(articles.array as! [WikiArticle])
        }
    }
    
    //Get article intro using article ID
    func getArticleIntro(id: String!, completion:((String) -> Void)) {
        let path = "/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&pageids=\(id)"
        
        let fullURLString = kWikilocationBaseURL + path
        let url = NSURL(string: fullURLString)
        
        var intro: String!
        
        Alamofire.request(.GET, url!)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let result = JSON["query"] as? NSDictionary {
                        if let pages = result["pages"] as? NSDictionary {
                            if let article = pages[id] as? NSDictionary {
                                intro = article["extract"] as! String
                            }
                        }
                    }
                }
                completion(intro)
        }
    }
}
