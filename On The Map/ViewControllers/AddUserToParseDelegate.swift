//
//  AddUserToParseDelegate.swift
//  On The Map
//
//  Created by Yan Zverev on 7/25/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

protocol AddUserToParseDelegate {
    func userAddedToParse() -> Void
    func userCancel() -> Void
}
