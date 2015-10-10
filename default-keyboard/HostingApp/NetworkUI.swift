//
//  NetworkUI.swift
//  TastyImitationKeyboard
//
//  Created by Jingrong (: on 10/10/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkUI:NSObject {
    // Singleton pattern
    class var sharedInstance: NetworkUI {
        struct Static {
            static var instance: NetworkUI?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = NetworkUI()
        }
        
        return Static.instance!
    }
    
    /* Static URLs */
    
    let kBaseUberSandboxURL = "https://sandbox-api.uber.com/"
    let kRequestUber = "/v1/sandbox/requests/" // Requires appending of request_id
    
    /* Functions */
    
    /*
    * @params : requestID
    */
    func sendSandboxUberRequest(params:[String: AnyObject], success: (response: Result<AnyObject>) -> Void, failure: (error: ErrorType?) -> Void) {
        
        let requestID = params["requestID"] as! String
        
        Alamofire.request(.PUT, String(format: "%@%@%@", kBaseUberSandboxURL, kRequestUber, requestID), parameters: params)
            .responseJSON { request, response, result in
                if result.isSuccess {
                    success(response:result)
                } else {
                    failure(error: result.error)
                }
                
        }
    }

}
