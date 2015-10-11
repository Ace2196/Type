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
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?input=\(id)&key=\(GappApiKey.key)"
        makeGetRequest(urlString) { json in
            let coordinates: [String] = self.convertJSONResponseToCoordinates(json)
            self.updateDelegateDestinationCoordinates(coordinates)

            self.getTest(coordinates)
        }
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

    func convertJSONResponseToCoordinates(json: JSON) -> [String] {
        var coordinates = [String]()
        coordinates[0] = json["result"]["geometry"]["location"]["lat"].string!
        coordinates[1] = json["result"]["geometry"]["location"]["lng"].string!

        return coordinates
    }

    private func updateDelegateSearches(searches: [String:String]) {
        delegate?.LocationManager(self, didReceiveSearches: searches)
    }

    private func updateDelegateDestinationCoordinates(coordinates: [String]) {
        delegate?.LocationManager(self, didReceiveCoordinates: coordinates)
    }
}