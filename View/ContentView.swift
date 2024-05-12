import SwiftUI
import Firebase
import StoreKit

struct ContentView: View {
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @ObservedObject var userData: UserData
    @State private var isAgreedView: Bool = false
    
    var body: some View {
        Group {
            if firebaseManager.isLoggedIn == true {
                if userData.isAgreed == false {
                    AgreeView(userData: userData, isAgreedView: $isAgreedView)
                } else {
                    LoggedinView_new()
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            firebaseManager.listenForAuthChanges()
        }
    }
}



