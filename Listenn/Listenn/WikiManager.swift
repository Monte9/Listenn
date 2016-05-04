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
    
    func requestResource(latitude: Double!, longitude: Double!, completion:(([WikiArticle]) -> Void)) {
        print("Calling API here with lat: \(latitude) & long: \(longitude)")
        
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
                            }
                        }
                    }
                }
                print("returning articles: \(articles.count)")
                completion(articles.array as! [WikiArticle])
        }
    }
}
