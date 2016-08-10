//
//  UdacityUsersClient.swift
//  On The Map
//
//  Created by Yan Zverev on 7/20/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation

class UdacityUsersModel: NSObject
{
    
    static let sharedInstance = UdacityUsersModel()
    
    var udacityUsers: [UdacityUser] = [UdacityUser]()
    
    func loadUsersData(completionHandlerForLoadUsersData:(success: Bool, error: NSError?) -> Void) -> Void
    {
        udacityUsers.removeAll()
        UdacityClientManager.sharedInstance.getStudentsInformationFromParse { (usersInfoArray, error) in
            
            guard (error == nil) else {
                completionHandlerForLoadUsersData(success: false, error: error!)
                return
            }
            
            guard (usersInfoArray != nil) else {
                completionHandlerForLoadUsersData(success: false, error: NSError(domain: "CompletionHandlerForLoadUsrsData", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error getting parse users info"]))
                return
            }
            for user in usersInfoArray {
                let udacityUser = UdacityUser(userInformation: user)
                self.udacityUsers.append(udacityUser)
            }
            completionHandlerForLoadUsersData(success: true, error: nil)
        }
    }
    
    func getUserForIndex(index: Int) -> UdacityUser?
    {
        if index >= 0 && index < udacityUsers.count {
            return udacityUsers[index]
        }
        
        return nil
    }
    
    func getUsersCount() -> Int
    {
        return udacityUsers.count
    }
    

}
