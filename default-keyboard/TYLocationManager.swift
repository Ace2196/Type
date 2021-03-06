//
//  TYLocationManager.swift
//  TastyImitationKeyboard
//
//  Created by Abdulla Contractor on 10/10/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TYLocationManager {

    var requestManager: Alamofire.Manager?
    var activeRequest: Alamofire.Request?

    var delegate: TYLocationManagerDelegate?

    class var sharedInstance : TYLocationManager {
        struct Singleton {
            static let instance = TYLocationManager()
        }
        return Singleton.instance
    }

    private init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 15
        self.requestManager = Alamofire.Manager(configuration: config)
    }

    func postInputString(input: NSString) {
        let processed = input.stringByReplacingOccurrencesOfString(" ", withString: "+")

        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(processed)&key=\(GappApiKey.key)"
        makeGetRequest(urlString) { json in
            let results: [String: String] = self.convertJSONResponseToSearchResults(json)
            self.updateDelegateSearches(results)

            self.getTest(Array(results.keys))
        }
    }

    func getTest(test: [String]) {
        print(test)
    }

    func postLocationId(id: String) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&key=\(GappApiKey.key)"
        makeGetRequest(urlString) { json in
            let coordinates: [Double] = self.convertJSONResponseToCoordinates(json)
            self.updateDelegateDestinationCoordinates(coordinates)

//            self.getTest(coordinates)
        }
    }

//    func getCurrentLocation() {
//        let urlString = "https://www.googleapis.com/geolocation/v1/geolocate?key=\(GappApiKey.key)"
//
//        self.activeRequest?.cancel()
//
//        let req = NSMutableURLRequest(URL: NSURL(string: urlString)!)
//        var body = ["considerIp" : "true"]
//        var json = JSON(body)
//        var post:NSData = json.rawData()
//        var postLength:NSString = String(post.length)
//
//        req.HTTPBody = json
//        req.HTTPMethod = "GET"
//        req.addValue("0", forHTTPHeaderField: "Content-Length")
//        self.activeRequest = requestManager?.request(req).responseJSON { (req, resp, res) in
//            if let e = res.error {
//                print(e)
//            } else {
//                completion(json: JSON(res.value!))
//            }
//        }
//
//
//    }

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

    func convertJSONResponseToCoordinates(json: JSON) -> [Double] {
        var coordinates = [Double]()
        
        if let lat = json["result"]["geometry"]["location"]["lat"].double {
            coordinates.append(lat)
        } else {
            //Fail silently
            return []
        }
        
        if let lng = json["result"]["geometry"]["location"]["lng"].double {
            coordinates.append(lng)
        } else {
            //Fail silently
            return []
        }

        return coordinates
    }

    private func updateDelegateSearches(searches: [String:String]) {
        delegate?.LocationManager(self, didReceiveSearches: searches)
    }

    private func updateDelegateDestinationCoordinates(coordinates: [Double]) {
        delegate?.LocationManager(self, didReceiveCoordinates: coordinates)
    }
}