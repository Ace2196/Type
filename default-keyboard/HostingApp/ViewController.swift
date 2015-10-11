////
////  ViewController.swift
////  TransliteratingKeyboard
////
////  Created by Alexei Baboulevitch on 6/9/14.
////  Copyright (c) 2014 Apple. All rights reserved.
////
//
//import UIKit
//import Alamofire
//import SwiftyJSON
//
//class HostingAppViewController: UIViewController {
//    
//    @IBOutlet var stats: UILabel?
//    var server: NetworkUI?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        server = NetworkUI.sharedInstance
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide"), name: UIKeyboardDidHideNotification, object: nil)
//        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidChangeFrame:"), name: UIKeyboardDidChangeFrameNotification, object: nil)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//    
//    @IBAction func dismiss() {
//        for view in self.view.subviews {
//            if let inputView = view as? UITextField {
//                inputView.resignFirstResponder()
//            }
//        }
//    }
//    
//    // SUCCESS OR FAILURE
//    let mapStatus = ["processing", "accepted", "arriving", "in_progress", "driver_canceled", "completed"]
//    var counterStatus = 0
//    @IBAction func advanceStatusSandboxRequest(sender: UIButton) {
//        if server!.hasOAuthToken() {
//            // Sandbox functionality.
//            let parameters = ["requestID": "test1", "status": mapStatus[counterStatus]]
//            counterStatus += 1
//            counterStatus %= mapStatus.count
//            
//            server!.sendSandboxUberRequestStringResponse(parameters, success: { (response) -> Void in
//                print(response)
//                }) { (error) -> Void in
//                    print(error.debugDescription)
//            }
//        } else {
//            server?.startOAuthSandboxUber()
//        }
//    }
//
//    func createUberWrapper(endLat: CGFloat, endLong: CGFloat) {
//        self.createUberRequest("a1111c8c-c720-46c3-8534-2fcdd730040d", startLat: CGFloat.max, startLong: CGFloat.max, endLat: endLat, endLong: endLong)
//    }
//    
//    //    {
//    //    "request_id": "852b8fdd-4369-4659-9628-e122662ad257",
//    //    "status": "processing",
//    //    "vehicle": null,
//    //    "driver": null,
//    //    "location": null,
//    //    "eta": 5,
//    //    "surge_multiplier": null
//    //    }
//    func createUberRequest(productId: String, startLat: CGFloat, startLong: CGFloat, endLat: CGFloat, endLong: CGFloat) -> [String: AnyObject] {
//        var res = [String:AnyObject]()
//        if server!.hasOAuthToken() {
//            let parameters = [
//                "product_id": productId,
//                "start_latitude": startLat,
//                "start_longitude": startLong,
//                "end_latitude": endLat,
//                "end_longitude": endLong,
//            ]
//    
//            server!.createSandboxUberRequestJSONResponse(parameters as! [String : AnyObject], success: { (response) -> Void in
//                var json = JSON(response.value!)
//                res["request_id"] = json["request_id"].string
//                res["status"] = json["status"].string
//                res["eta"] = json["eta"].int
//                res["surge_multiplier"] = json["surge_multiplier"].float
//
//                }) { (error) -> Void in
//                    print(error.debugDescription)
//
//            }
//        }
//        
//        return res
//    }
//    
////    {
////    "status": "accepted",
////    "driver": {
////    "phone_number": "(555)555-5555",
////    "rating": 5,
////    "picture_url": "https:\/\/d1w2poirtb3as9.cloudfront.net\/img.jpeg",
////    "name": "Bob"
////    },
////    "eta": 4,
////    "location": {
////        "latitude": 37.776033,
////        "longitude": -122.418143,
////        "bearing": 33
////    },
////    "vehicle": {
////        "make": "Bugatti",
////        "model": "Veyron",
////        "license_plate": "I<3Uber",
////        "picture_url": "https:\/\/d1w2poirtb3as9.cloudfront.net\/car.jpeg",
////    },
////    "surge_multiplier":  1.0,
////    "request_id": "b2205127-a334-4df4-b1ba-fc9f28f56c96"
////    }
//    func sendDetailsGetRequest(requestId: String) -> [String: AnyObject] {
//        var res = [String:AnyObject]()
//        if server!.hasOAuthToken() {
//            let parameters = ["requestID": requestId, "extensionID": ""]
//            
//            server!.getSandboxUberRequestJSONResponse(parameters, success: { (response) -> Void in
//                var json = JSON(response.value!)
//                res["request_id"] = json["request_id"].string
//                res["status"] = json["status"].string
//                res["eta"] = json["eta"].int
//                res["surge_multiplier"] = json["surge_multiplier"].float
//                
//                }) { (error) -> Void in
//                    print(error.debugDescription)
//            }
//        }
//        
//        return res
//    }
//    
//    //    {
//    //      "price":{
//    //      "surge_confirmation_href": "https:\/\/api.uber.com\/v1\/surge-confirmations\/7d604f5e",
//    //      "high_estimate": 6,
//    //      "surge_confirmation_id": "7d604f5e",
//    //      "minimum": 5,
//    //      "low_estimate": 5,
//    //      "surge_multiplier": 1.2,
//    //      "display": "$5-6",
//    //      "currency_code": "USD"
//    //    },
//    //      "trip":{
//    //          "distance_unit": "mile",
//    //          "duration_estimate": 9,
//    //          "distance_estimate": 2.1
//    //      },
//    //      "pickup_estimate":2
//    //    }
//    func sendEstimate(productId: String, startLat: CGFloat, startLong: CGFloat, endLat: CGFloat, endLong: CGFloat) -> [String: AnyObject] {
//        var res = [String:AnyObject]()
//        if server!.hasOAuthToken() {
//            let parameters = [
//                "product_id": productId,
//                "start_latitude": startLat,
//                "start_longitude": startLong,
//                "end_latitude": endLat,
//                "end_longitude": endLong,
//            ]
//            
//            server!.postSandboxUberRequestJSONResponse(parameters as! [String : AnyObject], success: { (response) -> Void in
//                var json = JSON(response.value!)
//                res["pickup_estimate"] = json["pickup_estimate"].int
//                res["surge_multiplier"] = json["price"]["surge_multiplier"].float
//                
//                }) { (error) -> Void in
//                    print(error.debugDescription)
//                    
//            }
//        }
//        
//        return res
//    }
//    
//    func sendCancel(requestId: String) -> String {
//        let parameters = ["requestID": requestId]
//        var str = ""
//        
//        server!.sendSandboxUberRequestStringResponse(parameters, success: { (response) -> Void in
//            str = response.value!
//            }) { (error) -> Void in
//                print(error.debugDescription)
//        }
//        
//        return str
//    }
//    
////    {
////    "request_id":"b5512127-a134-4bf4-b1ba-fe9f48f56d9d",
////    "href":"https://trip.uber.com/abc123"
////    }
//    func sendMap(requestId: String) -> [String: AnyObject] {
//        var res = [String:AnyObject]()
//        if server!.hasOAuthToken() {
//            let parameters = ["requestID": requestId, "extensionID": "/map"]
//            
//            server!.getSandboxUberRequestJSONResponse(parameters, success: { (response) -> Void in
//                var json = JSON(response.value!)
//                res["request_id"] = json["request_id"].string
//                res["href"] = json["href"].string
//                }) { (error) -> Void in
//                    print(error.debugDescription)
//            }
//        }
//        return res
//    }
//
//
//    var startTime: NSTimeInterval?
//    var firstHeightTime: NSTimeInterval?
//    var secondHeightTime: NSTimeInterval?
//    var referenceHeight: CGFloat = 216
//    
//    func keyboardWillShow() {
//        if startTime == nil {
//            startTime = CACurrentMediaTime()
//        }
//    }
//    
//    func keyboardDidHide() {
//        startTime = nil
//        firstHeightTime = nil
//        secondHeightTime = nil
//        
//        self.stats?.text = "(Waiting for keyboard...)"
//    }
//    
//    func keyboardDidChangeFrame(notification: NSNotification) {
//        let frameBegin: CGRect! = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
//        let frameEnd: CGRect! = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
//        
//        if frameEnd.height == referenceHeight {
//            if firstHeightTime == nil {
//                firstHeightTime = CACurrentMediaTime()
//                
//                if let startTime = self.startTime {
//                    if let firstHeightTime = self.firstHeightTime {
//                        let formatString = NSString(format: "First: %.2f, Total: %.2f", (firstHeightTime - startTime), (firstHeightTime - startTime))
//                        self.stats?.text = formatString as String
//                    }
//                }
//            }
//        }
//        else if frameEnd.height != 0 {
//            if secondHeightTime == nil {
//                secondHeightTime = CACurrentMediaTime()
//
//                if let startTime = self.startTime {
//                    if let firstHeightTime = self.firstHeightTime {
//                        if let secondHeightTime = self.secondHeightTime {
//                            let formatString = NSString(format: "First: %.2f, Second: %.2f, Total: %.2f", (firstHeightTime - startTime), (secondHeightTime - firstHeightTime), (secondHeightTime - startTime))
//                            self.stats?.text = formatString as String
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
////    @IBOutlet var stats: UILabel?
//////    var server: NetworkUI?
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        
//////        server = NetworkUI.sharedInstance
////
////        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name: UIKeyboardWillShowNotification, object: nil)
////        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide"), name: UIKeyboardDidHideNotification, object: nil)
////        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
////        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidChangeFrame:"), name: UIKeyboardDidChangeFrameNotification, object: nil)
////        
//////        TYLocationManager.sharedInstance.postInputString("here")
////    }
////
////    override func didReceiveMemoryWarning() {
////        super.didReceiveMemoryWarning()
////    }
////    
////    @IBAction func dismiss() {
////        for view in self.view.subviews {
////            if let inputView = view as? UITextField {
////                inputView.resignFirstResponder()
////            }
////        }
////    }
////    @IBAction func bestButtonEver(sender: UIButton) {
////        print(server!.hasOAuthToken())
////        if server!.hasOAuthToken() {
////            let parameters = ["requestID":""]
////            server!.sendSandboxUberRequest(parameters, success: { (response) -> Void in
////                print(response)
////                }) { (error) -> Void in
////                    print ("buang")
////            }
////        } else {
////            server?.startOAuthSandboxUber()
////        }
////        
////    }
////    
////    var startTime: NSTimeInterval?
////    var firstHeightTime: NSTimeInterval?
////    var secondHeightTime: NSTimeInterval?
////    var referenceHeight: CGFloat = 216
////    
////    func keyboardWillShow() {
////        if startTime == nil {
////            startTime = CACurrentMediaTime()
////        }
////    }
////    
////    func keyboardDidHide() {
////        startTime = nil
////        firstHeightTime = nil
////        secondHeightTime = nil
////        
////        self.stats?.text = "(Waiting for keyboard...)"
////    }
////    
////    func keyboardDidChangeFrame(notification: NSNotification) {
////        let frameBegin: CGRect! = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
////        let frameEnd: CGRect! = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
////        
////        if frameEnd.height == referenceHeight {
////            if firstHeightTime == nil {
////                firstHeightTime = CACurrentMediaTime()
////                
////                if let startTime = self.startTime {
////                    if let firstHeightTime = self.firstHeightTime {
////                        let formatString = NSString(format: "First: %.2f, Total: %.2f", (firstHeightTime - startTime), (firstHeightTime - startTime))
////                        self.stats?.text = formatString as String
////                    }
////                }
////            }
////        }
////        else if frameEnd.height != 0 {
////            if secondHeightTime == nil {
////                secondHeightTime = CACurrentMediaTime()
////
////                if let startTime = self.startTime {
////                    if let firstHeightTime = self.firstHeightTime {
////                        if let secondHeightTime = self.secondHeightTime {
////                            let formatString = NSString(format: "First: %.2f, Second: %.2f, Total: %.2f", (firstHeightTime - startTime), (secondHeightTime - firstHeightTime), (secondHeightTime - startTime))
////                            self.stats?.text = formatString as String
////                        }
////                    }
////                }
////            }
////        }
////    }
//
//
