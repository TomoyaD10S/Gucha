import SwiftUI
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    
        return true
    }
    
}

@main
struct YourApp: App {
    @StateObject var firebaseManager = FirebaseManager.shared
    @StateObject var userData = UserData()
        
    
    var body: some Scene {
        WindowGroup {
            ContentView(userData: userData)
                .environmentObject(firebaseManager)
        }
    }
}


