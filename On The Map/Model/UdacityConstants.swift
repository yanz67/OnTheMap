//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Yan Zverev on 7/19/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

extension UdacityClientManager
{
    struct Constants
    {
        //MARK: URLS
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    struct Methods
    {
        static let Session = "/session"
        static let users = "/users/{ID}"
    }
    
    struct BodyKeys
    {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let Facebook = "facebook_mobile"
    }
    
    struct JSONResponseKeys
    {
        //MARK: Authentication
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        
        //MARK: Session
        static let Session = "session"
        static let ID = "id"
        static let Expiration = "expiration"
    }
    
    struct ParseConstants
    {
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes"
    }
    
    struct ParseApplicationKeys
    {
        static let ParseApplicationID = "X-Parse-Application-Id"
        static let ParseRESTAPIKey = "X-Parse-REST-API-Key"
    }
    
    struct ParseApplicationValues
    {
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRESTAPIKEY = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }

    struct ParseMethods
    {
        static let StudentLocation = "/StudentLocation"
        static let StudentLocationWithObjectID = "/StudentLocation/{1}"
    }
    
    struct ParseParameterKeys
    {
        static let SortOrder = "order"
        static let Limit = "limit"
        static let Skip = "skip"
        static let Where = "where"
    }
    
    struct ParseParameterValues
    {
        static let SortAscending = "updatedAt"
        static let SortDescending = "-updatedAt"
    }
    
    struct ParseResults
    {
        static let ParseResults = "results"
    }
    
    
}