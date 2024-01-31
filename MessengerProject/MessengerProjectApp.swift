//
//  MessengerProjectApp.swift
//  MessengerProject
//
//  Created by Yeonu Park on 2024/01/06.
//

import SwiftUI
import Kingfisher
import RealmSwift

@main
struct MessengerProjectApp: SwiftUI.App {
    
    init() {
        configureRealm()
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            InitialView()
                .onAppear() {
                    registerForRemoteNotifications()
                    print("accessToken: \(UserDefaults.standard.string(forKey: "token") ?? "")")
                    //print("refreshToken: \(UserDefaults.standard.string(forKey: "refreshToken") ?? "")")
                }
        }
    }
    
    func registerForRemoteNotifications() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("Notification permission denied.")
                }
            }
        }
    
    func configureRealm() {
        let config = Realm.Configuration(schemaVersion: 10) { migration, oldSchemaVersion in
            
            if oldSchemaVersion < 1 { } // UserTable에 id 추가
            
        }
        Realm.Configuration.defaultConfiguration = config
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: "deviceToken")
        
        let modifier = AnyModifier { request in
            var r = request
            r.setValue(APIkeys.sesacKey, forHTTPHeaderField: "SesacKey")
            r.setValue(UserDefaults.standard.string(forKey: "token") ?? "", forHTTPHeaderField: "Authorization")
            //r.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return r
        }
        
        KingfisherManager.shared.defaultOptions = [.requestModifier(modifier)]
        
    }
}
