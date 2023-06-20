import UIKit
import Flutter
import Firebase
import PushNotificationPackage

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,PushNotificationManagerDelegate {
    var pushNotificationPackage = ACMLPushNotificationManager().getInstance()
    var fcmTokens = ""
    let channelName = "ACMLFlutterChannel"
    var methodChannel: FlutterMethodChannel?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      Analytics.setAnalyticsCollectionEnabled(true)
      Messaging.messaging().delegate = self
      pushNotificationPackage.registerForPushNotification()
      pushNotificationPackage.delegate = self

      GeneratedPluginRegistrant.register(with: self)

      let flutterVC = window?.rootViewController as! FlutterViewController
      methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: flutterVC.binaryMessenger)

      methodChannel!.setMethodCallHandler {
      (call: FlutterMethodCall, result: FlutterResult) -> Void in
      switch (call.method) {
      case "ShieldRegistration":
          // print("calling method ")
          // print(call.arguments as Any)
          let arguments = call.arguments as! [String:Any]
          let appID = arguments["appID"] as! String
          let userName = arguments["username"] as! String
          let userType = arguments["userType"] as! String
          let regUrl = arguments["regUrl"] as! String
          let appversion = arguments["appversion"] as! String
          self.pushNotificationPackage.isEncryptionEnabled = arguments["isCrypto"] as! Bool
          self.pushNotificationPackage.secretKey = arguments["secretKey"] as! String

          // print("push notitication token\n" + self.fcmTokens)
          // print(regUrl)
          // print(userName)

          self.sendPushNotificationRequest(token: self.fcmTokens, userName: userName, userType: userType, appID: appID, regURL: regUrl, appversion: appversion)
     case "pushLogsToServer":
        //  print("calling pushLogsToServer method ")
        //  print(call.arguments as Any)
         self.pushNotificationPackage.minsToAdd = 240
         let arguments = call.arguments as! [String:Any]
         let appID = arguments["appID"] as! String
         let regUrl = arguments["regUrl"] as! String
         self.pushNotificationPackage.isEncryptionEnabled = arguments["isCrypto"] as! Bool
         self.pushNotificationPackage.secretKey = arguments["secretKey"] as! String

         self.pushNotificationPackage.checkDateAndTimeAndSendDeliveryAck(connectionURL: regUrl)

          
      default: result(FlutterMethodNotImplemented)
      }
      }

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
       }


func targetToNavigate(_ target: String) {
  var freshLaunch = false
     let state = UIApplication.shared.applicationState
     if state == .active || state == .background {
         freshLaunch = true
     }
     else if state == .inactive {
         freshLaunch = false
     }
  let arguments = ["PUSH_CLICK_ACTION":target,"IS_FRESH_LAUNCH":freshLaunch,"VIDEO_LINK" :""] as [String : Any]
     methodChannel!.invokeMethod("handleNotificationClick", arguments: arguments)

  }

func checkNotification(){
}
    
func shieldRegistration(){}
    
func sendPushNotificationRequest(token:String,userName:String,userType:String,appID:String,regURL:String, appversion: String){
        pushNotificationPackage.sendPushRegistrationRequest(fcmToken: token, forUsername: userName, andUserType: userType, withAppID: appID, andConnectionURL: regURL, andAppVersion: appversion, completionHandler: { (completionFlag) -> Void in
            if completionFlag {
                // print(regURL)
                // print(userName)
                // print(token)
                // print("Register successfully")
            }
            else {

            }
        })
    }

}

extension AppDelegate : MessagingDelegate {
         
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      // print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict:[String: String] = ["token": fcmToken! ?? ""]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        fcmTokens = fcmToken! ?? "";
    }
  }
