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
    
    /* Static Info */
    
    let clientID: String = "1234567890"
    let clientSecret: String = "abcdefghijkl"
    
    
    var OAuthToken: String? {
        set {
            if let valueToSave = newValue {
                addSessionHeader("Authorization", value: "token \(valueToSave)")
            }
            else { // they set it to nil
                removeSessionHeaderIfExists("Authorization")
            }
        } get {
            // TODO: implement
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
        if let token = self.OAuthToken {
            return !token.isEmpty
        }
        return false
    }
    
    // Handlers for the oauth process.
    // Stored as vars since sometimes it requires a round trip to safari which
    // makes it hard to just keep a reference to it.
    var OAuthTokenCompletionHandler: (NSError? -> Void)?
    
    // Get OAuth2Token.
    func startOAuthSandboxUber() {
        let authPath:String = "https://login.uber.com/oauth/v2/authorize"
        if let authURL:NSURL = NSURL(string: authPath) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "loadingOauthToken")
            UIApplication.sharedApplication().openURL(authURL)
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
            ]
            
            // Step three: Get an access token.
            Alamofire.request(.POST, getTokenPath, parameters: tokenParams)
                .responseString { (request, response, results) in
                    if let anError = results.error
                    {
                        print(anError)
                        if let completionHandler = self.OAuthTokenCompletionHandler
                        {
                            let nOAuthError = NSError(domain: NSURLErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not obtain an OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                            completionHandler(nOAuthError)
                        }
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setBool(false, forKey: "loadingOAuthToken")
                        return
                    }
                    print(results)
                    if let receivedResults = results {
                        let resultParams:Array<String> = split(receivedResults) {$0 == "&"}
                        for param in resultParams
                        {
                            let resultsSplit = split(param) { $0 == "=" }
                            if (resultsSplit.count == 2)
                            {
                                let key = resultsSplit[0].lowercaseString // access_token, scope, token_type
                                let value = resultsSplit[1]
                                switch key {
                                case "access_token":
                                    self.OAuthToken = value
                                case "scope":
                                    // TODO: Verify scope.
                                    print("SET SCOPE")
                                case "token_type":
                                    // TODO: Verify is Bearer.
                                    print("CHECK IF BEARER")
                                default:
                                    print("got more than I expected from the OAuth token exchange")
                                }
                            }
                        }
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