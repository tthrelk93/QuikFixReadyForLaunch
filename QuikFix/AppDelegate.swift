//
//  AppDelegate.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 8/30/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import UserNotifications
import CoreLocation
import Stripe
import IQKeyboardManagerSwift
//import HockeySDK




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    // 1) To get started with this demo, first head to https://dashboard.stripe.com/account/apikeys
    // and copy your "Test Publishable Key" (it looks like pk_test_abcdef) into the line below.
    let stripePublishableKey = "pk_test_cmqNsIYuyCchUdHAnaHOyiXp"//"pk_live_F3qPhd7gnfCP6HP2gi1LTX41"
    
    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend , click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    let backendBaseURL: String? = "https://quikfixfinal.herokuapp.com"
    
    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    let appleMerchantID: String? = nil
    
    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "QuikFix"
    let paymentCurrency = "usd"
    
    
    //var notificationCenter: UNUserNotificationCenter?

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        /*print("geoShit: \(locationManager.monitoredRegions)")
        //
        for region in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: region)
        }*/
        
        /*BITHockeyManager.shared().configure(withIdentifier: "APP_IDENTIFIER")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation() // This line is obsolete in the crash only builds*/
        IQKeyboardManager.sharedManager().enable = true
        GMSPlacesClient.provideAPIKey("AIzaSyDvw0LOBxWRxlY56O3sbE5nCqs3T3K1u-M")
        GMSServices.provideAPIKey("AIzaSyADVDZNEDAirfuVo92hECXnvCvTay8gXqo")
        
        
       
            // your app's "normal" behaviour goes here
            // ...
            
            // define what do you need permission to use
        
            /*let options: UNAuthorizationOptions = [.alert, .sound]
            notificationCenter?.requestAuthorization(options: options) { (granted, error) in
                if !granted {
                    print("Permission not granted")
                }
            }*/
        // Fallback on earlier versions
        
            
            // request permission
        
            
            
            STPPaymentConfiguration.shared().publishableKey = "pk_test_cmqNsIYuyCchUdHAnaHOyiXp"//"pk_live_F3qPhd7gnfCP6HP2gi1LTX41"
            MyAPIClient.sharedClient.baseURLString = self.backendBaseURL
            
            // This code is included here for the sake of readability, but in your application you should set up your configuration and theme earlier, preferably in your App Delegate.
            let config = STPPaymentConfiguration.shared()
            config.publishableKey = self.stripePublishableKey
            config.appleMerchantIdentifier = self.appleMerchantID
            config.companyName = self.companyName
            // config.requiredBillingAddressFields = settings.requiredBillingAddressFields
            //config.requiredShippingAddressFields = settings.requiredShippingAddressFields
            // config.shippingType = settings.shippingType
            // config.additionalPaymentMethods = settings.additionalPaymentMethods
            
            /*var configureError: NSError?
             GGLContext.sharedInstance().configureWithError(&configureError)
             assert(configureError == nil, "Error configuring Google services: \(configureError)")*/
            
            Messaging.messaging().delegate = self
            
            
            
            // iOS 10 support
        
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()
       
       
        
        return true
    }
    /*@available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }*/
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print("url \(url)")
        print("url host :\(url.host!)")
        print("url path :\(url.path)")
        var uid = String()
        var stripeKey = String()
        var count = 0
        for comp in url.pathComponents{
            print("path component \(count): \(comp)")
            if count == 2{
                stripeKey = comp
            }
            if count == 3 {
                uid = comp
            }
            count = count + 1
        }
        uid.removeFirst()
        uid.removeLast()
        print("uid: \(uid)")
        let urlPath : String = url.path as String!
        let urlHost : String = url.host as String!
        let returnStoryboard: UIStoryboard = UIStoryboard(name: "StudentProfile", bundle: nil)
        
        if(urlHost != "quikfixredirect.com")
        {
            print("Host is not correct")
            return false
        }
        
        
        Database.database().reference().child("students").child(uid).updateChildValues([stripeKey: true])
        
        
        let innerPage: studentProfile = returnStoryboard.instantiateViewController(withIdentifier: "UIViewController-zzN-0X-3KP") as! studentProfile
            //innerPage.stripeConnectID = responseObject!
        //innerPage.willConnectStripe = true
        self.window?.rootViewController = innerPage
            
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    var token: String?
    func connectToFBMessaging()
    {
        Messaging.messaging().shouldEstablishDirectChannel = true
        /*Messaging.messaging().connect { (error) in
         if (error != nil)
         {
         print("unable to connect lol \(error)")
         }
         else
         {
         print("connected to firebase")
         }
         }*/
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        self.token = Messaging.messaging().fcmToken
        
        //let refreshedToken = FIRInstanceID.instanceID().token()
        // print("InstanceID token: \(refreshedToken)")
        connectToFBMessaging()
        
    }
    
    func tokenRefreshNotification(notification: NSNotification)
    {
        print("inRefresh")
        self.token = Messaging.messaging().fcmToken
        //let refreshedToken = FIRInstanceID.instanceID().token()
        // print("InstanceID token: \(refreshedToken)")
        connectToFBMessaging()
    }
    
  
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        /*print("MessageID: \(userInfo["gcm_message_id"]!)")
        
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? NSString {
                    //Do stuff
                    var notifiAlert = UIAlertView()
                    //var NotificationMessage : AnyObject? =  userInfo["alert"]
                    notifiAlert.title = "One Night Band Invite"
                    notifiAlert.message = message as? String
                    notifiAlert.addButton(withTitle: "OK")
                    notifiAlert.show()
                }
            } else if let alert = aps["alert"] as? NSString {
                //Do stuff
                var notifiAlert = UIAlertView()
                //var NotificationMessage : AnyObject? =  userInfo["alert"]
                notifiAlert.title = "One Night Band Invite"
                notifiAlert.message = alert as? String
                notifiAlert.addButton(withTitle: "OK")
                notifiAlert.show()
            }
        }
        // NotificationCenter.
        
        print(userInfo)*/
    }
    var deviceToken: String?
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        Messaging.messaging().shouldEstablishDirectChannel = true
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        self.deviceToken = deviceTokenString
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // Persist it in your backend in case it's new
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    // Push notification received
    //Make use of the data object which will contain any data that you send from your application backend, such as the chat ID, in the messenger app example.
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        // let alert = UIAlertController(title: "Tapped the alert banner", message: "Popups are a terrible user experience, eh?", preferredStyle: .Alert)
        //self.showViewController(alert, sender: nil)
        print("Push notification received: \(data)")
        
    }
    
    func note(fromRegionIdentifier identifier: String) -> [String]? {
        var dataArray = [String]()
        let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
        let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
        let index = geotifications?.index { $0?.identifier == identifier }
        
        dataArray.append((geotifications?[index!]?.note)!)
        dataArray.append((geotifications?[index!]?.identifier)!)
        dataArray.append((geotifications?[index!]?.studentID)!)
        return dataArray
    }
    func handleEvent(forRegion region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            guard let message = note(fromRegionIdentifier: region.identifier)?[0] else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = note(fromRegionIdentifier: region.identifier)?[1]
            notification.soundName = "Default"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
        
    }

}
extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("locDidEnter")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM-dd-yyyy h:mm a"
            let now = dateFormatter.string(from: Date())
            
            print(note(fromRegionIdentifier: region.identifier)![2])
            Database.database().reference().child("jobs").child(note(fromRegionIdentifier: region.identifier)![0]).child("timeLogs").child(note(fromRegionIdentifier: region.identifier)![2]).updateChildValues(["studentOnLocation": now])
            handleEvent(forRegion: region)
            Database.database().reference().child("students").child(note(fromRegionIdentifier: region.identifier)![2]).child("upcomingJobs").child(note(fromRegionIdentifier: region.identifier)![0]).child("timeLogs").child(note(fromRegionIdentifier: region.identifier)![2]).updateChildValues(["studentOnLocation":now])
            
            Database.database().reference().child("jobPosters").child(note(fromRegionIdentifier: region.identifier)![1]).child("upcomingJobs").child(note(fromRegionIdentifier: region.identifier)![0]).child("timeLogs").child(note(fromRegionIdentifier: region.identifier)![2]).updateChildValues(["studentOnLocation":now])
            //region.identifier
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            Database.database().reference().child("jobs").child(note(fromRegionIdentifier: region.identifier)![0]).child("timeLogs").updateChildValues(["studentOnLocation":"false"])
            Database.database().reference().child("students").child(note(fromRegionIdentifier: region.identifier)![2]).child("upcomingJobs").child(note(fromRegionIdentifier: region.identifier)![0]).child("timeLogs").updateChildValues(["studentOnLocation":"false"])
            
            Database.database().reference().child("jobPosters").child(note(fromRegionIdentifier: region.identifier)![1]).child("upcomingJobs").child(note(fromRegionIdentifier: region.identifier)![0]).child("timeLogs").updateChildValues(["studentOnLocation":"false"])
            
            handleEvent(forRegion: region)
        }
    }
}
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}




