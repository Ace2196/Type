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
    
    /* Static Info */
    
    let clientID = CLIENT_ID
    let clientSecret = CLIENT_SECRET
    
    var _scope: String?
    var _token_type: String?
    var _OAuthToken: String?
    var OAuthToken: String? {
        set(val) {
            if val != nil {
                addSessionHeader("Authorization", value: "Authorization: Bearer \(val!)")
                _OAuthToken = val
            } else { // they set it to nil
                removeSessionHeaderIfExists("Authorization")
                _OAuthToken = nil
            }
        } get {
            return _OAuthToken
        }
    }
    
    /* Sessions */
    
    func addSessionHeader(key: String, value: String)
    {
        let manager = Alamofire.Manager.sharedInstance
        if var sessionHeaders = manager.session.configuration.HTTPAdditionalHeaders as? Dictionary<String, String>
        {
            sessionHeaders[key] = value
            manager.session.configuration.HTTPAdditionalHeaders = sessionHeaders
        }
        else
        {
            manager.session.configuration.HTTPAdditionalHeaders = [
                key: value
            ]
        }
    }
    
    func removeSessionHeaderIfExists(key: String) {
        let manager = Alamofire.Manager.sharedInstance
        if var sessionHeaders = manager.session.configuration.HTTPAdditionalHeaders as? Dictionary<String, String> {
            sessionHeaders.removeValueForKey(key)
            manager.session.configuration.HTTPAdditionalHeaders = sessionHeaders
        }
    }
    
    /* OAuth */
    // Checks whether NetworkUI already has OAuth2 Token.
    func hasOAuthToken() -> Bool {
        if self.OAuthToken != nil {
            return true
        }
        return false
    }
    
    // Handlers for the oauth process.
    // Stored as vars since sometimes it requires a round trip to safari which
    // makes it hard to just keep a reference to it.
    var OAuthTokenCompletionHandler: (NSError? -> Void)?
    
    // Get OAuth2Token.
    func startOAuthSandboxUber() {
        let authPath:String = "https://login.uber.com/oauth/v2/authorize?client_id=\(clientID)&response_type=code&scope=request"
        if let authURL:NSURL = NSURL(string: authPath) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "loadingOauthToken")
//            UIApplication.sharedApplication().openURL(authURL) //TODO: IMP LOGIN
        }
    }
    
    // Step two: Receive redirect.
    func processOAuthStep2Response(url: NSURL) {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var code: String?
        // GET ?code=AUTHORIZATION_CODE.
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if (queryItem.name.lowercaseString == "code") {
                    code = queryItem.value
                    break
                }
            }
        }
        
        // If code exists.
        if let receivedCode = code {
            let getTokenPath:String = "https://login.uber.com/oauth/v2/token"
            let tokenParams = [
                "client_id": clientID,
                "client_secret": clientSecret,
                "code": receivedCode,
                "grant_type": "authorization_code",
                "redirect_uri": "TypeApp://oauth/callback",
            ]
            
            // Step three: Get an access token.
            Alamofire.request(.POST, getTokenPath, parameters: tokenParams)
                .responseString { (request, response, results) in
                    if let anError = results.error
                    {
                        if let completionHandler = self.OAuthTokenCompletionHandler
                        {
                            let nOAuthError = NSError(domain: NSURLErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not obtain an OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                            completionHandler(nOAuthError)
                        }
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setBool(false, forKey: "loadingOAuthToken")
                        return
                    }
                    if results.isSuccess {
                        print("succeeded!")
                        let jsond = JSON(results.value!)
                        print ( jsond.rawString() )
                        
                        var _receivedResults = jsond.rawString()!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                        var receivedResults = JSON(data:_receivedResults!)

                        print(receivedResults)
                        self.OAuthToken = receivedResults["access_token"].string
                        print(receivedResults["access_token"].string)
                        self._scope = receivedResults["scope"].string
                        self._token_type = receivedResults["token_type"].string
                    }
                    
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(false, forKey: "loadingOAuthToken")
                    
                    if self.hasOAuthToken()
                    {
                        if let completionHandler = self.OAuthTokenCompletionHandler
                        {
                            completionHandler(nil)
                        }
                    }
                    else
                    {
                        if let completionHandler = self.OAuthTokenCompletionHandler
                        {
                            let nOAuthError = NSError(domain: NSURLErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not obtain an OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                            completionHandler(nOAuthError)
                        }
                    }
            }
        }
        else
        {
            // no code in URL that we launched with
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "loadingOAuthToken")
        }
    }
    
    /* Static URLs */
    
    let kBaseUberSandboxURL = "https://sandbox-api.uber.com/"
    let kSandboxRequestUber = "/v1/sandbox/requests/" // Requires appending of request_id
    let kRequestUber = "/v1/requests/"
    
    /*
    * @params : requestID
    *           expects "proccessing", "accepted", "arriving", "in_progress", "driver_canceled" and "completed"
    */
    func sendSandboxUberRequestStringResponse(params:[String: AnyObject], success: (response: Result<String>) -> Void, failure: (error: ErrorType?) -> Void) {
        let requestID = params["requestID"] as! String
        
        Alamofire.request(.PUT, String(format: "%@%@%@", kBaseUberSandboxURL, kSandboxRequestUber, requestID), parameters: params)
            .responseString { _, _, result in success(response: result) }
        
    }
    
    func getSandboxUberRequestJSONResponse(params:[String: AnyObject], success: (response: Result<AnyObject>) -> Void, failure: (error: ErrorType?) -> Void) {
        let requestID = params["requestID"] as! String
        let extensionID = params["extensionID"] as! String
        
        Alamofire.request(.GET, String(format: "%@%@%@%@", kBaseUberSandboxURL, kRequestUber, requestID, extensionID), parameters: params)
            .responseJSON { request, response, result in
                if result.isSuccess {
                    success(response: result)
                } else {
                    failure(error: result.error)
                }
            }
    }
    
    func postSandboxUberRequestJSONResponse(params:[String: AnyObject], success: (response: Result<AnyObject>) -> Void, failure: (error: ErrorType?) -> Void) {
        let requestID = params["requestID"] as! String
        let extensionID = params["extensionID"] as! String
        
        Alamofire.request(.POST, String(format: "%@%@%@%@", kBaseUberSandboxURL, kRequestUber, requestID, extensionID), parameters: params)
            .responseJSON { request, response, result in
                if result.isSuccess {
                    success(response: result)
                } else {
                    failure(error: result.error)
                }
        }
    }
    
    func deleteSandboxUberRequestStringResponse(params:[String: AnyObject], success: (response: Result<String>) -> Void, failure: (error: ErrorType?) -> Void) {
        let requestID = params["requestID"] as! String
        let extensionID = params["extensionID"] as! String
        
        Alamofire.request(.DELETE, String(format: "%@%@%@%@", kBaseUberSandboxURL, kRequestUber, requestID, extensionID), parameters: params)
                .responseString { _, _, result in success(response: result) }
        
    }
    
    func createSandboxUberRequestJSONResponse(params:[String: AnyObject], success: (response: Result<AnyObject>) -> Void, failure: (error: ErrorType?) -> Void) {
        Alamofire.request(.POST, String(format: "%@%@%@", kBaseUberSandboxURL, kRequestUber), parameters: params)
            .responseJSON { request, response, result in
                if result.isSuccess {
                    success(response: result)
                } else {
                    failure(error: result.error)
                }
                
        }
    }
    
        

}