//
//  AppDelegate.swift
//  ScrollView
//
//  Created by Nguyễn Thành on 7/15/17.
//  Copyright © 2017 Nguyễn Thành. All rights reserved.
//
// garuda nt
import UIKit
import CallKit
import UserNotifications
import CoreTelephony

var callObservers: CXCallObserver!
var bgTask = UIBackgroundTaskIdentifier()
// in applicationDidFinishLaunching...


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    var backgroundUpdateTask: UIBackgroundTaskIdentifier = 0
    var strDeviceToken : String = ""
    var window: UIWindow?
    var callCenter : CTCallCenter = CTCallCenter()
    var observer : CXCallObserver?
    var call: CXCall?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        callObservers = CXCallObserver()
        callObservers.setDelegate(self, queue: nil)
        registerForRemoteNotification()
        
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskInvalid
        })
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let chars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var token = ""
        
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [chars[i]])
        }
        
        print("Device Token = ", token)
        self.strDeviceToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Error = ",error.localizedDescription)
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ",response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func pushNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Detected a Call"
        content.body = "Hello"
        //        content.categoryIdentifier = "pizza.category"
        // ----- Use a time interval trigger of 5 seconds, non repeating
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        
        // ----- Add the trigger and the content to the request
        let request = UNNotificationRequest(identifier: "pizza", content: content, trigger: trigger)
        
        // Add the request to the current notification center, and notify the developer of errors in the closure.
        UNUserNotificationCenter.current().add(request){
            (error) in
            if error != nil{
                print ("Add notification error: \(error?.localizedDescription)")
            }
        }
        
    }
    
    final func setup(){
        
        let networkInfo = CTTelephonyNetworkInfo()
        let code = networkInfo.subscriberCellularProvider?.mobileCountryCode
        print("\(code)")
        
        self.observer = CXCallObserver()
       
        self.observer?.setDelegate(self, queue: nil)
        self.callCenter = CTCallCenter()
    }
    
    

    // MARK: Class Methods
    
    func registerForRemoteNotification() {
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        self.endBackgroundUpdateTask()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            self.setup()
            print("call: \(self.observer?.calls)")
            if (self.observer?.calls.count)!  > 0 {
                self.callObserver(self.observer!, callChanged: (self.observer?.calls[0])!)
            }
        }
        callCenter.callEventHandler = block
    }
    func block(call: CTCall!) {
        print("aaa")
        let callState = String(call.callState)
        print(callState)
    }
}

extension AppDelegate: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
            pushNotification()
        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
            print("get notification")
        }
    }
}
