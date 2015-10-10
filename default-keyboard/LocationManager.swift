//
//  AutocompleteManager.swift
//  TastyImitationKeyboard
//
//  Created by Li Jia'En, Nicholette on 10/10/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LocationManager {
    
    var requestManager: Alamofire.Manager?
    var activeRequest: Alamofire.Request?
    
    class var sharedInstance : LocationManager {
        struct Singleton {
            static let instance = LocationManager()
        }
        return Singleton.instance
    }
    
    private init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 15
        self.requestManager = Alamofire.Manager(configuration: config)
    }
    
    func postInputString(input: NSString) {
        let newinput = "391 Burgoyne Street"
        let processed = newinput.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(processed)&key=GOOGLE_API_KEY_HERE"
        makeGetRequest(urlString) { json in
            let results: [String: String] = self.convertJSONResponseToSearchResults(json)
            self.getTest(Array(results.keys))
        }
    }
    
    func getTest(test: [String]) {
        print(test)
    }
    
    private func makeGetRequest(urlString: String, completion: (json: JSON) -> ()) {
        self.activeRequest?.cancel()
        
        let req = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        req.HTTPBody = nil
        req.HTTPMethod = "GET"
        req.addValue("0", forHTTPHeaderField: "Content-Length")
        self.activeRequest = requestManager?.request(req).responseJSON { (req, resp, res) in
            if let e = res.error {
                print(e)
            } else {
                completion(json: JSON(res.value!))
            }
        }
    }
    
    func convertJSONResponseToSearchResults(json: JSON) -> [String: String] {
        
        if let predictions = json["predictions"].array {
            var results = ["":""]
            for prediction in predictions {
                results[prediction["description"].string!] = prediction["place_id"].string!
            }
            return results
        }
        return ["":""]
    }
    
}