//
//  ACMLPushNotificationManager.swift
//  Runner
//
//  Created by Sahana Dhanraj on 22/06/22.
//

import UIKit
import PushNotificationPackage

public class ACMLPushNotificationManager {
    
    static var instance : PushNotificationManager!
    
    public func getInstance() -> PushNotificationManager {
        if ACMLPushNotificationManager.instance == nil {
            #if qa
            ACMLPushNotificationManager.instance = PushNotificationManager.init(userDefaultSuitName:"group.com.msf.acml.qa.app.group")
            #elseif uat
            ACMLPushNotificationManager.instance = PushNotificationManager.init(userDefaultSuitName:"group.com.msf.acml.uat.app.group")
            #else
            ACMLPushNotificationManager.instance = PushNotificationManager.init(userDefaultSuitName:"group.com.msf.acml.app.group")
            #endif
        }
        return ACMLPushNotificationManager.instance
    }
    
}
