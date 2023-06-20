//
//  NotificationService.swift
//  ACMLNotificationServiceExtension
//
//  Created by Sahana Dhanraj on 22/06/22.
//

import UserNotifications
import PushNotificationPackage

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var pushNotificationPackage = ACMLPushNotificationManager().getInstance()

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        pushNotificationPackage.didReceiveNotification(request, withContentHandler: {(modifiedContent)-> Void in
                   contentHandler(modifiedContent)
               })
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        pushNotificationPackage.notificationServiceExtensionTimeWillExpire()
    }

}
