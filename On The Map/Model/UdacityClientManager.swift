//
//  UdacityClientManager.swift
//  On The Map
//
//  Created by Yan Zverev on 7/19/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class UdacityClientManager: NSObject
{
    //MARK: Initilization
    static let sharedInstance = UdacityClientManager()
    
    var udacitySessionID: String?
    var udacityUserID: String?
    
    var session = NSURLSession.sharedSession()
    
    override init()
    {
        super.init()
    }
    
    //MARK: appdelegate functions
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    
    
    
    
    //MARK: Login with udacity
    
    func isLoggedIn() -> Bool
    {
        return udacitySessionID != nil && udacityUserID != nil
    }
    
    func logoutFromUdacity(completionHanlderForLogout: (success: Bool?, error: NSError?) -> Void) -> Void
    {
        taskForDeleteMethod(Methods.Session) { (result, error) in
            guard(error == nil) else {
                completionHanlderForLogout(success: false, error: error)
                return
            }
            
            self.udacityUserID = nil;
            self.udacitySessionID = nil;
            completionHanlderForLogout(success: true, error: nil);
        }
    }

    func authenticateWithUdacity(userName: String?, password: String?, completionHandlerForAuthentication: (success: Bool?, error: NSError?) -> Void) -> Void {
        
        if userName != nil && password != nil {
           let jsonBody = "{\"\(BodyKeys.Udacity)\": {\"\(BodyKeys.Username)\": \"\(userName!)\", \"\(BodyKeys.Password)\": \"\(password!)\"}}"
            
            taskForPostMethod(Methods.Session, parameters: nil, jsonBody: jsonBody, completionHandlerForPost: { (results, error) in
                
                func sendError(error: NSError?) {
                    completionHandlerForAuthentication(success: false, error: error)
                }
                
                guard (error == nil) else
                {
                    sendError(error)
                    return
                }
                
                guard let udacitySession = results[JSONResponseKeys.Session] as? [String:AnyObject]  else
                {
                    let userInfo = [NSLocalizedDescriptionKey : "Cannot find session key in results '\(results)"]
                    sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                    return
                }
                
                guard let udacitySessionID = udacitySession[JSONResponseKeys.ID] as? String else {
                    let userInfo = [NSLocalizedDescriptionKey : "Cannot find ID key in results '\(results)"]
                    sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                    return
                }
                
                guard let udacityAccount = results[JSONResponseKeys.Account] as? [String : AnyObject] else {
                    let userInfo = [NSLocalizedDescriptionKey : "Cannot find Udacity Account key in results '\(results)"]
                    sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                    return
                }
                
                guard let udacityKey = udacityAccount[JSONResponseKeys.Key] as? String else {
                    let userInfo = [NSLocalizedDescriptionKey : "Cannot find Udacity key (ID) in results '\(results)"]
                    sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                    return
                }
                
                self.udacityUserID = udacityKey
                self.udacitySessionID = udacitySessionID
                
                completionHandlerForAuthentication(success: true, error: nil)
            })
        } else {
            let userInfo = [NSLocalizedDescriptionKey : "Username or Password is blank"]
            completionHandlerForAuthentication(success: false, error:(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo)))
        }
        
    }
    func authenticateWithUdacityWithFacebook(accessToken: String, completionHandlerForAuthentication: (success: Bool?, error: NSError?) -> Void) -> Void {
        
        let jsonBody = "{\"\(BodyKeys.Facebook)\": {\"access_token\":\"\(accessToken)\"}}"
        
        taskForPostMethod(Methods.Session, parameters: nil, jsonBody: jsonBody, completionHandlerForPost: { (results, error) in
            
            func sendError(error: NSError?) {
                completionHandlerForAuthentication(success: false, error: error)
            }
            
            guard (error == nil) else
            {
                sendError(error)
                return
            }
            
            guard let udacitySession = results[JSONResponseKeys.Session] as? [String:AnyObject]  else
            {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find session key in results '\(results)"]
                sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                return
            }
            
            guard let udacitySessionID = udacitySession[JSONResponseKeys.ID] as? String else {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find ID key in results '\(results)"]
                sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                return
            }
            
            guard let udacityAccount = results[JSONResponseKeys.Account] as? [String : AnyObject] else {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find Udacity Account key in results '\(results)"]
                sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                return
            }
            
            guard let udacityKey = udacityAccount[JSONResponseKeys.Key] as? String else {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find Udacity key (ID) in results '\(results)"]
                sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                return
            }
            
            self.udacityUserID = udacityKey
            self.udacitySessionID = udacitySessionID
            
            completionHandlerForAuthentication(success: true, error: nil)
        })
        
    }
    
    
    //MARK: Getting Data From Parse
    
    func getStudentsInformationFromParse(completionHandlerForGetStudentDataFromParse: (usersInfoArray: [[String:AnyObject]]!, error: NSError?) -> Void) -> Void
    {
        let parameters = [ ParseParameterKeys.SortOrder : ParseParameterValues.SortDescending]
        
        taskForGETMethod(ParseMethods.StudentLocation, parameters: parameters, completionHandlerForGET: { (results, error) in
            
            guard (error == nil) else {
                completionHandlerForGetStudentDataFromParse(usersInfoArray: nil, error: error)
                return
            }
            
            guard let resultsUsersInfo = results[ParseResults.ParseResults] as? [[String:AnyObject]]  else
            {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find results key in  '\(results)"]
                completionHandlerForGetStudentDataFromParse(usersInfoArray: nil, error: (NSError(domain: "getStudentsInformationFromParse", code: 1, userInfo: userInfo)))
                return
            }
            
            completionHandlerForGetStudentDataFromParse(usersInfoArray: resultsUsersInfo, error: nil)
            
        })
    }
    
    
    func getStudentLocationFromParse(completionHandlerForGetStudentLocation: (studentInfo: [String:AnyObject]? , studentFound: Bool, error: NSError?) -> Void) -> Void
    {
        if udacityUserID == nil {
            completionHandlerForGetStudentLocation(studentInfo: nil, studentFound: false, error: NSError(domain: "getStudentLocationFromParse", code: 1, userInfo: [NSLocalizedDescriptionKey : "User Is Not Logged In"]))
        } else {
            let parameters = [ ParseParameterKeys.Where : "{\"uniqueKey\":\"\(udacityUserID!)\"}"]
            taskForGETMethod(ParseMethods.StudentLocation, parameters: parameters) { (result, error) in
                print(error)
                guard (error == nil) else {
                    completionHandlerForGetStudentLocation(studentInfo: nil, studentFound: false, error: error)
                    return
                }
                
                guard let resultUserInfo = result[ParseResults.ParseResults] as? [[String:AnyObject]] else {
                    let userInfo = [NSLocalizedDescriptionKey : "Coulnd't find results key in '\(result)"]
                    completionHandlerForGetStudentLocation(studentInfo: nil, studentFound: false, error: NSError(domain: "getStudentLocationFromParse", code: 1, userInfo: userInfo))
                    return
                }
                guard resultUserInfo.count > 0 else {
                    completionHandlerForGetStudentLocation(studentInfo: nil, studentFound:false, error: nil)
                    return

                }
                completionHandlerForGetStudentLocation(studentInfo: resultUserInfo[0], studentFound: true, error: nil)
            }
        }
        
    }
    
    func postSudentLocationToParse(studentInfo: [String:AnyObject], completionHandlerForPostStudentLocationToParse: (success: Bool, error: NSError?) -> Void) -> Void
    {
        convertDictionaryToJSONWithCompletionHandler(studentInfo) { (result, error) in
            guard (error == nil) else {
                completionHandlerForPostStudentLocationToParse(success: false, error: error)
                return
            }
            
            guard let jsonBody = result as? String else {
                
                let userInfo = [NSLocalizedDescriptionKey : "Couldn't convert studentInfo dictionary to JSON"]
                completionHandlerForPostStudentLocationToParse(success: false, error: NSError(domain: "postStudentLocationToParse", code: 1, userInfo: userInfo))
                return
            }
            
            self.taskForParseMethod("POST", method: ParseMethods.StudentLocation, parameters: nil, jsonBody: jsonBody, completionHandlerForParse: { (result, error) in
                guard (error == nil) else {
                    completionHandlerForPostStudentLocationToParse(success: false, error: error)
                    return
                }
                
                completionHandlerForPostStudentLocationToParse(success: true, error: nil)
            })
            
        }
    }
    
    func updateStudentLocationToParse(studentInfo: [String:AnyObject], completionHandlerForUpdateSudentLocationToParse: (success: Bool, error: NSError?) -> Void) -> Void
    {
        convertDictionaryToJSONWithCompletionHandler(studentInfo) { (result, error) in
            guard (error == nil) else {
                completionHandlerForUpdateSudentLocationToParse(success: false, error: error)
                return
            }
            guard let jsonBody = result as? String else {
                
                let userInfo = [NSLocalizedDescriptionKey : "Couldn't convert studentInfo dictionary to JSON"]
                completionHandlerForUpdateSudentLocationToParse(success: false, error: NSError(domain: "updateSudentLocationToParse", code: 1, userInfo: userInfo))
                return
            }
            self.taskForParseMethod("PUT", method: self.subtituteKeyInMethod(ParseMethods.StudentLocationWithObjectID, key: "1", value: (studentInfo["objectId"] as? String)!)!,parameters: nil, jsonBody: jsonBody, completionHandlerForParse: { (result, error) in
                guard (error == nil) else {
                    completionHandlerForUpdateSudentLocationToParse(success: false, error: error)
                    return
                }
                
                completionHandlerForUpdateSudentLocationToParse(success: true, error: nil)
            })
            
        }
    }


    
    
    // MARK: Network Convinience Methods
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject]?, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        request.addValue(ParseApplicationValues.ParseApplicationID, forHTTPHeaderField: ParseApplicationKeys.ParseApplicationID)
        request.addValue(ParseApplicationValues.ParseRESTAPIKEY, forHTTPHeaderField: ParseApplicationKeys.ParseRESTAPIKey)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            
        }
        
        task.resume()
        
        return task
        
    }

    
    
  
    func taskForPostMethod(method: String, parameters: [String:AnyObject]?, jsonBody: String, completionHandlerForPost: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPost(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard data != nil else {
                sendError("No data was returned by request!")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: { (result, error) in
                    guard(error == nil) else {
                        sendError("Your request returned a status code other than 2xx!")
                        return
                    }
                    sendError(result["error"] as! String)
                })
                
                return
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPost)
        }
        
        task.resume()
        
        return task
        
    }
    
    func taskForDeleteMethod(method: String, completionHandlerForDeleteMethod: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(nil, withPathExtension: method))
        
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDeleteMethod(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard data != nil else {
                sendError("No data was returned by request!")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: { (result, error) in
                    guard(error == nil) else {
                        sendError("Your request returned a status code other than 2xx!")
                        return
                    }
                    sendError(result["error"] as! String)
                })
                
                return
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDeleteMethod)
            
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        return task;
        
    }
    
    func taskForParseMethod(requestMethod: String, method: String, parameters: [String:AnyObject]?, jsonBody: String, completionHandlerForParse: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = requestMethod
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForParse(result: nil, error: NSError(domain: "taskForParseMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error!.localizedDescription)
                return
            }
            guard data != nil else {
                sendError("No data was returned by request!")
                return
            }
            //let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))

            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: { (result, error) in
                    guard(error == nil) else {
                        sendError("Your request returned a status code other than 2xx!")
                        return
                    }
                    sendError(result["Error"] as! String)
                })
                
                return
            }
            
            
            
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForParse)
        }
        
        task.resume()
        return task
    }
    
    private func parseURLFromParameters(parameters: [String : AnyObject]?, withPathExtension: String? = nil) -> NSURL
    {
        let components = NSURLComponents()
        
        components.scheme = ParseConstants.ApiScheme
        components.host = ParseConstants.ApiHost
        components.path = ParseConstants.ApiPath + (withPathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [NSURLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        
        return components.URL!
    }

    private func udacityURLFromParameters(parameters: [String:AnyObject]?, withPathExtension: String? = nil) -> NSURL
    {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        if let parameters = parameters {
            components.queryItems = [NSURLQueryItem]()
            
            for (key, value) in parameters
            {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.URL!
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData:(result: AnyObject!, error: NSError?) -> Void)
    {
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Couldn't Parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
        
    }
    
    private func convertDictionaryToJSONWithCompletionHandler(dictionary: [String:AnyObject], completionHandlerForConverDictionaryToJSON:(result: AnyObject!, error: NSError?) -> Void)
    {
        var parsedResult:  NSData!
        var stringJSON: String = ""
        do {
            parsedResult = try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
            stringJSON = NSString(data: parsedResult, encoding: NSUTF8StringEncoding)  as! String
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not convert dictionary to JSON: '\(stringJSON)'"]
            completionHandlerForConverDictionaryToJSON(result: nil, error: NSError(domain: "convertDictionaryToJSON", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConverDictionaryToJSON(result: stringJSON, error: nil)
    }
    
    private func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

}
