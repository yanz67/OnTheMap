//
//  UdacityUser.swift
//  On The Map
//
//  Created by Yan Zverev on 7/20/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

struct ParseUserInfoKeys
{
    static let FirstName = "firstName"
    static let LastName = "lastName"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
    static let MapString = "mapString"
    static let MediaURL = "mediaURL"
    static let ObjectID = "objectId"
    static let UniqueKey = "uniqueKey"
}
struct UdacityUser
{
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectID: String
    var uniqueKey: String
    
    init(userInformation: [String:AnyObject])
    {
        firstName = userInformation[ParseUserInfoKeys.FirstName] as! String
        lastName = userInformation[ParseUserInfoKeys.LastName] as! String
        latitude = userInformation[ParseUserInfoKeys.Latitude] as! Double
        longitude = userInformation[ParseUserInfoKeys.Longitude] as! Double
        mapString = userInformation[ParseUserInfoKeys.MapString] as! String
        mediaURL = userInformation[ParseUserInfoKeys.MediaURL] as! String
        objectID = userInformation[ParseUserInfoKeys.ObjectID] as! String
        uniqueKey = userInformation[ParseUserInfoKeys.UniqueKey] as! String
    }
    
   
    func convetToDictionary() -> [String:AnyObject]
    {
        let userDictionary = [ParseUserInfoKeys.FirstName : firstName,
                              ParseUserInfoKeys.LastName : lastName,
                              ParseUserInfoKeys.Latitude : latitude,
                              ParseUserInfoKeys.Longitude : longitude,
                              ParseUserInfoKeys.MapString : mapString,
                              ParseUserInfoKeys.MediaURL : mediaURL,
                              ParseUserInfoKeys.ObjectID : objectID,
                              ParseUserInfoKeys.UniqueKey : uniqueKey
        ]
        
        return userDictionary as! [String : AnyObject]
    }

}
